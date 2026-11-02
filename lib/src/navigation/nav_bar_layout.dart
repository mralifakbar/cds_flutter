import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_motion.dart';

// Layout helpers shared by CdsTopNavBar and CdsNavigationBar. Not exported.

/// Keeps the last child on screen while a slot collapses, so adding or
/// removing a start or end action shrinks it smoothly instead of popping.
class CollapsingSlot extends StatefulWidget {
  const CollapsingSlot({super.key, this.child, this.paddingStart = 0, this.paddingEnd = 0});

  final Widget? child;

  /// Pixels added on the start side while the slot has content.
  final double paddingStart;

  /// Pixels added on the end side while the slot has content.
  final double paddingEnd;

  @override
  State<CollapsingSlot> createState() => _CollapsingSlotState();
}

class _CollapsingSlotState extends State<CollapsingSlot> with SingleTickerProviderStateMixin {
  late Widget? _last = widget.child;
  late final AnimationController _size;

  @override
  void initState() {
    super.initState();
    _size = AnimationController(vsync: this, duration: CdsDurations.fast1, value: widget.child == null ? 0 : 1)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && widget.child == null && mounted) setState(() => _last = null);
      });
  }

  @override
  void didUpdateWidget(CollapsingSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != null) _last = widget.child;
    final visible = widget.child != null;
    if (visible == (oldWidget.child != null)) return;
    if (CdsMotion.reduceMotion(context)) {
      _size.value = visible ? 1 : 0;
      if (!visible) _last = null;
    } else if (visible) {
      _size.forward();
    } else {
      _size.reverse();
    }
  }

  @override
  void dispose() {
    _size.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = _last;
    if (content == null) return const SizedBox.shrink();
    final visible = widget.child != null;
    final curve = CurvedAnimation(parent: _size, curve: CdsCurves.global);
    return ExcludeFocus(
      excluding: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: curve,
            builder: (context, child) => Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: curve.value,
              child: Opacity(opacity: curve.value, child: child),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: widget.paddingStart, end: widget.paddingEnd),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays out start, middle and end so the middle stays centered on the bar.
/// Start and end take their natural width; the middle gets the width left
/// after reserving the wider side on both sides, and is centered.
class CenteredBarRow extends MultiChildRenderObjectWidget {
  CenteredBarRow({super.key, required Widget start, required Widget middle, required Widget end, this.gap = 0})
      : super(children: [start, middle, end]);

  /// Space in pixels between the middle and a non-empty side slot.
  final double gap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderCenteredBarRow(gap: gap, textDirection: Directionality.of(context));

  @override
  void updateRenderObject(BuildContext context, RenderCenteredBarRow renderObject) {
    renderObject
      ..gap = gap
      ..textDirection = Directionality.of(context);
  }
}

class _BarParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCenteredBarRow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _BarParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _BarParentData> {
  RenderCenteredBarRow({required double gap, required TextDirection textDirection})
      : _gap = gap,
        _textDirection = textDirection;

  double _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _BarParentData) child.parentData = _BarParentData();
  }

  List<RenderBox> get _kids => getChildrenAsList();

  ({Size size, List<Size> sizes}) _compute(BoxConstraints constraints, Size Function(RenderBox, BoxConstraints) layoutChild) {
    final kids = _kids;
    final start = kids[0], middle = kids[1], end = kids[2];
    final maxWidth = constraints.maxWidth;
    final loose = BoxConstraints(maxHeight: constraints.maxHeight);
    final bounded = maxWidth.isFinite;
    final startSize = layoutChild(start, bounded ? loose.copyWith(maxWidth: maxWidth) : loose);
    final endSize = layoutChild(end, bounded ? loose.copyWith(maxWidth: math.max(0, maxWidth - startSize.width)) : loose);
    final side = math.max(startSize.width, endSize.width);
    final sideGap = side > 0 ? _gap : 0.0;
    final middleMax = bounded ? math.max(0.0, maxWidth - 2 * (side + sideGap)) : double.infinity;
    final middleSize = layoutChild(middle, loose.copyWith(maxWidth: middleMax));
    final width = bounded ? maxWidth : startSize.width + endSize.width + middleSize.width + 2 * (side + sideGap);
    final height = [startSize.height, middleSize.height, endSize.height].reduce(math.max);
    return (size: constraints.constrain(Size(width, height)), sizes: [startSize, middleSize, endSize]);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      _compute(constraints, (child, c) => child.getDryLayout(c)).size;

  @override
  void performLayout() {
    final result = _compute(constraints, (child, c) {
      child.layout(c, parentUsesSize: true);
      return child.size;
    });
    size = result.size;
    final kids = _kids;
    final rtl = _textDirection == TextDirection.rtl;
    double centerY(Size s) => (size.height - s.height) / 2;
    final startSize = result.sizes[0], middleSize = result.sizes[1], endSize = result.sizes[2];
    (kids[0].parentData! as _BarParentData).offset =
        Offset(rtl ? size.width - startSize.width : 0, centerY(startSize));
    (kids[1].parentData! as _BarParentData).offset =
        Offset((size.width - middleSize.width) / 2, centerY(middleSize));
    (kids[2].parentData! as _BarParentData).offset =
        Offset(rtl ? 0 : size.width - endSize.width, centerY(endSize));
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _kids.fold(0.0, (sum, child) => sum + child.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) {
    final kids = _kids;
    final side = math.max(kids[0].getMaxIntrinsicWidth(height), kids[2].getMaxIntrinsicWidth(height));
    return kids[1].getMaxIntrinsicWidth(height) + 2 * (side + (side > 0 ? _gap : 0));
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _kids.fold(0.0, (h, child) => math.max(h, child.getMinIntrinsicHeight(width)));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _kids.fold(0.0, (h, child) => math.max(h, child.getMaxIntrinsicHeight(width)));

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);
}
