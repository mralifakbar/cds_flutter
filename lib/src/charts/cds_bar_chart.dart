import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';
import 'cds_cartesian_chart.dart';
import 'cds_chart_scale.dart';
import 'cds_chart_types.dart';
import 'cds_x_axis.dart';
import 'cds_y_axis.dart';
import 'internal/chart_internals.dart';

/// Geometry of one bar: its rect and which ends get rounded corners.
@immutable
class CdsBarGeometry {
  const CdsBarGeometry({
    required this.seriesId,
    required this.index,
    required this.rect,
    required this.roundLow,
    required this.roundHigh,
    required this.positive,
  });

  final String seriesId;
  final int index;
  final Rect rect;

  /// Round the end nearest the baseline.
  final bool roundLow;

  /// Round the end farthest from the baseline.
  final bool roundHigh;

  /// The bar grows up (vertical) or right (horizontal) from its baseline.
  final bool positive;
}

/// Lays out bars for every series in [data], grouping series that share a
/// stack id. Exposed for custom bar painters and tests.
List<CdsBarGeometry> cdsBarLayout(
  CdsCartesianChartData data, {
  List<String>? seriesIds,
  double barPadding = 0.1,
  double stackGap = 0,
  double barMinSize = 0,
  bool roundBaseline = false,
}) {
  final out = <CdsBarGeometry>[];
  if (data.dataLength == 0 || data.drawingArea.isEmpty) return out;
  final horizontal = data.isHorizontal;
  final scale = data.categoryScale;
  final band = scale is CdsBandScale
      ? scale
      : CdsBandScale(count: data.dataLength, range: scale.range, padding: data.categoryAxis.categoryPadding ?? 0.3);
  final series = [
    for (final s in data.series)
      if (seriesIds == null || seriesIds.contains(s.id)) s,
  ];

  final groups = <String, List<CdsChartSeries>>{};
  for (final s in series) {
    groups.putIfAbsent(s.stackId ?? '__${s.id}', () => []).add(s);
  }
  final totalStacks = groups.length;
  if (totalStacks == 0) return out;
  final gap = totalStacks > 1 ? band.bandwidth * barPadding / (totalStacks - 1) : 0.0;
  final adjustment = totalStacks > 1 ? gap * (totalStacks - 1) / totalStacks : 0.0;
  final thickness = math.max(0.0, band.bandwidth / totalStacks - adjustment);
  final baselinePx = data.baselinePixel;
  final valueScale = data.valueScale;

  var stackIndex = 0;
  for (final group in groups.values) {
    for (var i = 0; i < data.dataLength; i++) {
      final indexPos = band.bandStart(i) + stackIndex * (thickness + gap);
      final bars = <({String id, double lo, double hi, bool positive})>[];
      for (final s in group) {
        final values = data.stacked[s.id];
        final p = values == null || i >= values.length ? null : values[i];
        if (p == null) continue;
        final a = valueScale(p.$1), b = valueScale(p.$2);
        if (!a.isFinite || !b.isFinite) continue;
        final positive = p.$2 >= p.$1;
        var lo = math.min(a, b), hi = math.max(a, b);
        if (hi - lo < barMinSize) {
          // Grow away from the baseline so tiny values stay visible.
          final growUp = horizontal ? positive : !positive;
          if (growUp) {
            hi = lo + barMinSize;
          } else {
            lo = hi - barMinSize;
          }
        }
        if (hi - lo <= 0) continue;
        bars.add((id: s.id, lo: lo, hi: hi, positive: positive));
      }
      if (bars.isEmpty) continue;
      bars.sort((x, y) => x.lo.compareTo(y.lo));
      final stacked = bars.length > 1;
      for (var k = 0; k < bars.length; k++) {
        var lo = bars[k].lo, hi = bars[k].hi;
        if (stackGap > 0 && stacked) {
          if (k > 0) lo += stackGap / 2;
          if (k < bars.length - 1) hi -= stackGap / 2;
          if (hi <= lo) continue;
        }
        // Pixel lo/hi map to physical edges; translate to baseline-relative ends.
        final atBaselineLo = (lo - baselinePx).abs() < 0.5;
        final atBaselineHi = (hi - baselinePx).abs() < 0.5;
        final outerLo = k == 0, outerHi = k == bars.length - 1;
        final separate = !stacked || stackGap > 0;
        final roundPixelLo = (separate || outerLo) && (roundBaseline || !atBaselineLo);
        final roundPixelHi = (separate || outerHi) && (roundBaseline || !atBaselineHi);
        final rect = horizontal
            ? Rect.fromLTRB(lo, indexPos, hi, indexPos + thickness)
            : Rect.fromLTRB(indexPos, lo, indexPos + thickness, hi);
        // In vertical charts larger values have smaller pixels.
        final highIsPixelLo = horizontal ? !bars[k].positive : bars[k].positive;
        out.add(
          CdsBarGeometry(
            seriesId: bars[k].id,
            index: i,
            rect: rect,
            roundHigh: highIsPixelLo ? roundPixelLo : roundPixelHi,
            roundLow: highIsPixelLo ? roundPixelHi : roundPixelLo,
            positive: bars[k].positive,
          ),
        );
      }
    }
    stackIndex++;
  }
  return out;
}

/// Draws bars for some or all series of a [CdsCartesianChart]. [CdsBarChart]
/// adds one for you; use it directly to combine bars with lines.
///
/// ```dart
/// CdsCartesianChart(
///   xAxis: const CdsAxisConfig(scaleType: CdsAxisScaleType.band),
///   series: const [CdsChartSeries(id: 'volume', data: [4, 8, 6])],
///   children: const [CdsBarPlot()],
/// )
/// ```
class CdsBarPlot extends StatefulWidget {
  const CdsBarPlot({
    super.key,
    this.seriesIds,
    this.barPadding = 0.1,
    this.borderRadius = 4,
    this.fillOpacity = 1,
    this.stackGap = 0,
    this.barMinSize = 0,
    this.roundBaseline = false,
    this.animate,
  });

  /// Series drawn as bars. Defaults to every series.
  final List<String>? seriesIds;

  /// Gap between side-by-side bars in one category, as a fraction of the band.
  final double barPadding;

  /// Corner radius in pixels, capped at half the bar thickness.
  final double borderRadius;
  final double fillOpacity;

  /// Pixel gap between bars stacked on each other.
  final double stackGap;

  /// Minimum bar length in pixels, so small values stay visible.
  final double barMinSize;

  /// Round the end of each bar that touches the baseline.
  final bool roundBaseline;

  /// Overrides the chart's `animate` for these bars.
  final bool? animate;

  @override
  State<CdsBarPlot> createState() => _CdsBarPlotState();
}

class _CdsBarPlotState extends State<CdsBarPlot> with SingleTickerProviderStateMixin {
  late final ChartValueAnimator<List<Rect?>> _animator = ChartValueAnimator(
    vsync: this,
    lerp: (a, b, t) => lerpRects(a, b, t, horizontal: _horizontal),
    equals: (a, b) => listEquals(a, b),
  );
  bool _horizontal = false;

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = CdsCartesianChartScope.of(context);
    _horizontal = data.isHorizontal;
    final bars = cdsBarLayout(
      data,
      seriesIds: widget.seriesIds,
      barPadding: widget.barPadding,
      stackGap: widget.stackGap,
      barMinSize: widget.barMinSize,
      roundBaseline: widget.roundBaseline,
    );
    _animator.sync([for (final b in bars) b.rect], revision: data.revision, animate: widget.animate ?? data.animate);
    final theme = context.cds;
    final colors = {for (final s in data.series) s.id: s.resolveColor(theme)};
    return CustomPaint(
      painter: _BarPainter(
        bars: bars,
        colors: colors,
        animator: _animator,
        data: data,
        borderRadius: widget.borderRadius,
        fillOpacity: widget.fillOpacity,
        repaint: Listenable.merge([_animator.controller, data.enterProgress]),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.bars,
    required this.colors,
    required this.animator,
    required this.data,
    required this.borderRadius,
    required this.fillOpacity,
    super.repaint,
  });

  final List<CdsBarGeometry> bars;
  final Map<String, Color> colors;
  final ChartValueAnimator<List<Rect?>> animator;
  final CdsCartesianChartData data;
  final double borderRadius;
  final double fillOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rects = animator.value ?? const <Rect?>[];
    final horizontal = data.isHorizontal;
    final enter = data.enterProgress.value;
    final base = data.baselinePixel;
    for (var i = 0; i < bars.length && i < rects.length; i++) {
      var rect = rects[i];
      if (rect == null) continue;
      if (enter < 1) {
        // Bars grow out of the baseline on first render.
        final collapsed = horizontal
            ? Rect.fromLTRB(base, rect.top, base, rect.bottom)
            : Rect.fromLTRB(rect.left, base, rect.right, base);
        rect = Rect.lerp(collapsed, rect, enter)!;
      }
      final bar = bars[i];
      final thickness = horizontal ? rect.height : rect.width;
      final length = horizontal ? rect.width : rect.height;
      final both = bar.roundLow && bar.roundHigh;
      final r = Radius.circular(
        math.max(0, math.min(borderRadius, math.min(thickness / 2, both ? length / 2 : length))),
      );
      final highIsStart = horizontal ? !bar.positive : bar.positive;
      final roundStart = highIsStart ? bar.roundHigh : bar.roundLow;
      final roundEnd = highIsStart ? bar.roundLow : bar.roundHigh;
      final rrect = horizontal
          ? RRect.fromRectAndCorners(
              rect,
              topLeft: roundStart ? r : Radius.zero,
              bottomLeft: roundStart ? r : Radius.zero,
              topRight: roundEnd ? r : Radius.zero,
              bottomRight: roundEnd ? r : Radius.zero,
            )
          : RRect.fromRectAndCorners(
              rect,
              topLeft: roundStart ? r : Radius.zero,
              topRight: roundStart ? r : Radius.zero,
              bottomLeft: roundEnd ? r : Radius.zero,
              bottomRight: roundEnd ? r : Radius.zero,
            );
      final color = colors[bar.seriesId]!;
      canvas.drawRRect(rrect, Paint()..color = color.withValues(alpha: color.a * fillOpacity));
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => true;
}

/// A bar chart: grouped or stacked bars, vertical or horizontal.
///
/// ```dart
/// CdsBarChart(
///   height: 200,
///   showXAxis: true,
///   xAxis: const CdsAxisConfig(data: ['Mon', 'Tue', 'Wed']),
///   series: const [CdsChartSeries(id: 'volume', data: [4, 8, 6])],
/// )
/// ```
class CdsBarChart extends StatelessWidget {
  const CdsBarChart({
    super.key,
    this.series = const [],
    this.stacked = false,
    this.layout = CdsChartLayout.vertical,
    this.barPadding = 0.1,
    this.borderRadius = 4,
    this.fillOpacity = 1,
    this.stackGap = 0,
    this.barMinSize = 0,
    this.roundBaseline = false,
    this.showXAxis = false,
    this.showYAxis = false,
    this.xAxis = const CdsAxisConfig(),
    this.yAxis = const CdsAxisConfig(),
    this.xAxisStyle,
    this.yAxisStyle,
    this.animate = true,
    this.inset,
    this.legend,
    this.legendPosition = CdsLegendPosition.bottom,
    this.enableScrubbing = false,
    this.onScrubberPositionChange,
    this.width,
    this.height,
    this.accessibilityLabel,
    this.getScrubberAccessibilityLabel,
    this.children = const [],
  });

  final List<CdsChartSeries> series;

  /// Stack every series into one bar per category.
  final bool stacked;
  final CdsChartLayout layout;
  final double barPadding;
  final double borderRadius;
  final double fillOpacity;
  final double stackGap;
  final double barMinSize;
  final bool roundBaseline;
  final bool showXAxis;
  final bool showYAxis;

  /// The category axis defaults to a band scale in vertical charts.
  final CdsAxisConfig xAxis;

  /// The category axis defaults to a band scale in horizontal charts.
  final CdsAxisConfig yAxis;

  /// Visual options for the x axis shown when [showXAxis] is true.
  final CdsXAxis? xAxisStyle;

  /// Visual options for the y axis shown when [showYAxis] is true.
  final CdsYAxis? yAxisStyle;
  final bool animate;
  final CdsChartInset? inset;
  final Widget? legend;
  final CdsLegendPosition legendPosition;
  final bool enableScrubbing;
  final ValueChanged<int?>? onScrubberPositionChange;
  final double? width;
  final double? height;
  final String? accessibilityLabel;
  final CdsScrubberAccessibilityLabelBuilder? getScrubberAccessibilityLabel;

  /// Extra elements painted after the bars.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final horizontal = layout == CdsChartLayout.horizontal;
    final chartSeries = [
      for (final s in series)
        stacked && s.stackId == null
            ? CdsChartSeries(
                id: s.id,
                data: s.data,
                label: s.label,
                color: s.color,
                dangerouslySetColor: s.dangerouslySetColor,
                stackId: 'DEFAULT_STACK_ID',
                legendShape: s.legendShape,
              )
            : s,
    ];
    final x = horizontal
        ? xAxis.copyWith(includeBaseline: true)
        : xAxis.copyWith(scaleType: xAxis.scaleType ?? CdsAxisScaleType.band);
    final y = horizontal
        ? yAxis.copyWith(scaleType: yAxis.scaleType ?? CdsAxisScaleType.band)
        : yAxis.copyWith(includeBaseline: true);
    return CdsCartesianChart(
      series: chartSeries,
      layout: layout,
      animate: animate,
      xAxis: x,
      yAxis: y,
      inset: inset,
      legend: legend,
      legendPosition: legendPosition,
      enableScrubbing: enableScrubbing,
      onScrubberPositionChange: onScrubberPositionChange,
      width: width,
      height: height,
      accessibilityLabel: accessibilityLabel,
      getScrubberAccessibilityLabel: getScrubberAccessibilityLabel,
      children: [
        if (showXAxis) xAxisStyle ?? const CdsXAxis(),
        if (showYAxis) yAxisStyle ?? const CdsYAxis(),
        CdsBarPlot(
          barPadding: barPadding,
          borderRadius: borderRadius,
          fillOpacity: fillOpacity,
          stackGap: stackGap,
          barMinSize: barMinSize,
          roundBaseline: roundBaseline,
        ),
        ...children,
      ],
    );
  }
}
