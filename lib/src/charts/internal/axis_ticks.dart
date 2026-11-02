import 'dart:math' as math;
import 'dart:ui';

import '../cds_chart_scale.dart';
import '../cds_chart_types.dart';

/// One tick: its data value and pixel position along the axis.
typedef AxisTick = ({double value, double position});

/// Grid line and tick mark placement for band scales.
enum CdsAxisBandPlacement { start, middle, end, edges }

CdsPointAnchor bandAnchor(CdsAxisBandPlacement p) => switch (p) {
  CdsAxisBandPlacement.start || CdsAxisBandPlacement.edges => CdsPointAnchor.stepStart,
  CdsAxisBandPlacement.end => CdsPointAnchor.stepEnd,
  CdsAxisBandPlacement.middle => CdsPointAnchor.middle,
};

/// Computes ticks with CDS precedence: explicit [ticks], then [tickFilter],
/// then [requestedTickCount], then [tickInterval] spacing.
List<AxisTick> computeAxisTicks({
  required CdsChartScale scale,
  required List<String>? categories,
  List<double>? ticks,
  bool Function(double value)? tickFilter,
  int? requestedTickCount,
  double? tickInterval,
  double? tickMinStep,
  double? tickMaxStep,
}) {
  if (scale is CdsBandScale) {
    final count = categories?.length ?? scale.count;
    Iterable<int> indices = List.generate(count, (i) => i);
    if (ticks != null) {
      indices = ticks.map((t) => t.round()).where((i) => i >= 0 && i < count);
    } else if (tickFilter != null) {
      indices = indices.where((i) => tickFilter(i.toDouble()));
    }
    return [for (final i in indices) (value: i.toDouble(), position: scale.anchorOf(i, CdsPointAnchor.middle))];
  }
  final linear = scale as CdsLinearScale;
  final possible = categories == null ? null : List<double>.generate(categories.length, (i) => i.toDouble());
  List<double> values;
  if (ticks != null) {
    values = ticks;
  } else if (tickFilter != null) {
    values = (possible ?? linear.ticks(requestedTickCount ?? 10)).where(tickFilter).toList();
  } else if (requestedTickCount != null) {
    values = linear.ticks(requestedTickCount);
  } else if (tickInterval != null) {
    if (possible != null && possible.isNotEmpty) {
      final count = math.min(math.max((linear.range.span.abs() / tickInterval).floor(), 4), possible.length);
      if (count <= 1) {
        values = [possible.first];
      } else {
        final step = (possible.length - 1) / (count - 1);
        values = [for (var i = 0; i < count; i++) possible[i == count - 1 ? possible.length - 1 : (step * i).round()]];
      }
    } else {
      values = CdsChartTicks.evenlyDistributed(linear, tickInterval, minStep: tickMinStep, maxStep: tickMaxStep);
    }
  } else {
    values = const [];
  }
  return [
    for (final v in values)
      if (v.isFinite) (value: v, position: linear(v)),
  ];
}

/// Default label for a tick: the category name when the axis has string data,
/// otherwise the formatter or a plain number.
String axisTickLabel(double value, List<String>? categories, String Function(double)? formatter) {
  if (formatter != null) return formatter(value);
  if (categories != null) {
    final i = value.round();
    if (i >= 0 && i < categories.length && i == value) return categories[i];
  }
  return cdsChartFormatValue(value);
}

/// Hides labels that would sit closer than [minGap] to a visible neighbor,
/// always keeping the first and last (CDS `prioritizeEndLabels`).
List<int> visibleLabelIndices(List<Rect> rects, double minGap, {required bool horizontal}) {
  if (rects.length <= 2) return List.generate(rects.length, (i) => i);
  bool overlaps(Rect a, Rect b) => horizontal
      ? a.right + minGap > b.left && b.right + minGap > a.left
      : a.bottom + minGap > b.top && b.bottom + minGap > a.top;
  final last = rects.length - 1;
  final kept = <int>[0];
  for (var i = 1; i < last; i++) {
    if (!overlaps(rects[kept.last], rects[i]) && !overlaps(rects[i], rects[last])) kept.add(i);
  }
  if (!overlaps(rects[kept.last], rects[last])) kept.add(last);
  return kept;
}
