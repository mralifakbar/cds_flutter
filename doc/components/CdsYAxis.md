# CdsYAxis

The vertical axis of a cartesian chart: value labels, grid lines, tick marks, axis line and title.

CDS reference: https://cds.coinbase.com/components/charts/YAxis

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCartesianChart(
  height: 200,
  series: const [CdsChartSeries(id: 'a', data: [3, 5, 4])],
  children: [
    CdsYAxis(showGrid: true, tickLabelFormatter: (v) => '\$${v.toInt()}'),
    const CdsLine(seriesId: 'a'),
  ],
)
```

## When to use / when not to

- Use it when people compare values against a scale. Put it first in `children` so grid lines sit behind data.
- In the chart wrappers, set `showYAxis: true` and pass visuals through `yAxisStyle`.
- CDS places it on the right by default.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `position` | `CdsYAxisPosition` | `right` | `left` or `right`. |
| `showGrid` | `bool` | `false` | Dotted `bgLine` grid lines across the drawing area at each tick. |
| `showLine` | `bool` | `false` | Solid 1px `fg` axis line. |
| `showTickMarks` | `bool` | `false` | Solid 1px `fg` tick marks. |
| `tickMarkSize` | `double` | `4` | Tick mark length. |
| `ticks` | `List<double>?` | `null` | Exact tick values (category indices for band scales). Overrides every other tick option. |
| `tickFilter` | `bool Function(double)?` | `null` | Keeps only ticks for which it returns true (every index on a category axis). |
| `tickMinStep` | `double` | `1` | Smallest step for interval-based ticks. |
| `tickMaxStep` | `double?` | `null` | Largest step for interval-based ticks. |
| `tickLabelFormatter` | `String Function(double)?` | `null` | Formats tick values. Category labels from `CdsAxisConfig.data` are used when null. |
| `label` | `String?` | `null` | Axis title. |
| `bandGridLinePlacement` | `CdsAxisBandPlacement` | `edges` | Band scales: grid lines at `start`, `middle`, `end` of each band, or `edges` (start of each plus the closing edge). |
| `bandTickMarkPlacement` | `CdsAxisBandPlacement` | `middle` | Band scales: tick mark placement. |
| `requestedTickCount` | `int?` | `null` | Approximate tick count. Defaults to 5 when y is the value axis (vertical charts). |
| `tickInterval` | `double?` | `null` | Pixel spacing between ticks, used when no count is requested. |
| `tickMarkLabelGap` | `double` | `8` | Gap between tick marks (or the axis edge) and labels. |
| `minTickLabelGap` | `double` | `0` | Labels closer than this to a neighbor are hidden. |
| `width` | `double?` | `null` | Reserved width. Defaults to 44, or 64 with a `label`. |

## Examples

### Left axis for horizontal bars

```dart
const CdsBarChart(
  height: 160,
  layout: CdsChartLayout.horizontal,
  showYAxis: true,
  yAxis: CdsAxisConfig(data: ['Alpha', 'Beta', 'Gamma']),
  yAxisStyle: CdsYAxis(position: CdsYAxisPosition.left, width: 56),
  series: [CdsChartSeries(id: 'a', data: [12, 30, 21])],
)
```

## Accessibility

Same as `CdsXAxis`: labels are painted, the chart's semantics carry values. Format values the same way in `tickLabelFormatter` and in the chart's `getScrubberAccessibilityLabel`.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `position` | `position` (default `right`) |
| `ticks` (array / function) | `ticks` / `tickFilter` |
| `width` | `width` |
| other props | same as `CdsXAxis` |
