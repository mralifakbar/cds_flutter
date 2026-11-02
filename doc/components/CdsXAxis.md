# CdsXAxis

The horizontal axis of a cartesian chart: tick labels, grid lines, tick marks, axis line and title.

CDS reference: https://cds.coinbase.com/components/charts/XAxis

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsCartesianChart(
  height: 200,
  xAxis: CdsAxisConfig(data: ['Jan', 'Feb', 'Mar']),
  series: [CdsChartSeries(id: 'a', data: [3, 5, 4])],
  children: [CdsXAxis(showGrid: true), CdsLine(seriesId: 'a')],
)
```

## When to use / when not to

- Put it first in a chart's `children` so grid lines sit behind data. The chart reserves its height below (or above) the drawing area.
- In `CdsLineChart`, `CdsAreaChart` and `CdsBarChart`, set `showXAxis: true` and pass visuals through `xAxisStyle`.
- Leave axes off for compact charts where a header already shows the values.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `position` | `CdsXAxisPosition` | `bottom` | `top` or `bottom`. |
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
| `requestedTickCount` | `int?` | `null` | Approximate tick count (d3 `ticks`). Defaults to 5 when x is the value axis (horizontal charts). Overrides `tickInterval`. |
| `tickInterval` | `double` | `32` | Approximate pixel spacing between ticks; always includes the first value. |
| `tickMarkLabelGap` | `double` | `2` | Gap between tick marks (or the axis edge) and labels. |
| `minTickLabelGap` | `double` | `4` | Labels closer than this to a neighbor are hidden; the first and last are kept. |
| `height` | `double?` | `null` | Reserved height. Defaults to 32, or 52 with a `label`. |

## Examples

### Every other month, with tick marks and a title

```dart
const CdsLineChart(
  height: 220,
  showXAxis: true,
  xAxis: CdsAxisConfig(data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']),
  xAxisStyle: CdsXAxis(showLine: true, showTickMarks: true, ticks: [0, 2, 4], label: 'Month'),
  series: [CdsLineSeries(id: 'a', data: [3, 5, 4, 6, 8, 7])],
)
```

## Accessibility

Tick labels are painted, not separate semantics nodes; the chart's own label and scrubber value carry the information. Use `getScrubberAccessibilityLabel` on the chart to read category names. Labels use `label2` in `fgMuted` and scale with the text scale setting.

## Motion

None. The axis redraws immediately when scales change, as on CDS mobile.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `position`, `showGrid`, `showLine`, `showTickMarks`, `tickMarkSize` | same names |
| `ticks` (array) | `ticks` |
| `ticks` (function) | `tickFilter` |
| `requestedTickCount`, `tickInterval`, `tickMinStep`, `tickMaxStep` | same names |
| `tickLabelFormatter` | `tickLabelFormatter` (returns `String`) |
| `tickMarkLabelGap`, `minTickLabelGap`, `label`, `height` | same names |
| `bandGridLinePlacement`, `bandTickMarkPlacement` | same names |
| `axisId` | not ported; one x axis per chart |
| `labelGap`, `tickLabelOverflow`, `*Component` | not ported; edge labels are kept inside the canvas |
