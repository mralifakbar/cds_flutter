import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import 'cds_bar_chart.dart';
import 'cds_chart_types.dart';
import 'cds_x_axis.dart';
import 'cds_y_axis.dart';

/// One segment series in a [CdsPercentageBarChart]. [data] holds one value per
/// bar; [CdsPercentageBarSeries.single] is shorthand for a single bar.
@immutable
class CdsPercentageBarSeries {
  const CdsPercentageBarSeries({
    required this.id,
    required this.data,
    this.label,
    this.color,
    this.dangerouslySetColor,
    this.legendShape = CdsLegendShape.circle,
  });

  /// A series contributing [value] to the first bar only.
  CdsPercentageBarSeries.single({
    required this.id,
    required double value,
    this.label,
    this.color,
    this.dangerouslySetColor,
    this.legendShape = CdsLegendShape.circle,
  }) : data = [value];

  final String id;

  /// Raw values per bar. Negative values and null count as zero.
  final List<double?> data;
  final String? label;
  final CdsColor? color;
  final Color? dangerouslySetColor;
  final CdsLegendShape legendShape;
}

/// Converts raw segment values to percentages of each group's total.
/// Groups whose total is zero produce nulls (nothing is drawn).
List<CdsChartSeries> cdsPercentageSeries(List<CdsPercentageBarSeries> series) {
  final groups = series.fold<int>(0, (m, s) => math.max(m, s.data.length));
  double valueAt(CdsPercentageBarSeries s, int i) {
    final raw = i < s.data.length ? s.data[i] : null;
    return raw == null || !raw.isFinite ? 0 : math.max(0, raw);
  }

  final totals = List<double>.generate(groups, (i) => series.fold(0.0, (sum, s) => sum + valueAt(s, i)));
  return [
    for (final s in series)
      CdsChartSeries(
        id: s.id,
        label: s.label,
        color: s.color,
        dangerouslySetColor: s.dangerouslySetColor,
        legendShape: s.legendShape,
        stackId: 'DEFAULT_STACK_ID',
        data: [
          for (var i = 0; i < groups; i++)
            totals[i] > 0 && i < s.data.length && s.data[i] != null ? valueAt(s, i) / totals[i] * 100 : null,
        ],
      ),
  ];
}

/// A part-to-whole bar: each series is a segment sized by its share of the
/// total. Built on [CdsBarChart], horizontal by default.
///
/// ```dart
/// CdsPercentageBarChart(
///   height: 16,
///   stackGap: 2,
///   series: [
///     CdsPercentageBarSeries.single(id: 'a', value: 70, label: 'Buy', color: CdsColor.fgPositive),
///     CdsPercentageBarSeries.single(id: 'b', value: 45, label: 'Sell', color: CdsColor.fgNegative),
///   ],
/// )
/// ```
class CdsPercentageBarChart extends StatelessWidget {
  const CdsPercentageBarChart({
    super.key,
    this.series = const [],
    this.layout = CdsChartLayout.horizontal,
    this.roundBaseline = true,
    this.inset = const CdsChartInset(),
    this.borderRadius = 4,
    this.stackGap = 0,
    this.barMinSize = 0,
    this.barPadding = 0.1,
    this.showXAxis = false,
    this.showYAxis = false,
    this.xAxis = const CdsAxisConfig(),
    this.yAxis = const CdsAxisConfig(),
    this.xAxisStyle,
    this.yAxisStyle,
    this.animate = true,
    this.legend,
    this.legendPosition = CdsLegendPosition.bottom,
    this.width,
    this.height,
    this.accessibilityLabel,
    this.children = const [],
  });

  final List<CdsPercentageBarSeries> series;
  final CdsChartLayout layout;

  /// Round the segment ends at the start of the bar.
  final bool roundBaseline;
  final CdsChartInset inset;
  final double borderRadius;

  /// Pixel gap between segments. The bar keeps its full length.
  final double stackGap;
  final double barMinSize;
  final double barPadding;
  final bool showXAxis;
  final bool showYAxis;
  final CdsAxisConfig xAxis;
  final CdsAxisConfig yAxis;
  final CdsXAxis? xAxisStyle;
  final CdsYAxis? yAxisStyle;
  final bool animate;
  final Widget? legend;
  final CdsLegendPosition legendPosition;
  final double? width;
  final double? height;

  /// Defaults to each segment's label and share, for example "Buy 61%".
  final String? accessibilityLabel;
  final List<Widget> children;

  String _summary(List<CdsChartSeries> percentages) {
    final parts = <String>[];
    for (final s in percentages) {
      final v = s.data.isEmpty ? null : s.data.first;
      if (v == null) continue;
      parts.add('${s.label ?? s.id} ${v.round()}%');
    }
    return parts.isEmpty ? 'Percentage bar, no data' : 'Percentage bar. ${parts.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final percentages = cdsPercentageSeries(series);
    final horizontal = layout == CdsChartLayout.horizontal;
    const valueDomain = CdsAxisDomain(min: 0, max: 100);
    final x = horizontal
        ? xAxis.copyWith(domain: xAxis.domain ?? valueDomain, domainLimit: xAxis.domainLimit ?? CdsDomainLimit.strict)
        : xAxis.copyWith(categoryPadding: xAxis.categoryPadding ?? 0);
    final y = horizontal
        ? yAxis.copyWith(categoryPadding: yAxis.categoryPadding ?? 0)
        : yAxis.copyWith(domain: yAxis.domain ?? valueDomain, domainLimit: yAxis.domainLimit ?? CdsDomainLimit.strict);
    return CdsBarChart(
      series: percentages,
      stacked: true,
      layout: layout,
      roundBaseline: roundBaseline,
      inset: inset,
      borderRadius: borderRadius,
      stackGap: stackGap,
      barMinSize: barMinSize,
      barPadding: barPadding,
      showXAxis: showXAxis,
      showYAxis: showYAxis,
      xAxis: x,
      yAxis: y,
      xAxisStyle: xAxisStyle,
      yAxisStyle: yAxisStyle,
      animate: animate,
      legend: legend,
      legendPosition: legendPosition,
      width: width,
      height: height,
      accessibilityLabel: accessibilityLabel ?? _summary(percentages),
      children: children,
    );
  }
}
