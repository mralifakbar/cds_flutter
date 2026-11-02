import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_cartesian_chart.dart';
import 'cds_chart_types.dart';

/// Lists the labeled series of the surrounding chart with their colors. Pass
/// it as a chart's `legend`; series without a `label` are skipped.
///
/// ```dart
/// CdsLineChart(
///   legend: const CdsLegend(),
///   series: const [
///     CdsLineSeries(id: 'btc', label: 'Bitcoin', data: [1, 2, 3]),
///     CdsLineSeries(id: 'eth', label: 'Ethereum', data: [2, 1, 3], color: CdsColor.fgWarning),
///   ],
/// )
/// ```
class CdsLegend extends StatelessWidget {
  const CdsLegend({
    super.key,
    this.seriesIds,
    this.series,
    this.direction = Axis.horizontal,
    this.justifyContent = WrapAlignment.center,
    this.columnGap = 2,
    this.rowGap = 0.75,
    this.padding = 1,
    this.accessibilityLabel = 'Legend',
  });

  /// Series to show. Defaults to every labeled series.
  final List<String>? seriesIds;

  /// Series to list when the legend is used outside a chart.
  final List<CdsChartSeries>? series;

  /// `horizontal` wraps entries in rows; `vertical` stacks them.
  final Axis direction;
  final WrapAlignment justifyContent;

  /// Space token between entries on a row.
  final double columnGap;

  /// Space token between rows.
  final double rowGap;

  /// Space token around the legend.
  final double padding;
  final String accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final all = series ?? CdsCartesianChartScope.seriesOf(context) ?? const [];
    final shown = [
      for (final s in all)
        if (s.label != null && (seriesIds == null || seriesIds!.contains(s.id))) s,
    ];
    if (shown.isEmpty) return const SizedBox.shrink();
    final entries = [
      for (final s in shown) CdsLegendEntry(label: s.label!, color: s.resolveColor(theme), shape: s.legendShape),
    ];
    return Semantics(
      container: true,
      label: accessibilityLabel,
      child: Padding(
        padding: EdgeInsets.all(theme.space(padding)),
        child: direction == Axis.horizontal
            ? Wrap(
                alignment: justifyContent,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: theme.space(columnGap),
                runSpacing: theme.space(rowGap),
                children: entries,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: theme.space(rowGap),
                children: entries,
              ),
      ),
    );
  }
}

/// One legend row: a colored shape and a label.
class CdsLegendEntry extends StatelessWidget {
  const CdsLegendEntry({super.key, required this.label, required this.color, this.shape = CdsLegendShape.circle});

  final String label;
  final Color color;
  final CdsLegendShape shape;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final (w, h, r) = switch (shape) {
      CdsLegendShape.circle => (10.0, 10.0, 5.0),
      CdsLegendShape.square => (10.0, 10.0, 0.0),
      CdsLegendShape.squircle => (10.0, 10.0, 2.0),
      CdsLegendShape.pill => (6.0, 24.0, 3.0),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.space(1),
      children: [
        SizedBox(
          width: 10,
          height: 24,
          child: Center(
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(r)),
            ),
          ),
        ),
        CdsText(label, font: CdsFont.label1),
      ],
    );
  }
}
