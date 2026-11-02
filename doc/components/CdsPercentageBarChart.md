# CdsPercentageBarChart

A part-to-whole bar: each series is a segment sized by its share of the total. Horizontal by default.

CDS reference: https://cds.coinbase.com/components/charts/PercentageBarChart

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsPercentageBarChart(
  height: 16,
  series: [
    CdsPercentageBarSeries.single(id: 'a', value: 70, label: 'Segment A', color: CdsColor.fgPositive),
    CdsPercentageBarSeries.single(id: 'b', value: 45, label: 'Segment B', color: CdsColor.fgNegative),
  ],
)
```

## When to use / when not to

- Use it for a split that sums to a whole: buy versus sell volume, allocation, vote shares.
- Pass several values per series to draw one bar per group (rows when horizontal).
- Negative values, null and missing indices count as zero. If every group sums to zero, nothing is drawn; show an empty state around it.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `series` | `List<CdsPercentageBarSeries>` | `const []` | Segments. `data` is `List<double?>` (one value per bar); `CdsPercentageBarSeries.single(value: ...)` fills the first bar only. |
| `layout` | `CdsChartLayout` | `horizontal` | Bar orientation. |
| `roundBaseline` | `bool` | `true` | Round the start of the bar too. |
| `inset` | `CdsChartInset` | `const CdsChartInset()` | No space around the bar by default. |
| `borderRadius` | `double` | `4` | Segment corner radius. `1000` makes pill ends. |
| `stackGap` | `double` | `0` | Pixel gap between segments; the bar keeps its full length. |
| `barMinSize` | `double` | `0` | Minimum segment length in pixels. |
| `barPadding` | `double` | `0.1` | Band fraction between groups. |
| `showXAxis`, `showYAxis` | `bool` | `false` | Render axes. The value axis is fixed to 0 to 100; the category axis padding defaults to 0. |
| `xAxis`, `yAxis`, `xAxisStyle`, `yAxisStyle` | see `CdsBarChart` | | Axis configuration and visuals. |
| `animate` | `bool` | `true` | Grow and morph segments. |
| `legend`, `legendPosition` | `Widget?`, `CdsLegendPosition` | `null`, `bottom` | Legend. |
| `width`, `height` | `double?` | `null` | Size. |
| `accessibilityLabel` | `String?` | `null` | Defaults to each segment's label and rounded share, for example "Buy 61%". |
| `children` | `List<Widget>` | `const []` | Extra elements. |

## Examples

### Pill ends with gaps

```dart
CdsPercentageBarChart(
  height: 28,
  borderRadius: 1000,
  stackGap: 2,
  series: [
    CdsPercentageBarSeries.single(id: 'a', value: 45, label: 'A', dangerouslySetColor: context.cds.spectrum.of(CdsHue.purple, 30)),
    CdsPercentageBarSeries.single(id: 'b', value: 30, label: 'B', dangerouslySetColor: context.cds.spectrum.of(CdsHue.blue, 30)),
    CdsPercentageBarSeries.single(id: 'c', value: 20, label: 'C', dangerouslySetColor: context.cds.spectrum.of(CdsHue.teal, 30)),
  ],
)
```

### Several groups with labels

```dart
const CdsPercentageBarChart(
  height: 100,
  stackGap: 2,
  showYAxis: true,
  yAxis: CdsAxisConfig(data: ['Q1', 'Q2', 'Q3'], categoryPadding: 0.45),
  yAxisStyle: CdsYAxis(position: CdsYAxisPosition.left),
  series: [
    CdsPercentageBarSeries(id: 'a', data: [40, null, 20], label: 'A', color: CdsColor.fgPositive),
    CdsPercentageBarSeries(id: 'b', data: [-10, 60, 30], label: 'B', color: CdsColor.fgWarning),
  ],
)
```

## Accessibility

The chart is one node labeled with every segment's share of the first group. Pass `accessibilityLabel` for multi-group charts or localized text, and show the shares as text (a legend with percentages) so color is never the only cue.

## Motion

Segments grow from the start on first render and morph with the CDS update spring when shares change. Instant under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `series` (`data: number | number[]`) | `series` (`CdsPercentageBarSeries` / `.single`) |
| `layout`, `roundBaseline`, `inset` | same names, same defaults |
| `borderRadius`, `stackGap`, `barMinSize` | same names |
| other `BarChart` props | see `CdsBarChart` |
