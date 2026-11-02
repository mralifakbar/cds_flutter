import 'dart:math' as math;

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Which piece of cell content wins when space runs out.
enum CdsCellPriority { start, middle, end }

/// Slots of a [CdsCellLayout]. Internal.
enum CdsCellSlot { media, main, intermediary, end, accessory }

/// Lays out a cell row the way CDS does with flexbox: media and accessory
/// keep their size, the main content and end content grow into free space,
/// and when space runs out every piece not named in [priority] shrinks in
/// proportion to its natural width (CSS `flex-shrink` weighted by basis).
///
/// Internal to cds_flutter; used by cells and table cells.
class CdsCellLayout extends SlottedMultiChildRenderObjectWidget<CdsCellSlot, RenderBox> {
  const CdsCellLayout({
    super.key,
    this.media,
    required this.main,
    this.intermediary,
    this.end,
    this.accessory,
    this.gap = 0,
    this.alignItems = CrossAxisAlignment.center,
    this.priority = const {},
    this.endWidth,
  });

  final Widget? media;
  final Widget main;
  final Widget? intermediary;
  final Widget? end;
  final Widget? accessory;

  /// Gap between pieces in logical pixels.
  final double gap;
  final CrossAxisAlignment alignItems;
  final Set<CdsCellPriority> priority;

  /// Fixed width for the end content; it neither grows nor shrinks.
  final double? endWidth;

  @override
  Iterable<CdsCellSlot> get slots => CdsCellSlot.values;

  @override
  Widget? childForSlot(CdsCellSlot slot) => switch (slot) {
        CdsCellSlot.media => media,
        CdsCellSlot.main => main,
        CdsCellSlot.intermediary => intermediary,
        CdsCellSlot.end => end,
        CdsCellSlot.accessory => accessory,
      };

  @override
  RenderCdsCellLayout createRenderObject(BuildContext context) => RenderCdsCellLayout(
        gap: gap,
        alignItems: alignItems,
        priority: priority,
        endWidth: endWidth,
        textDirection: Directionality.of(context),
      );

  @override
  void updateRenderObject(BuildContext context, RenderCdsCellLayout renderObject) {
    renderObject
      ..gap = gap
      ..alignItems = alignItems
      ..priority = priority
      ..endWidth = endWidth
      ..textDirection = Directionality.of(context);
  }
}

class RenderCdsCellLayout extends RenderBox with SlottedContainerRenderObjectMixin<CdsCellSlot, RenderBox> {
  RenderCdsCellLayout({
    required double gap,
    required CrossAxisAlignment alignItems,
    required Set<CdsCellPriority> priority,
    required double? endWidth,
    required TextDirection textDirection,
  })  : _gap = gap,
        _alignItems = alignItems,
        _priority = priority,
        _endWidth = endWidth,
        _textDirection = textDirection;

  double _gap;
  set gap(double v) {
    if (v == _gap) return;
    _gap = v;
    markNeedsLayout();
  }

  CrossAxisAlignment _alignItems;
  set alignItems(CrossAxisAlignment v) {
    if (v == _alignItems) return;
    _alignItems = v;
    markNeedsLayout();
  }

  Set<CdsCellPriority> _priority;
  set priority(Set<CdsCellPriority> v) {
    if (setEquals(v, _priority)) return;
    _priority = v;
    markNeedsLayout();
  }

  double? _endWidth;
  set endWidth(double? v) {
    if (v == _endWidth) return;
    _endWidth = v;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  List<(CdsCellSlot, RenderBox)> get _present => [
        for (final slot in CdsCellSlot.values)
          if (childForSlot(slot) case final child?) (slot, child),
      ];

  bool _isFixed(CdsCellSlot slot) =>
      slot == CdsCellSlot.media || slot == CdsCellSlot.accessory || (slot == CdsCellSlot.end && _endWidth != null);

  bool _grows(CdsCellSlot slot) => slot == CdsCellSlot.main || (slot == CdsCellSlot.end && _endWidth == null);

  bool _shrinks(CdsCellSlot slot) => switch (slot) {
        CdsCellSlot.main => !_priority.contains(CdsCellPriority.start),
        CdsCellSlot.intermediary => !_priority.contains(CdsCellPriority.middle),
        CdsCellSlot.end => !_priority.contains(CdsCellPriority.end),
        _ => false,
      };

  /// Widths for every present child given [maxWidth]. [fixedWidth] measures
  /// media and accessory; flexible pieces use their max intrinsic width as
  /// the flex basis.
  Map<CdsCellSlot, double> _widths(double maxWidth, double Function(CdsCellSlot, RenderBox) fixedWidth) {
    final present = _present;
    final widths = <CdsCellSlot, double>{};
    if (present.isEmpty) return widths;
    var used = _gap * (present.length - 1);
    final flexible = <(CdsCellSlot, RenderBox)>[];
    for (final entry in present) {
      if (_isFixed(entry.$1)) {
        final w = entry.$1 == CdsCellSlot.end ? _endWidth! : fixedWidth(entry.$1, entry.$2);
        widths[entry.$1] = w;
        used += w;
      } else {
        flexible.add(entry);
      }
    }
    final basis = {for (final (slot, child) in flexible) slot: child.getMaxIntrinsicWidth(double.infinity)};
    if (!maxWidth.isFinite) {
      widths.addAll(basis);
      return widths;
    }
    final available = math.max(0.0, maxWidth - used);
    final total = basis.values.fold(0.0, (a, b) => a + b);
    if (total <= available) {
      final growers = flexible.where((e) => _grows(e.$1)).length;
      final extra = growers == 0 ? 0.0 : (available - total) / growers;
      for (final (slot, _) in flexible) {
        widths[slot] = basis[slot]! + (_grows(slot) ? extra : 0);
      }
      return widths;
    }

    var deficit = total - available;
    final current = Map<CdsCellSlot, double>.of(basis);
    void shrink(Iterable<CdsCellSlot> slots) {
      final weight = slots.fold(0.0, (a, s) => a + current[s]!);
      if (weight <= 0 || deficit <= 0) return;
      final take = math.min(deficit, weight);
      for (final s in slots) {
        current[s] = math.max(0.0, current[s]! - take * current[s]! / weight);
      }
      deficit -= take;
    }

    shrink([for (final (slot, _) in flexible) if (_shrinks(slot)) slot]);
    shrink([for (final (slot, _) in flexible) if (!_shrinks(slot)) slot]);
    widths.addAll(current);
    return widths;
  }

  double _crossOffset(double extent, double childExtent) => switch (_alignItems) {
        CrossAxisAlignment.start || CrossAxisAlignment.stretch || CrossAxisAlignment.baseline => 0,
        CrossAxisAlignment.end => extent - childExtent,
        CrossAxisAlignment.center => (extent - childExtent) / 2,
      };

  Size _run(BoxConstraints constraints, {required bool dry}) {
    final maxH = constraints.maxHeight;
    Size measure(RenderBox child, BoxConstraints c) => dry ? child.getDryLayout(c) : (child..layout(c, parentUsesSize: true)).size;

    final fixedSizes = <CdsCellSlot, Size>{};
    final widths = _widths(constraints.maxWidth, (slot, child) {
      final size = measure(child, BoxConstraints(maxWidth: constraints.maxWidth, maxHeight: maxH));
      fixedSizes[slot] = size;
      return size.width;
    });

    final present = _present;
    final sizes = <CdsCellSlot, Size>{};
    var height = 0.0;
    for (final (slot, child) in present) {
      final size = (fixedSizes[slot] != null && slot != CdsCellSlot.end)
          ? fixedSizes[slot]!
          : measure(child, BoxConstraints.tightFor(width: widths[slot]).enforce(BoxConstraints(maxHeight: maxH)));
      sizes[slot] = size;
      height = math.max(height, size.height);
    }
    final content = widths.values.fold(0.0, (a, b) => a + b) + (present.isEmpty ? 0 : _gap * (present.length - 1));
    final size = constraints.constrain(Size(constraints.maxWidth.isFinite ? constraints.maxWidth : content, height));
    if (dry) return size;

    final rtl = _textDirection == TextDirection.rtl;
    var x = 0.0;
    for (final (slot, child) in present) {
      final w = sizes[slot]!.width;
      final y = _crossOffset(size.height, sizes[slot]!.height);
      (child.parentData! as BoxParentData).offset = Offset(rtl ? size.width - x - w : x, y);
      x += widths[slot]! + _gap;
    }
    return size;
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! BoxParentData) child.parentData = BoxParentData();
  }

  @override
  void performLayout() {
    size = _run(constraints, dry: false);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _run(constraints, dry: true);

  @override
  double computeMinIntrinsicWidth(double height) {
    final present = _present;
    if (present.isEmpty) return 0;
    return present.fold(0.0, (a, e) => a + e.$2.getMinIntrinsicWidth(height)) + _gap * (present.length - 1);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final present = _present;
    if (present.isEmpty) return 0;
    return present.fold(0.0, (a, e) => a + e.$2.getMaxIntrinsicWidth(height)) + _gap * (present.length - 1);
  }

  double _intrinsicHeight(double width, double Function(RenderBox, double) measure) {
    final widths = _widths(width, (slot, child) => math.min(child.getMaxIntrinsicWidth(double.infinity), width));
    var height = 0.0;
    for (final (slot, child) in _present) {
      height = math.max(height, measure(child, widths[slot] ?? width));
    }
    return height;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width, (c, w) => c.getMinIntrinsicHeight(w));

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width, (c, w) => c.getMaxIntrinsicHeight(w));

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final main = childForSlot(CdsCellSlot.main);
    if (main == null) return null;
    final offset = (main.parentData! as BoxParentData).offset;
    final distance = main.getDistanceToActualBaseline(baseline);
    return distance == null ? null : distance + offset.dy;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final child in children) {
      context.paintChild(child, (child.parentData! as BoxParentData).offset + offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final child in children) {
      final parentData = child.parentData! as BoxParentData;
      final hit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (result, transformed) => child.hitTest(result, position: transformed),
      );
      if (hit) return true;
    }
    return false;
  }
}
