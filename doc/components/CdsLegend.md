# CdsLegend

Lists the labeled series of the surrounding chart with their colors and shapes.

CDS reference: https://cds.coinbase.com/components/charts/Legend

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsLineChart(
  height: 200,
  legend: CdsLegend(),
  series: [
    CdsLineSeries(id: 'a', label: 'Series A', data: [1, 2, 3]),
    CdsLineSeries(id: 'b', label: 'Series B', data: [2, 1, 3], color: CdsColor.fgWarning),
  ],
)
```

## When to use / when not to

- Use it whenever a chart shows more than one series, so color is never the only way to tell them apart.
- Pass it as the chart's `legend`. Series without a `label` are skipped.
- Outside a chart, pass `series` directly.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `seriesIds` | `List<String>?` | `null` | Series to show. Defaults to every labeled series. |
| `series` | `List<CdsChartSeries>?` | `null` | Series to list when used outside a chart. |
| `direction` | `Axis` | `Axis.horizontal` | `horizontal` wraps entries in centered rows; `vertical` stacks them. |
| `justifyContent` | `WrapAlignment` | `WrapAlignment.center` | Row alignment. |
| `columnGap` | `double` | `2` | Space token between entries. |
| `rowGap` | `double` | `0.75` | Space token between rows. |
| `padding` | `double` | `1` | Space token around the legend. |
| `accessibilityLabel` | `String` | `'Legend'` | Label of the legend group. |

Each entry is a `CdsLegendEntry(label:, color:, shape:)`: a 10px shape (`circle`, `square`, `squircle`, or a 6x24 `pill`) and a `label1` label.

## Examples

### Vertical legend on the right

```dart
const CdsBarChart(
  height: 200,
  legend: CdsLegend(direction: Axis.vertical),
  legendPosition: CdsLegendPosition.right,
  series: [
    CdsChartSeries(id: 'a', label: 'Buys', data: [3, 4], color: CdsColor.fgPositive, legendShape: CdsLegendShape.squircle),
    CdsChartSeries(id: 'b', label: 'Sells', data: [2, 5], color: CdsColor.fgNegative, legendShape: CdsLegendShape.squircle),
  ],
)
```

## Accessibility

The legend is a semantics container labeled "Legend"; each entry's text is read in order. The shape is decorative.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `seriesIds` | `seriesIds` |
| `flexDirection` | `direction` |
| `justifyContent`, `columnGap`, `rowGap` | same names |
| `accessibilityLabel` | `accessibilityLabel` |
| series `legendShape` | `CdsChartSeries.legendShape` |
| `EntryComponent`, `ShapeComponent`, `styles` | not ported; compose `CdsLegendEntry` |
