// Shared plumbing for anchored overlays (popover, dropdown, tooltip, context
// menu). Not exported from the overlays barrel.

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../theme/cds_motion.dart';
import 'cds_overlay.dart';

/// Returns the anchor rectangle in the coordinate space of [overlayBox].
typedef CdsAnchorRectResolver = Rect? Function(RenderBox overlayBox);

/// Resolves the rectangle of the widget that owns [context].
CdsAnchorRectResolver cdsAnchorOfContext(BuildContext context) {
  return (overlayBox) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return MatrixUtils.transformRect(box.getTransformTo(overlayBox), Offset.zero & box.size);
  };
}

enum CdsAnchorSide { top, bottom, left, right }

extension CdsPlacementParts on CdsPlacement {
  CdsAnchorSide get side => switch (this) {
        CdsPlacement.top || CdsPlacement.topStart || CdsPlacement.topEnd => CdsAnchorSide.top,
        CdsPlacement.bottom || CdsPlacement.bottomStart || CdsPlacement.bottomEnd => CdsAnchorSide.bottom,
        CdsPlacement.left || CdsPlacement.leftStart || CdsPlacement.leftEnd => CdsAnchorSide.left,
        CdsPlacement.right || CdsPlacement.rightStart || CdsPlacement.rightEnd => CdsAnchorSide.right,
      };

  /// -1 start, 0 center, 1 end.
  int get align => switch (this) {
        CdsPlacement.topStart ||
        CdsPlacement.bottomStart ||
        CdsPlacement.leftStart ||
        CdsPlacement.rightStart =>
          -1,
        CdsPlacement.topEnd || CdsPlacement.bottomEnd || CdsPlacement.leftEnd || CdsPlacement.rightEnd => 1,
        _ => 0,
      };
}

/// Positions its child next to an anchor rectangle, flips to the opposite
/// side when the preferred side does not fit, shrinks to the space available
/// and paints the enter/exit transition (fade, a short slide away from the
/// anchor and a slight scale from the edge facing the anchor).
class CdsAnchoredBox extends SingleChildRenderObjectWidget {
  const CdsAnchoredBox({
    super.key,
    required this.anchorRect,
    required this.placement,
    required this.gap,
    required this.margin,
    required this.animation,
    required this.textDirection,
    this.matchAnchorWidth = false,
    this.minWidth = 0,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.slide = 16,
    this.scaleFrom = 0.95,
    super.child,
  });

  /// Anchor in the coordinate space of the overlay this box fills. Measure it
  /// during build (with [CdsAnchorRectResolver]); render objects may not read
  /// other boxes' geometry during layout.
  final Rect? anchorRect;
  final CdsPlacement placement;
  final double gap;
  final EdgeInsets margin;
  final Animation<double> animation;
  final TextDirection textDirection;
  final bool matchAnchorWidth;
  final double minWidth;
  final double maxWidth;
  final double maxHeight;

  /// Distance in px the panel travels toward its resting place while entering.
  final double slide;

  /// Scale the panel starts from while entering.
  final double scaleFrom;

  @override
  RenderCdsAnchoredBox createRenderObject(BuildContext context) => RenderCdsAnchoredBox(
        anchorRect: anchorRect,
        placement: placement,
        gap: gap,
        margin: margin,
        animation: animation,
        textDirection: textDirection,
        matchAnchorWidth: matchAnchorWidth,
        minWidth: minWidth,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        slide: slide,
        scaleFrom: scaleFrom,
      );

  @override
  void updateRenderObject(BuildContext context, RenderCdsAnchoredBox renderObject) {
    renderObject
      ..anchorRect = anchorRect
      ..placement = placement
      ..gap = gap
      ..margin = margin
      ..animation = animation
      ..textDirection = textDirection
      ..matchAnchorWidth = matchAnchorWidth
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..maxHeight = maxHeight
      ..slide = slide
      ..scaleFrom = scaleFrom;
  }
}

class RenderCdsAnchoredBox extends RenderShiftedBox {
  RenderCdsAnchoredBox({
    required Rect? anchorRect,
    required CdsPlacement placement,
    required double gap,
    required EdgeInsets margin,
    required Animation<double> animation,
    required TextDirection textDirection,
    required bool matchAnchorWidth,
    required double minWidth,
    required double maxWidth,
    required double maxHeight,
    required double slide,
    required double scaleFrom,
  })  : _anchorInput = anchorRect,
        _placement = placement,
        _gap = gap,
        _margin = margin,
        _animation = animation,
        _textDirection = textDirection,
        _matchAnchorWidth = matchAnchorWidth,
        _minWidth = minWidth,
        _maxWidth = maxWidth,
        _maxHeight = maxHeight,
        _slide = slide,
        _scaleFrom = scaleFrom,
        super(null);

  Rect? _anchorInput;
  set anchorRect(Rect? v) {
    if (v == _anchorInput) return;
    _anchorInput = v;
    markNeedsLayout();
  }

  CdsPlacement _placement;
  set placement(CdsPlacement v) {
    if (v == _placement) return;
    _placement = v;
    markNeedsLayout();
  }

  double _gap;
  set gap(double v) {
    if (v == _gap) return;
    _gap = v;
    markNeedsLayout();
  }

  EdgeInsets _margin;
  set margin(EdgeInsets v) {
    if (v == _margin) return;
    _margin = v;
    markNeedsLayout();
  }

  Animation<double> _animation;
  set animation(Animation<double> v) {
    if (v == _animation) return;
    if (attached) _animation.removeListener(_onTick);
    _animation = v;
    if (attached) _animation.addListener(_onTick);
    markNeedsPaint();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  bool _matchAnchorWidth;
  set matchAnchorWidth(bool v) {
    if (v == _matchAnchorWidth) return;
    _matchAnchorWidth = v;
    markNeedsLayout();
  }

  double _minWidth;
  set minWidth(double v) {
    if (v == _minWidth) return;
    _minWidth = v;
    markNeedsLayout();
  }

  double _maxWidth;
  set maxWidth(double v) {
    if (v == _maxWidth) return;
    _maxWidth = v;
    markNeedsLayout();
  }

  double _maxHeight;
  set maxHeight(double v) {
    if (v == _maxHeight) return;
    _maxHeight = v;
    markNeedsLayout();
  }

  double _slide;
  set slide(double v) {
    if (v == _slide) return;
    _slide = v;
    markNeedsPaint();
  }

  double _scaleFrom;
  set scaleFrom(double v) {
    if (v == _scaleFrom) return;
    _scaleFrom = v;
    markNeedsPaint();
  }

  CdsAnchorSide _side = CdsAnchorSide.bottom;
  Rect _anchorRect = Rect.zero;

  /// The side the child ended up on after flipping.
  CdsAnchorSide get resolvedSide => _side;

  void _onTick() => markNeedsPaint();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(_onTick);
  }

  @override
  void detach() {
    _animation.removeListener(_onTick);
    super.detach();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) return;
    final bounds = _margin.deflateRect(Offset.zero & size);
    final anchor = _anchorInput ?? Rect.fromCenter(center: size.center(Offset.zero), width: 0, height: 0);
    _anchorRect = anchor;

    final preferred = _placement.side;
    final vertical = preferred == CdsAnchorSide.top || preferred == CdsAnchorSide.bottom;
    final spaceTop = anchor.top - bounds.top - _gap;
    final spaceBottom = bounds.bottom - anchor.bottom - _gap;
    final spaceLeft = anchor.left - bounds.left - _gap;
    final spaceRight = bounds.right - anchor.right - _gap;

    final widthCap = math.max(0.0, math.min(_maxWidth, bounds.width));
    final minW = math.min(_matchAnchorWidth ? math.max(_minWidth, anchor.width) : _minWidth, widthCap);
    final heightCap = math.max(0.0, math.min(_maxHeight, bounds.height));

    BoxConstraints constraintsFor(double maxW, double maxH) => BoxConstraints(
          minWidth: math.min(minW, maxW),
          maxWidth: math.max(0.0, maxW),
          maxHeight: math.max(0.0, maxH),
        );

    child.layout(constraintsFor(widthCap, heightCap), parentUsesSize: true);
    var childSize = child.size;

    var side = preferred;
    if (vertical) {
      final fitsPreferred = childSize.height <= (preferred == CdsAnchorSide.bottom ? spaceBottom : spaceTop);
      if (!fitsPreferred) {
        final opposite = preferred == CdsAnchorSide.bottom ? CdsAnchorSide.top : CdsAnchorSide.bottom;
        final oppositeSpace = opposite == CdsAnchorSide.bottom ? spaceBottom : spaceTop;
        final preferredSpace = preferred == CdsAnchorSide.bottom ? spaceBottom : spaceTop;
        if (childSize.height <= oppositeSpace || oppositeSpace > preferredSpace) side = opposite;
      }
      final available = side == CdsAnchorSide.bottom ? spaceBottom : spaceTop;
      if (childSize.height > available) {
        child.layout(constraintsFor(widthCap, math.min(heightCap, available)), parentUsesSize: true);
        childSize = child.size;
      }
    } else {
      final fitsPreferred = childSize.width <= (preferred == CdsAnchorSide.right ? spaceRight : spaceLeft);
      if (!fitsPreferred) {
        final opposite = preferred == CdsAnchorSide.right ? CdsAnchorSide.left : CdsAnchorSide.right;
        final oppositeSpace = opposite == CdsAnchorSide.right ? spaceRight : spaceLeft;
        final preferredSpace = preferred == CdsAnchorSide.right ? spaceRight : spaceLeft;
        if (childSize.width <= oppositeSpace || oppositeSpace > preferredSpace) side = opposite;
      }
      final available = side == CdsAnchorSide.right ? spaceRight : spaceLeft;
      if (childSize.width > available) {
        child.layout(constraintsFor(math.min(widthCap, math.max(0.0, available)), heightCap), parentUsesSize: true);
        childSize = child.size;
      }
    }
    _side = side;

    final align = _placement.align;
    double x;
    double y;
    if (side == CdsAnchorSide.top || side == CdsAnchorSide.bottom) {
      y = side == CdsAnchorSide.bottom ? anchor.bottom + _gap : anchor.top - _gap - childSize.height;
      final rtl = _textDirection == TextDirection.rtl;
      final startAligned = rtl ? anchor.right - childSize.width : anchor.left;
      final endAligned = rtl ? anchor.left : anchor.right - childSize.width;
      x = switch (align) {
        -1 => startAligned,
        1 => endAligned,
        _ => anchor.center.dx - childSize.width / 2,
      };
    } else {
      x = side == CdsAnchorSide.right ? anchor.right + _gap : anchor.left - _gap - childSize.width;
      y = switch (align) {
        -1 => anchor.top,
        1 => anchor.bottom - childSize.height,
        _ => anchor.center.dy - childSize.height / 2,
      };
    }
    x = x.clamp(bounds.left, math.max(bounds.left, bounds.right - childSize.width));
    y = y.clamp(bounds.top, math.max(bounds.top, bounds.bottom - childSize.height));
    (child.parentData! as BoxParentData).offset = Offset(x, y);
  }

  double get _t => _animation.value.clamp(0.0, 1.0);

  Matrix4 _transform() {
    final child = this.child!;
    final offset = (child.parentData! as BoxParentData).offset;
    final rect = offset & child.size;
    final t = _t;
    final distance = _slide * (1 - t);
    final scale = _scaleFrom + (1 - _scaleFrom) * t;
    Offset origin;
    Offset shift;
    final anchorX = _anchorRect.center.dx.clamp(rect.left, rect.right);
    final anchorY = _anchorRect.center.dy.clamp(rect.top, rect.bottom);
    switch (_side) {
      case CdsAnchorSide.bottom:
        origin = Offset(anchorX, rect.top);
        shift = Offset(0, -distance);
      case CdsAnchorSide.top:
        origin = Offset(anchorX, rect.bottom);
        shift = Offset(0, distance);
      case CdsAnchorSide.right:
        origin = Offset(rect.left, anchorY);
        shift = Offset(-distance, 0);
      case CdsAnchorSide.left:
        origin = Offset(rect.right, anchorY);
        shift = Offset(distance, 0);
    }
    return Matrix4.identity()
      ..translateByDouble(origin.dx + shift.dx, origin.dy + shift.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-origin.dx, -origin.dy, 0, 1);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    final t = _t;
    if (t <= 0) {
      layer = null;
      return;
    }
    final childOffset = (child.parentData! as BoxParentData).offset;
    void paintChild(PaintingContext c, Offset o) => c.paintChild(child, o + childOffset);
    if (t >= 1) {
      layer = null;
      paintChild(context, offset);
      return;
    }
    layer = context.pushOpacity(
      offset,
      (t * 255).round(),
      (c, o) => c.pushTransform(needsCompositing, o, _transform(), paintChild),
      oldLayer: layer is OpacityLayer ? layer as OpacityLayer : null,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null || _t <= 0) return false;
    final childOffset = (child.parentData! as BoxParentData).offset;
    return result.addWithPaintTransform(
      transform: _t >= 1 ? null : _transform(),
      position: position,
      hitTest: (result, transformed) => result.addWithPaintOffset(
        offset: childOffset,
        position: transformed,
        hitTest: (result, p) => child.hitTest(result, position: p),
      ),
    );
  }

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (_t > 0 && _t < 1) transform.multiply(_transform());
    super.applyPaintTransform(child, transform);
  }
}

/// Shows [panelBuilder] in the overlay next to [child] while [open] is true,
/// with CDS dropdown motion (opacity and a 16px slide, `moderate3` with the
/// global curve). The panel stays mounted until its exit finishes.
class CdsAnchoredPortal extends StatefulWidget {
  const CdsAnchoredPortal({
    super.key,
    required this.open,
    required this.child,
    required this.panelBuilder,
    this.placement = CdsPlacement.bottomStart,
    this.gap = 4,
    this.margin = const EdgeInsets.all(8),
    this.anchor,
    this.matchAnchorWidth = false,
    this.minWidth = 0,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.enterDuration = CdsDurations.moderate3,
    this.exitDuration = CdsDurations.moderate3,
    this.curve = CdsCurves.global,
    this.barrierBuilder,
    this.onExitComplete,
    this.tapRegionGroupId,
    this.useRootOverlay = false,
  });

  final bool open;
  final Widget child;
  final WidgetBuilder panelBuilder;
  final CdsPlacement placement;

  /// Distance between anchor and panel in px.
  final double gap;

  /// Space kept between the panel and the screen edges.
  final EdgeInsets margin;

  /// Anchor rectangle; defaults to the bounds of [child].
  final CdsAnchorRectResolver? anchor;
  final bool matchAnchorWidth;
  final double minWidth;
  final double maxWidth;
  final double maxHeight;
  final Duration enterDuration;
  final Duration exitDuration;
  final Curve curve;

  /// Optional full-screen layer under the panel (for example a scrim).
  final Widget Function(BuildContext context, Animation<double> animation)? barrierBuilder;
  final VoidCallback? onExitComplete;

  /// Taps inside widgets sharing this group do not count as "outside".
  final Object? tapRegionGroupId;
  final bool useRootOverlay;

  @override
  State<CdsAnchoredPortal> createState() => _CdsAnchoredPortalState();
}

class _CdsAnchoredPortalState extends State<CdsAnchoredPortal> with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  late final AnimationController _controller = AnimationController(vsync: this);
  late CurvedAnimation _curved = CurvedAnimation(parent: _controller, curve: widget.curve);

  @override
  void initState() {
    super.initState();
    // OverlayPortalController cannot be toggled during a build, so the portal
    // attaches once after the first frame and renders nothing while closed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(_portal.show);
      if (widget.open) _show();
    });
  }

  @override
  void didUpdateWidget(CdsAnchoredPortal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.curve != widget.curve) {
      _curved.dispose();
      _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    }
    if (widget.open != oldWidget.open && _portal.isShowing) {
      widget.open ? _show() : _hide();
    }
  }

  void _show() {
    _controller.duration = CdsMotion.reduceMotion(context) ? CdsDurations.fast1 : widget.enterDuration;
    _controller.forward();
  }

  void _hide() {
    _controller.reverseDuration = CdsMotion.reduceMotion(context) ? CdsDurations.fast1 : widget.exitDuration;
    _controller.reverse().whenCompleteOrCancel(() {
      if (!mounted || _controller.value > 0) return;
      setState(() {});
      widget.onExitComplete?.call();
    });
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOverlay(BuildContext context) {
    if (!widget.open && _controller.value == 0) return const SizedBox.shrink();
    final reduce = CdsMotion.reduceMotion(context);
    final overlayBox = Overlay.of(context).context.findRenderObject();
    final resolver = widget.anchor ?? cdsAnchorOfContext(this.context);
    final anchorRect = overlayBox is RenderBox && overlayBox.hasSize ? resolver(overlayBox) : null;
    Widget panel = CdsAnchoredBox(
      anchorRect: anchorRect,
      placement: widget.placement,
      gap: widget.gap,
      margin: widget.margin + MediaQuery.paddingOf(context),
      animation: _curved,
      textDirection: Directionality.of(context),
      matchAnchorWidth: widget.matchAnchorWidth,
      minWidth: widget.minWidth,
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
      slide: reduce ? 0 : 16,
      scaleFrom: reduce ? 1 : 0.95,
      child: widget.tapRegionGroupId == null
          ? widget.panelBuilder(context)
          : TapRegion(groupId: widget.tapRegionGroupId, child: widget.panelBuilder(context)),
    );
    panel = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => IgnorePointer(ignoring: !widget.open, child: child),
      child: panel,
    );
    if (widget.barrierBuilder != null) {
      panel = Stack(fit: StackFit.expand, children: [widget.barrierBuilder!(context, _curved), panel]);
    }
    return panel;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    if (widget.tapRegionGroupId != null) child = TapRegion(groupId: widget.tapRegionGroupId, child: child);
    return OverlayPortal(
      controller: _portal,
      overlayLocation: widget.useRootOverlay ? OverlayChildLocation.rootOverlay : OverlayChildLocation.nearestOverlay,
      overlayChildBuilder: _buildOverlay,
      child: child,
    );
  }
}

/// Returns [action] stretched to the full width. CDS clones `block` onto the
/// buttons it lays out in groups; this does the same for [CdsButton] and
/// leaves other widgets alone.
Widget cdsBlockAction(Widget action) {
  if (action is! CdsButton || action.block) return action;
  return CdsButton(
    key: action.key,
    label: action.label,
    onPress: action.onPress,
    onLongPress: action.onLongPress,
    variant: action.variant,
    size: action.size,
    disabled: action.disabled,
    loading: action.loading,
    transparent: action.transparent,
    block: true,
    startIcon: action.startIcon,
    startIconActive: action.startIconActive,
    endIcon: action.endIcon,
    endIconActive: action.endIconActive,
    start: action.start,
    end: action.end,
    flush: action.flush,
    noScaleOnPress: action.noScaleOnPress,
    maxLines: action.maxLines,
    feedback: action.feedback,
    semanticLabel: action.semanticLabel,
    semanticHint: action.semanticHint,
    focusNode: action.focusNode,
    autofocus: action.autofocus,
  );
}
