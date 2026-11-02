import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme_data.dart';
import 'cds_chart_scale.dart';

/// Direction bars and areas grow in a [CdsCartesianChart].
enum CdsChartLayout {
  /// Bars grow vertically. X is the category axis, Y is the value axis.
  vertical,

  /// Bars grow horizontally. Y is the category axis, X is the value axis.
  horizontal,
}

/// Scale used by an axis.
enum CdsAxisScaleType {
  /// Continuous numeric scale. Lines and areas use it for both axes.
  linear,

  /// Evenly spaced categories with padding. Bar charts use it for the category axis.
  band,
}

/// How a numeric axis picks its bounds from the data.
enum CdsDomainLimit {
  /// Round the bounds outward to human-friendly values (0 to 100, not 1.2 to 97.8).
  nice,

  /// Use the exact data minimum and maximum.
  strict,
}

/// Shape drawn next to a series label in [CdsLegend].
enum CdsLegendShape { circle, square, squircle, pill }

/// Where [CdsCartesianChart] places its legend.
enum CdsLegendPosition { top, bottom, left, right }

/// Stroke style for lines.
enum CdsChartLineType { solid, dotted }

/// Fill style for areas.
enum CdsChartAreaType { solid, gradient, dotted }

/// One data series in a cartesian chart.
///
/// ```dart
/// CdsChartSeries(id: 'btc', label: 'Bitcoin', data: [10, 12, null, 14], color: CdsColor.fgPositive)
/// ```
@immutable
class CdsChartSeries {
  const CdsChartSeries({
    required this.id,
    this.data = const [],
    this.label,
    this.color,
    this.dangerouslySetColor,
    this.stackId,
    this.legendShape = CdsLegendShape.circle,
  });

  /// Unique id. Line, area and point widgets refer to a series by id.
  final String id;

  /// Values in category order. Null leaves a gap.
  final List<double?> data;

  /// Name shown in the legend, scrubber beacon labels and screen reader summaries.
  final String? label;

  /// Series color token. Defaults to `fgPrimary`.
  final CdsColor? color;

  /// Raw color, for data palettes built from the spectrum:
  /// `context.cds.spectrum.of(CdsHue.blue, 60)`. Takes precedence over [color].
  final Color? dangerouslySetColor;

  /// Series with the same stack id stack on top of each other.
  final String? stackId;
  final CdsLegendShape legendShape;

  /// The color this series draws with in [theme].
  Color resolveColor(CdsThemeData theme) => dangerouslySetColor ?? theme.colorOf(color ?? CdsColor.fgPrimary);

  @override
  bool operator ==(Object other) =>
      other is CdsChartSeries &&
      other.id == id &&
      listEquals(other.data, data) &&
      other.label == label &&
      other.color == color &&
      other.dangerouslySetColor == dangerouslySetColor &&
      other.stackId == stackId &&
      other.legendShape == legendShape;

  @override
  int get hashCode => Object.hash(id, Object.hashAll(data), label, color, dangerouslySetColor, stackId, legendShape);
}

/// Scale configuration for one axis of a [CdsCartesianChart].
///
/// Visuals (ticks, grid, labels) live on [CdsXAxis] and [CdsYAxis]; this only
/// decides how data maps to pixels.
///
/// ```dart
/// CdsAxisConfig(data: ['Jan', 'Feb', 'Mar'], scaleType: CdsAxisScaleType.band)
/// CdsAxisConfig(domain: CdsAxisDomain(min: 0))
/// ```
@immutable
class CdsAxisConfig {
  const CdsAxisConfig({
    this.scaleType,
    this.data,
    this.domain,
    this.domainLimit,
    this.categoryPadding,
    this.baseline,
    this.includeBaseline = false,
  });

  /// Defaults to `linear`, or `band` for the category axis of a bar chart.
  final CdsAxisScaleType? scaleType;

  /// Category labels. On the category axis these label ticks and set the
  /// number of positions.
  final List<String>? data;

  /// Fixes either bound. Unset bounds come from the data.
  final CdsAxisDomain? domain;

  /// Defaults to `strict` for the category axis and `nice` for the value axis.
  final CdsDomainLimit? domainLimit;

  /// Empty fraction of each band (band scales only), 0 to 1. Defaults to 0.3.
  final double? categoryPadding;

  /// Value the bars and areas grow from on the value axis. Defaults to 0.
  final double? baseline;

  /// Extends a computed domain so it contains [baseline]. Bar and area charts
  /// turn this on so bars start from zero.
  final bool includeBaseline;

  CdsAxisConfig copyWith({
    CdsAxisScaleType? scaleType,
    List<String>? data,
    CdsAxisDomain? domain,
    CdsDomainLimit? domainLimit,
    double? categoryPadding,
    double? baseline,
    bool? includeBaseline,
  }) => CdsAxisConfig(
    scaleType: scaleType ?? this.scaleType,
    data: data ?? this.data,
    domain: domain ?? this.domain,
    domainLimit: domainLimit ?? this.domainLimit,
    categoryPadding: categoryPadding ?? this.categoryPadding,
    baseline: baseline ?? this.baseline,
    includeBaseline: includeBaseline ?? this.includeBaseline,
  );

  @override
  bool operator ==(Object other) =>
      other is CdsAxisConfig &&
      other.scaleType == scaleType &&
      listEquals(other.data, data) &&
      other.domain == domain &&
      other.domainLimit == domainLimit &&
      other.categoryPadding == categoryPadding &&
      other.baseline == baseline &&
      other.includeBaseline == includeBaseline;

  @override
  int get hashCode => Object.hash(
    scaleType,
    data == null ? null : Object.hashAll(data!),
    domain,
    domainLimit,
    categoryPadding,
    baseline,
    includeBaseline,
  );
}

/// Partial axis bounds. Null sides are computed from the data.
@immutable
class CdsAxisDomain {
  const CdsAxisDomain({this.min, this.max});

  final double? min;
  final double? max;

  @override
  bool operator ==(Object other) => other is CdsAxisDomain && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

/// Space around the chart drawing area, outside the axes, in logical pixels.
@immutable
class CdsChartInset {
  const CdsChartInset({this.top = 0, this.left = 0, this.bottom = 0, this.right = 0});

  const CdsChartInset.all(double value) : top = value, left = value, bottom = value, right = value;

  /// CDS default for vertical charts.
  static const CdsChartInset vertical = CdsChartInset(top: 32, left: 16, bottom: 16, right: 16);

  /// CDS default for horizontal charts.
  static const CdsChartInset horizontal = CdsChartInset(top: 16, left: 16, bottom: 16, right: 48);

  final double top;
  final double left;
  final double bottom;
  final double right;

  @override
  bool operator ==(Object other) =>
      other is CdsChartInset &&
      other.top == top &&
      other.left == left &&
      other.bottom == bottom &&
      other.right == right;

  @override
  int get hashCode => Object.hash(top, left, bottom, right);
}

/// One timestamped value, used by [CdsSparklineInteractive].
@immutable
class CdsChartDataPoint {
  const CdsChartDataPoint({required this.value, required this.date});

  final double value;
  final DateTime date;

  @override
  bool operator ==(Object other) => other is CdsChartDataPoint && other.value == value && other.date == date;

  @override
  int get hashCode => Object.hash(value, date);
}

/// Formats a number for screen readers and default labels: whole numbers
/// without decimals, others with up to two.
String cdsChartFormatValue(double value) {
  if (!value.isFinite) return '';
  if (value == value.roundToDouble() && value.abs() < 1e15) return value.toInt().toString();
  var s = value.toStringAsFixed(2);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  }
  return s;
}

/// Internal stacking result: for each series, `[low, high]` per category.
typedef CdsStackedData = Map<String, List<(double, double)?>>;

/// Normalizes and stacks series values around [baseline], like d3 `stack`
/// with `stackOffsetDiverging`: positive values stack upward from the
/// baseline, negative values downward.
CdsStackedData cdsStackSeries(List<CdsChartSeries> series, {double baseline = 0}) {
  final out = <String, List<(double, double)?>>{};
  final groups = <String, List<CdsChartSeries>>{};
  for (final s in series) {
    if (s.stackId == null) {
      out[s.id] = [for (final v in s.data) v == null || !v.isFinite ? null : (baseline, v)];
    } else {
      groups.putIfAbsent(s.stackId!, () => []).add(s);
    }
  }
  for (final group in groups.values) {
    if (group.length < 2) {
      final s = group.single;
      out[s.id] = [for (final v in s.data) v == null || !v.isFinite ? null : (baseline, v)];
      continue;
    }
    final length = group.fold<int>(0, (m, s) => s.data.length > m ? s.data.length : m);
    final positive = List<double>.filled(length, 0);
    final negative = List<double>.filled(length, 0);
    for (final s in group) {
      out[s.id] = List.generate(length, (i) {
        final raw = i < s.data.length ? s.data[i] : null;
        final v = raw == null || !raw.isFinite ? 0.0 : raw - baseline;
        if (v >= 0) {
          final low = positive[i];
          positive[i] += v;
          return (low + baseline, positive[i] + baseline);
        }
        final high = negative[i];
        negative[i] += v;
        return (negative[i] + baseline, high + baseline);
      });
    }
  }
  return out;
}

/// Bounds of every finite value in [stacked], or null when there are none.
CdsAxisBounds? cdsStackedExtent(CdsStackedData stacked, {bool includeLow = true}) {
  var lo = double.infinity;
  var hi = double.negativeInfinity;
  for (final list in stacked.values) {
    for (final p in list) {
      if (p == null) continue;
      final values = includeLow ? [p.$1, p.$2] : [p.$2];
      for (final v in values) {
        if (v < lo) lo = v;
        if (v > hi) hi = v;
      }
    }
  }
  if (lo == double.infinity) return null;
  return CdsAxisBounds(lo, hi);
}
