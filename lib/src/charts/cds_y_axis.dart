import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_typography.dart';
import 'cds_cartesian_chart.dart';
import 'cds_chart_scale.dart';
import 'internal/axis_ticks.dart';
import 'internal/chart_internals.dart';

/// Where [CdsYAxis] sits relative to the drawing area.
enum CdsYAxisPosition { left, right }

/// The vertical axis of a [CdsCartesianChart]: tick labels, optional grid
/// lines, tick marks, axis line and title. Place it in the chart's `children`;
/// the chart reserves [reservedSize] pixels for it.
///
/// ```dart
/// CdsCartesianChart(
///   series: const [CdsChartSeries(id: 'a', data: [3, 5, 4])],
///   children: [
///     CdsYAxis(showGrid: true, tickLabelFormatter: (v) => '\$${v.toInt()}'),
///     const CdsLine(seriesId: 'a'),
///   ],
/// )
/// ```
class CdsYAxis extends StatelessWidget {
  const CdsYAxis({
    super.key,
    this.position = CdsYAxisPosition.right,
    this.showGrid = false,
    this.showLine = false,
    this.showTickMarks = false,
    this.tickMarkSize = 4,
    this.ticks,
    this.tickFilter,
    this.requestedTickCount,
    this.tickInterval,
    this.tickMinStep = 1,
    this.tickMaxStep,
    this.tickLabelFormatter,
    this.tickMarkLabelGap = 8,
    this.minTickLabelGap = 0,
    this.label,
    this.width,
    this.bandGridLinePlacement = CdsAxisBandPlacement.edges,
    this.bandTickMarkPlacement = CdsAxisBandPlacement.middle,
  });

  static const double _axisWidth = 44;
  static const double _labelSize = 20;

  final CdsYAxisPosition position;

  /// Dotted grid lines across the drawing area at each tick.
  final bool showGrid;
  final bool showLine;
  final bool showTickMarks;
  final double tickMarkSize;

  /// Exact tick values (category indices for band scales). Overrides every
  /// other tick option.
  final List<double>? ticks;

  /// Keeps only ticks for which this returns true.
  final bool Function(double value)? tickFilter;

  /// Approximate tick count (d3 `ticks`). Defaults to 5 when this is the value
  /// axis (vertical charts).
  final int? requestedTickCount;

  /// Approximate pixel spacing between ticks, used when no count is requested.
  final double? tickInterval;
  final double tickMinStep;
  final double? tickMaxStep;

  /// Formats tick values. String category labels are used when null.
  final String Function(double value)? tickLabelFormatter;

  /// Gap between tick marks (or the axis edge) and labels.
  final double tickMarkLabelGap;

  /// Labels closer than this to a neighbor are hidden.
  final double minTickLabelGap;

  /// Axis title, drawn rotated along the outer edge.
  final String? label;

  /// Width including padding. Defaults to 44, or 64 with a [label].
  final double? width;
  final CdsAxisBandPlacement bandGridLinePlacement;
  final CdsAxisBandPlacement bandTickMarkPlacement;

  /// Space the chart reserves for this axis.
  double get reservedSize => width ?? (label != null ? _axisWidth + _labelSize : _axisWidth);

  @override
  Widget build(BuildContext context) {
    final data = CdsCartesianChartScope.of(context);
    return CustomPaint(
      painter: _YAxisPainter(axis: this, data: data, theme: context.cds, textScaler: MediaQuery.textScalerOf(context)),
    );
  }
}

class _YAxisPainter extends CustomPainter {
  _YAxisPainter({required this.axis, required this.data, required this.theme, required this.textScaler});

  final CdsYAxis axis;
  final CdsCartesianChartData data;
  final CdsThemeData theme;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = data.yAxisRect;
    final area = data.drawingArea;
    if (rect == null || area.height <= 0) return;
    final scale = data.yScale;
    final categories = data.yAxis.data;
    final isValueAxis = !data.isHorizontal;
    final ticks = computeAxisTicks(
      scale: scale,
      categories: categories,
      ticks: axis.ticks,
      tickFilter: axis.tickFilter,
      requestedTickCount: axis.requestedTickCount ?? (isValueAxis && axis.tickInterval == null ? 5 : null),
      tickInterval: axis.tickInterval,
      tickMinStep: axis.tickMinStep,
      tickMaxStep: axis.tickMaxStep,
    );
    final left = axis.position == CdsYAxisPosition.left;

    List<double> linePositions(CdsAxisBandPlacement placement) {
      if (scale is! CdsBandScale) return [for (final t in ticks) t.position];
      final out = <double>[];
      for (var i = 0; i < ticks.length; i++) {
        final index = ticks[i].value.round();
        out.add(scale.anchorOf(index, bandAnchor(placement)));
        if (i == ticks.length - 1 && placement == CdsAxisBandPlacement.edges) {
          out.add(scale.anchorOf(index, CdsPointAnchor.stepEnd));
        }
      }
      return out;
    }

    if (axis.showGrid) {
      final paint = Paint()
        ..color = theme.color.bgLine
        ..strokeWidth = 2;
      for (final y in linePositions(axis.bandGridLinePlacement)) {
        drawDottedPath(
          canvas,
          Path()
            ..moveTo(area.left, y)
            ..lineTo(area.right, y),
          paint,
        );
      }
    }
    final solid = Paint()
      ..color = theme.color.fg
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;
    final edge = left ? rect.right : rect.left;
    if (axis.showTickMarks) {
      final x1 = left ? edge - axis.tickMarkSize : edge + axis.tickMarkSize;
      for (final y in linePositions(axis.bandTickMarkPlacement)) {
        canvas.drawLine(Offset(edge, y), Offset(x1, y), solid);
      }
    }
    if (axis.showLine) canvas.drawLine(Offset(edge, rect.top), Offset(edge, rect.bottom), solid);

    final style = theme.textStyle(CdsFont.label2, color: CdsColor.fgMuted);
    final tickOffset = axis.tickMarkLabelGap + (axis.showTickMarks ? axis.tickMarkSize : 0);
    final painters = <TextPainter>[];
    final rects = <Rect>[];
    for (final t in ticks) {
      final p = layoutChartText(axisTickLabel(t.value, categories, axis.tickLabelFormatter), style, textScaler);
      final x = left ? edge - tickOffset - p.width : edge + tickOffset;
      final maxTop = math.max(0.0, size.height - p.height);
      final top = (t.position - p.height / 2).clamp(0.0, maxTop);
      painters.add(p);
      rects.add(Rect.fromLTWH(x, top, p.width, p.height));
    }
    for (final i in visibleLabelIndices(rects, axis.minTickLabelGap, horizontal: false)) {
      painters[i].paint(canvas, rects[i].topLeft);
    }
    for (final p in painters) {
      p.dispose();
    }

    if (axis.label != null) {
      final p = layoutChartText(axis.label!, style, textScaler);
      final x = left ? rect.left + CdsYAxis._labelSize / 2 : rect.right - CdsYAxis._labelSize / 2;
      canvas.save();
      canvas.translate(x, rect.center.dy);
      canvas.rotate(left ? -math.pi / 2 : math.pi / 2);
      paintLaidOutText(canvas, p, Offset.zero);
      canvas.restore();
      p.dispose();
    }
  }

  @override
  bool shouldRepaint(_YAxisPainter old) =>
      old.axis != axis || !identical(old.data, data) || old.theme != theme || old.textScaler != textScaler;
}
