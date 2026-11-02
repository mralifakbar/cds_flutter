import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_typography.dart';
import 'cds_cartesian_chart.dart';
import 'cds_chart_scale.dart';
import 'internal/axis_ticks.dart';
import 'internal/chart_internals.dart';

export 'internal/axis_ticks.dart' show CdsAxisBandPlacement;

/// Where [CdsXAxis] sits relative to the drawing area.
enum CdsXAxisPosition { top, bottom }

/// The horizontal axis of a [CdsCartesianChart]: tick labels, optional grid
/// lines, tick marks, axis line and title. Place it in the chart's `children`;
/// the chart reserves [reservedSize] pixels for it.
///
/// ```dart
/// CdsCartesianChart(
///   xAxis: const CdsAxisConfig(data: ['Jan', 'Feb', 'Mar']),
///   series: const [CdsChartSeries(id: 'a', data: [3, 5, 4])],
///   children: const [CdsXAxis(showGrid: true), CdsLine(seriesId: 'a')],
/// )
/// ```
class CdsXAxis extends StatelessWidget {
  const CdsXAxis({
    super.key,
    this.position = CdsXAxisPosition.bottom,
    this.showGrid = false,
    this.showLine = false,
    this.showTickMarks = false,
    this.tickMarkSize = 4,
    this.ticks,
    this.tickFilter,
    this.requestedTickCount,
    this.tickInterval = 32,
    this.tickMinStep = 1,
    this.tickMaxStep,
    this.tickLabelFormatter,
    this.tickMarkLabelGap = 2,
    this.minTickLabelGap = 4,
    this.label,
    this.height,
    this.bandGridLinePlacement = CdsAxisBandPlacement.edges,
    this.bandTickMarkPlacement = CdsAxisBandPlacement.middle,
  });

  static const double _axisHeight = 32;
  static const double _labelSize = 20;

  final CdsXAxisPosition position;

  /// Dotted grid lines across the drawing area at each tick.
  final bool showGrid;
  final bool showLine;
  final bool showTickMarks;
  final double tickMarkSize;

  /// Exact tick values (category indices for band scales). Overrides every
  /// other tick option.
  final List<double>? ticks;

  /// Keeps only ticks for which this returns true. For the category axis it is
  /// called with every index.
  final bool Function(double value)? tickFilter;

  /// Approximate tick count (d3 `ticks`). Defaults to 5 when this is the value
  /// axis of a horizontal chart. Overrides [tickInterval].
  final int? requestedTickCount;

  /// Approximate pixel spacing between ticks.
  final double tickInterval;
  final double tickMinStep;
  final double? tickMaxStep;

  /// Formats tick values. String category labels are used when null.
  final String Function(double value)? tickLabelFormatter;

  /// Gap between tick marks (or the axis edge) and labels.
  final double tickMarkLabelGap;

  /// Labels closer than this to a neighbor are hidden.
  final double minTickLabelGap;

  /// Axis title shown below (or above) the tick labels.
  final String? label;

  /// Height including padding. Defaults to 32, or 52 with a [label].
  final double? height;
  final CdsAxisBandPlacement bandGridLinePlacement;
  final CdsAxisBandPlacement bandTickMarkPlacement;

  /// Space the chart reserves for this axis.
  double get reservedSize => height ?? (label != null ? _axisHeight + _labelSize : _axisHeight);

  @override
  Widget build(BuildContext context) {
    final data = CdsCartesianChartScope.of(context);
    return CustomPaint(
      painter: _XAxisPainter(axis: this, data: data, theme: context.cds, textScaler: MediaQuery.textScalerOf(context)),
    );
  }
}

class _XAxisPainter extends CustomPainter {
  _XAxisPainter({required this.axis, required this.data, required this.theme, required this.textScaler});

  final CdsXAxis axis;
  final CdsCartesianChartData data;
  final CdsThemeData theme;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = data.xAxisRect;
    final area = data.drawingArea;
    if (rect == null || area.width <= 0) return;
    final scale = data.xScale;
    final categories = data.xAxis.data;
    final ticks = computeAxisTicks(
      scale: scale,
      categories: categories,
      ticks: axis.ticks,
      tickFilter: axis.tickFilter,
      requestedTickCount: axis.requestedTickCount ?? (data.isHorizontal ? 5 : null),
      tickInterval: axis.tickInterval,
      tickMinStep: axis.tickMinStep,
      tickMaxStep: axis.tickMaxStep,
    );
    final bottom = axis.position == CdsXAxisPosition.bottom;

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
      for (final x in linePositions(axis.bandGridLinePlacement)) {
        drawDottedPath(
          canvas,
          Path()
            ..moveTo(x, area.top)
            ..lineTo(x, area.bottom),
          paint,
        );
      }
    }
    final solid = Paint()
      ..color = theme.color.fg
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;
    if (axis.showTickMarks) {
      final y0 = bottom ? rect.top : rect.bottom;
      final y1 = bottom ? rect.top + axis.tickMarkSize : rect.bottom - axis.tickMarkSize;
      for (final x in linePositions(axis.bandTickMarkPlacement)) {
        canvas.drawLine(Offset(x, y0), Offset(x, y1), solid);
      }
    }
    if (axis.showLine) {
      final y = bottom ? rect.top : rect.bottom;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), solid);
    }

    final style = theme.textStyle(CdsFont.label2, color: CdsColor.fgMuted);
    final tickOffset = axis.tickMarkLabelGap + (axis.showTickMarks ? axis.tickMarkSize : 0);
    final labelOffset = (CdsXAxis._axisHeight - tickOffset) / 2;
    final labelY = bottom ? rect.top + labelOffset + tickOffset : rect.bottom - tickOffset - labelOffset;
    final painters = <TextPainter>[];
    final rects = <Rect>[];
    for (final t in ticks) {
      final p = layoutChartText(axisTickLabel(t.value, categories, axis.tickLabelFormatter), style, textScaler);
      // Keep edge labels inside the canvas instead of clipping them.
      final left = (t.position - p.width / 2).clamp(0.0, (size.width - p.width).clamp(0.0, double.infinity));
      painters.add(p);
      rects.add(Rect.fromLTWH(left, labelY - p.height / 2, p.width, p.height));
    }
    for (final i in visibleLabelIndices(rects, axis.minTickLabelGap, horizontal: true)) {
      painters[i].paint(canvas, rects[i].topLeft);
    }
    for (final p in painters) {
      p.dispose();
    }

    if (axis.label != null) {
      final p = layoutChartText(axis.label!, style, textScaler);
      final y = bottom ? rect.bottom - CdsXAxis._labelSize / 2 : rect.top + CdsXAxis._labelSize / 2;
      paintLaidOutText(canvas, p, Offset(rect.center.dx, y));
      p.dispose();
    }
  }

  @override
  bool shouldRepaint(_XAxisPainter old) =>
      old.axis != axis || !identical(old.data, data) || old.theme != theme || old.textScaler != textScaler;
}
