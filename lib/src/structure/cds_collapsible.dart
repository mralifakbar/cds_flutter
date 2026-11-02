import 'package:flutter/widgets.dart';

import '../layout/cds_box.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';

/// Shows or hides content by animating its size and opacity.
///
/// The animation runs on one controller, so flipping [collapsed] mid-flight
/// reverses from the current size instead of restarting. Content that starts
/// expanded appears without animating. Under reduced motion the change is
/// instant. While collapsed, the content is hidden from screen readers and
/// skipped by keyboard focus.
///
/// ```dart
/// CdsCollapsible(
///   collapsed: !showDetails,
///   paddingX: 3,
///   child: const CdsText('Network fees vary with demand.'),
/// )
/// ```
class CdsCollapsible extends StatefulWidget {
  const CdsCollapsible({
    super.key,
    required this.collapsed,
    required this.child,
    this.direction = Axis.vertical,
    this.maxHeight,
    this.maxWidth,
    this.padding,
    this.paddingX,
    this.paddingY,
    this.paddingTop,
    this.paddingBottom,
    this.paddingStart,
    this.paddingEnd,
  });

  /// Hides the content when true.
  final bool collapsed;
  final Widget child;

  /// Axis the content grows along. [Axis.horizontal] animates width.
  final Axis direction;

  /// Caps the expanded height in logical px; taller content scrolls.
  /// Applies to [Axis.vertical].
  final double? maxHeight;

  /// Caps the expanded width in logical px; wider content scrolls.
  /// Applies to [Axis.horizontal].
  final double? maxWidth;

  /// Space tokens around the content (1 = 8px).
  final double? padding, paddingX, paddingY, paddingTop, paddingBottom, paddingStart, paddingEnd;

  @override
  State<CdsCollapsible> createState() => _CdsCollapsibleState();
}

class _CdsCollapsibleState extends State<CdsCollapsible> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, value: widget.collapsed ? 0 : 1);
  late CurvedAnimation _size;
  late CurvedAnimation _opacity;

  @override
  void initState() {
    super.initState();
    _buildCurves();
  }

  // Vertical: size and opacity together (in slow1, out moderate3, global).
  // Horizontal: width first, then fade in; on the way out fade first, then
  // shrink, matching CDS's delayed horizontal specs.
  void _buildCurves() {
    if (widget.direction == Axis.vertical) {
      _size = CurvedAnimation(parent: _controller, curve: CdsCurves.global);
      _opacity = CurvedAnimation(parent: _controller, curve: CdsCurves.global);
    } else {
      _size = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5, curve: CdsCurves.global));
      _opacity = CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1, curve: CdsCurves.exitFunctional));
    }
  }

  void _syncDurations() {
    if (widget.direction == Axis.vertical) {
      _controller.duration = CdsMotion.duration(context, CdsDurations.slow1);
      _controller.reverseDuration = CdsMotion.duration(context, CdsDurations.moderate3);
    } else {
      final d = CdsMotion.duration(context, CdsDurations.fast1 * 2);
      _controller.duration = d;
      _controller.reverseDuration = d;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDurations();
  }

  @override
  void didUpdateWidget(CdsCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.direction != widget.direction) {
      _size.dispose();
      _opacity.dispose();
      _buildCurves();
    }
    _syncDurations();
    if (oldWidget.collapsed != widget.collapsed) {
      if (widget.collapsed) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _size.dispose();
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final vertical = widget.direction == Axis.vertical;
    Widget content = Padding(
      padding: cdsInsets(theme,
          all: widget.padding,
          x: widget.paddingX,
          y: widget.paddingY,
          top: widget.paddingTop,
          bottom: widget.paddingBottom,
          start: widget.paddingStart,
          end: widget.paddingEnd),
      child: widget.child,
    );
    final cap = vertical ? widget.maxHeight : widget.maxWidth;
    if (cap != null) {
      content = ConstrainedBox(
        constraints: vertical ? BoxConstraints(maxHeight: cap) : BoxConstraints(maxWidth: cap),
        child: SingleChildScrollView(
          scrollDirection: widget.direction,
          primary: false,
          child: content,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      child: content,
      builder: (context, child) {
        final hidden = _controller.isDismissed;
        return ExcludeFocus(
          excluding: widget.collapsed,
          child: ExcludeSemantics(
            excluding: widget.collapsed,
            child: ClipRect(
              child: Align(
                alignment: vertical ? AlignmentDirectional.topStart : AlignmentDirectional.centerStart,
                heightFactor: vertical ? _size.value : 1,
                widthFactor: vertical ? null : _size.value,
                child: Opacity(
                  opacity: _opacity.value.clamp(0.0, 1.0),
                  // Fully collapsed content stops painting and hit testing.
                  child: Offstage(offstage: hidden, child: child),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
