import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../cds_chart_path.dart';
import 'chart_internals.dart';

/// Stroke style for [CdsSparkline].
enum CdsSparklineStrokeType { solid, gradient }

/// Area fill style for [CdsSparkline].
enum CdsSparklineFillType { dotted, gradient, gradientDotted }

/// Sparkline coordinate math, ported from CDS `getSparklineRange` and
/// `getSparklineTransform`.
abstract final class SparklineGeometry {
  /// Pixel y range `[bottom, top]` for a sparkline of [height].
  static (double, double) yRange(double height, double? yAxisScalingFactor) =>
      (math.max(3, (height - 2) * (yAxisScalingFactor ?? 1)), 2);

  /// Vertical offset that centers a scaled path. Zero when no factor is set.
  static double yTranslate(double height, double? yAxisScalingFactor) {
    if (yAxisScalingFactor == null || !yAxisScalingFactor.isFinite) return 0;
    final (bottom, top) = yRange(height, yAxisScalingFactor);
    return height / 2 - (bottom - top).abs() / 2;
  }

  /// Points for a static sparkline: LTTB-downsampled to one point per 3px,
  /// spread over `[0, n]` like CDS (so the last point stops short of the edge).
  static List<ui.Offset> indexPoints(List<double> data, ui.Size size, double? yAxisScalingFactor) {
    final finite = [
      for (final v in data)
        if (v.isFinite) v,
    ];
    if (finite.isEmpty || size.width <= 0 || size.height <= 0) return const [];
    final sampled = CdsChartPath.largestTriangleThreeBucket(finite, size.width / 3);
    final n = sampled.length;
    final lo = sampled.reduce(math.min), hi = sampled.reduce(math.max);
    final (yBottom, yTop) = yRange(size.height, yAxisScalingFactor);
    final x0 = 2.0, x1 = size.width - 2;
    return [
      for (var i = 0; i < n; i++)
        ui.Offset(
          x0 + (i / n) * (x1 - x0),
          hi == lo ? (yBottom + yTop) / 2 : yBottom + (sampled[i] - lo) / (hi - lo) * (yTop - yBottom),
        ),
    ];
  }
}

/// Paints a sparkline line and optional area fill.
class SparklinePainter extends CustomPainter {
  SparklinePainter({
    required this.points,
    required this.color,
    required this.isDark,
    this.strokeType = CdsSparklineStrokeType.solid,
    this.fillType = CdsSparklineFillType.dotted,
    this.fill = false,
    this.curve = CdsChartCurve.basis,
    this.yAxisScalingFactor,
    this.strokeWidth = 2,
    super.repaint,
  });

  final SparklinePointsGetter points;
  final ui.Color color;
  final bool isDark;
  final CdsSparklineStrokeType strokeType;
  final CdsSparklineFillType fillType;
  final bool fill;
  final CdsChartCurve curve;
  final double? yAxisScalingFactor;
  final double strokeWidth;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final pts = points();
    if (pts == null || pts.isEmpty) return;
    final dy = SparklineGeometry.yTranslate(size.height, yAxisScalingFactor);
    canvas.save();
    canvas.translate(0, dy);
    final line = CdsChartPath.line(pts, curve: curve);
    if (fill) _paintFill(canvas, size, pts, dy);
    final paint = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..color = color;
    // CDS disables the darkening stroke gradient in dark mode.
    if (strokeType == CdsSparklineStrokeType.gradient && !isDark) {
      paint.shader = ui.Gradient.linear(ui.Offset.zero, ui.Offset(size.width, 0), [color, darkerColor(color)]);
    }
    canvas.drawPath(line, paint);
    canvas.restore();
  }

  void _paintFill(ui.Canvas canvas, ui.Size size, List<ui.Offset?> pts, double dy) {
    final bottom = [for (final p in pts) p == null ? null : ui.Offset(p.dx, size.height)];
    final area = CdsChartPath.area(pts, bottom, curve: curve);
    final y1 = yAxisScalingFactor == null ? 2.0 : SparklineGeometry.yRange(size.height, yAxisScalingFactor).$2;
    final y2 = yAxisScalingFactor == null ? size.height - 2 : size.height - dy;
    switch (fillType) {
      case CdsSparklineFillType.gradient:
        canvas.drawPath(
          area,
          ui.Paint()
            ..shader = ui.Gradient.linear(ui.Offset(0, y1), ui.Offset(0, y2), [
              color.withValues(alpha: color.a * 0.3),
              color.withValues(alpha: 0),
            ]),
        );
      case CdsSparklineFillType.dotted:
        _dots(canvas, area, ui.Paint()..color = color.withValues(alpha: color.a * (isDark ? 0.4 : 0.2)));
      case CdsSparklineFillType.gradientDotted:
        _dots(
          canvas,
          area,
          ui.Paint()
            ..shader = ui.Gradient.linear(ui.Offset(0, y1), ui.Offset(0, y2), [color, color.withValues(alpha: 0)]),
        );
    }
  }

  /// SVG-style dot pattern: 4px cells, a 1px-radius dot at (1, 1) in each.
  void _dots(ui.Canvas canvas, ui.Path area, ui.Paint paint) {
    final bounds = area.getBounds();
    if (bounds.isEmpty) return;
    canvas.save();
    canvas.clipPath(area);
    final dots = <ui.Offset>[
      for (var x = (bounds.left / 4).floor() * 4.0 + 1; x <= bounds.right; x += 4)
        for (var y = (bounds.top / 4).floor() * 4.0 + 1; y <= bounds.bottom; y += 4) ui.Offset(x, y),
    ];
    canvas.drawPoints(
      ui.PointMode.points,
      dots,
      paint
        ..strokeWidth = 2
        ..strokeCap = ui.StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(SparklinePainter old) => true;
}

/// Returns the points to paint this frame.
typedef SparklinePointsGetter = List<ui.Offset?>? Function();
