import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_typography.dart';
import 'cds_cartesian_chart.dart';
import 'internal/chart_internals.dart';

/// Where a [CdsPoint] label sits relative to the point.
enum CdsPointLabelPosition { top, bottom, left, right, center }

/// A circle marking one coordinate in data space, with an optional label.
/// Place it in a [CdsCartesianChart]'s `children`.
///
/// ```dart
/// const CdsPoint(dataX: 4, dataY: 98, label: 'High', labelPosition: CdsPointLabelPosition.top)
/// ```
class CdsPoint extends StatefulWidget {
  const CdsPoint({
    super.key,
    required this.dataX,
    required this.dataY,
    this.fill,
    this.dangerouslySetFill,
    this.radius = 5,
    this.stroke,
    this.strokeWidth = 2,
    this.opacity = 1,
    this.label,
    this.labelPosition = CdsPointLabelPosition.center,
    this.labelOffset,
    this.labelFont = CdsFont.label2,
    this.animate,
  });

  /// X coordinate in data space (the category index in vertical charts).
  final double dataX;

  /// Y coordinate in data space (the value in vertical charts).
  final double dataY;

  /// Fill color token. Defaults to `fgPrimary`.
  final CdsColor? fill;

  /// Raw fill color. Takes precedence over [fill].
  final Color? dangerouslySetFill;
  final double radius;

  /// Ring color around the point. Defaults to `bg`, so the point reads as cut
  /// out of the line beneath it.
  final CdsColor? stroke;

  /// Ring width. 0 removes the ring.
  final double strokeWidth;
  final double opacity;
  final String? label;
  final CdsPointLabelPosition labelPosition;

  /// Distance from the point to the label. Defaults to twice [radius].
  final double? labelOffset;
  final CdsFont labelFont;

  /// Overrides the chart's `animate` for this point.
  final bool? animate;

  @override
  State<CdsPoint> createState() => _CdsPointState();
}

class _CdsPointState extends State<CdsPoint> with SingleTickerProviderStateMixin {
  late final ChartValueAnimator<Offset> _animator = ChartValueAnimator(
    vsync: this,
    lerp: (a, b, t) => Offset.lerp(a, b, t)!,
  );

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = CdsCartesianChartScope.of(context);
    final target = Offset(data.xScale(widget.dataX), data.yScale(widget.dataY));
    _animator.sync(target, revision: data.revision, animate: widget.animate ?? data.animate);
    final theme = context.cds;
    return CustomPaint(
      painter: _PointPainter(
        point: widget,
        animator: _animator,
        data: data,
        theme: theme,
        textScaler: MediaQuery.textScalerOf(context),
        repaint: Listenable.merge([_animator.controller, data.enterProgress]),
      ),
    );
  }
}

class _PointPainter extends CustomPainter {
  _PointPainter({
    required this.point,
    required this.animator,
    required this.data,
    required this.theme,
    required this.textScaler,
    super.repaint,
  });

  final CdsPoint point;
  final ChartValueAnimator<Offset> animator;
  final CdsCartesianChartData data;
  final CdsThemeData theme;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    final c = animator.value;
    if (c == null || !c.dx.isFinite || !c.dy.isFinite) return;
    if (!data.drawingArea.inflate(0.5).contains(c)) return;
    // Accessories fade in after the line reveal, as CDS does (150ms after a 350ms delay).
    final enter = ((data.enterProgress.value - 0.7) / 0.3).clamp(0.0, 1.0);
    final opacity = point.opacity * enter;
    if (opacity <= 0) return;
    final fill = point.dangerouslySetFill ?? theme.colorOf(point.fill ?? CdsColor.fgPrimary);
    final ring = theme.colorOf(point.stroke ?? CdsColor.bg);
    if (point.strokeWidth > 0) {
      canvas.drawCircle(
        c,
        point.radius + point.strokeWidth / 2,
        Paint()..color = ring.withValues(alpha: ring.a * opacity),
      );
    }
    canvas.drawCircle(
      c,
      point.radius - (point.strokeWidth > 0 ? point.strokeWidth / 2 : 0),
      Paint()..color = fill.withValues(alpha: fill.a * opacity),
    );

    final label = point.label;
    if (label == null) return;
    final style = theme.textStyle(point.labelFont, color: CdsColor.fgMuted);
    final p = layoutChartText(label, style.copyWith(color: style.color!.withValues(alpha: opacity)), textScaler);
    final offset = point.labelOffset ?? point.radius * 2;
    final (anchor, align, baseline) = switch (point.labelPosition) {
      CdsPointLabelPosition.top => (c.translate(0, -offset), ChartTextAlign.center, ChartTextBaseline.bottom),
      CdsPointLabelPosition.bottom => (c.translate(0, offset), ChartTextAlign.center, ChartTextBaseline.top),
      CdsPointLabelPosition.left => (c.translate(-offset, 0), ChartTextAlign.right, ChartTextBaseline.middle),
      CdsPointLabelPosition.right => (c.translate(offset, 0), ChartTextAlign.left, ChartTextBaseline.middle),
      CdsPointLabelPosition.center => (c, ChartTextAlign.center, ChartTextBaseline.middle),
    };
    paintLaidOutText(canvas, p, anchor, align: align, baseline: baseline);
    p.dispose();
  }

  @override
  bool shouldRepaint(_PointPainter old) => true;
}
