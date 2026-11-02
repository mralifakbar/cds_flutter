import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import 'tab_list.dart';

/// The 2px bar that marks the active tab. It fills its parent's width and
/// draws the bar at [x] with [width]; when either changes, the bar springs
/// there from its current position (no jump if it was already moving).
///
/// [CdsTabs] and [CdsTabNavigation] place it for you. Use it directly when you
/// build your own tab row:
///
/// ```dart
/// CdsTabIndicator(x: activeRect.left, width: activeRect.width)
/// ```
///
/// The first frame and reduced motion place the bar without animating.
class CdsTabIndicator extends StatefulWidget {
  const CdsTabIndicator({
    super.key,
    required this.x,
    required this.width,
    this.background = CdsColor.bgPrimary,
    this.animate = true,
  });

  /// Distance of the bar from the parent's left edge, in logical pixels.
  final double x;

  /// Bar width in logical pixels. Zero hides the bar.
  final double width;

  /// Bar color.
  final CdsColor background;

  /// False jumps straight to [x] and [width], e.g. while tracking a drag.
  final bool animate;

  @override
  State<CdsTabIndicator> createState() => _CdsTabIndicatorState();
}

class _CdsTabIndicatorState extends State<CdsTabIndicator> with TickerProviderStateMixin, SpanSpring {
  @override
  void initState() {
    super.initState();
    moveSpan(widget.x, widget.width, animate: false);
  }

  @override
  void didUpdateWidget(CdsTabIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.x != widget.x || oldWidget.width != widget.width || !widget.animate) {
      moveSpan(widget.x, widget.width, animate: widget.animate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final color = theme.colorOf(widget.background);
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: span,
        builder: (context, _) => CustomPaint(
          painter: _BarPainter(x: spanX.value, width: spanWidth.value, color: color),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter({required this.x, required this.width, required this.color});

  final double x;
  final double width;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (width <= 0) return;
    canvas.drawRect(Rect.fromLTWH(x, 0, width, size.height), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.x != x || old.width != width || old.color != color;
}
