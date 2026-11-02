# CdsBarChart

Grouped or stacked bars, vertical or horizontal, built on `CdsCartesianChart`.

CDS reference: https://cds.coinbase.com/components/charts/BarChart

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsBarChart(
  height: 200,
  showXAxis: true,
  xAxis: CdsAxisConfig(data: ['Mon', 'Tue', 'Wed']),
  series: [CdsChartSeries(id: 'volume', data: [4, 8, 6])],
)
```

## When to use / when not to

- Use it to compare discrete categories or periods (daily volume, monthly totals).
- Use `stacked: true` to show composition, and `CdsPercentageBarChart` when only shares matter.
- The category axis is a band scale (`categoryPadding` 0.3) and the value axis always includes the baseline.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `series` | `List<CdsChartSeries>` | `const []` | One bar per series per category; series sharing a `stackId` stack. |
| `stacked` | `bool` | `false` | Stack every series into one bar per category. |
| `layout` | `CdsChartLayout` | `vertical` | `horizontal` makes bars grow to the right. |
| `barPadding` | `double` | `0.1` | Gap between side-by-side bars in one category, as a fraction of the band. |
| `borderRadius` | `double` | `4` | Corner radius in pixels, capped at half the bar thickness. |
| `fillOpacity` | `double` | `1` | Bar opacity. |
| `stackGap` | `double` | `0` | Pixel gap between stacked bars. The stack keeps its total length. |
| `barMinSize` | `double` | `0` | Minimum bar length in pixels. |
| `roundBaseline` | `bool` | `false` | Round the end touching the baseline too. |
| `showXAxis`, `showYAxis` | `bool` | `false` | Render the axes. |
| `xAxis`, `yAxis` | `CdsAxisConfig` | `const CdsAxisConfig()` | Scale configuration. The category axis defaults to `band`. |
| `xAxisStyle`, `yAxisStyle` | `CdsXAxis?`, `CdsYAxis?` | `null` | Visual axis options. |
| `animate` | `bool` | `true` | Enter reveal and data-change animation. Reduced motion turns it off. |
| `inset` | `CdsChartInset?` | `null` | Space around the drawing area, outside the axes. Defaults to `CdsChartInset.vertical` (top 32, sides and bottom 16) or `CdsChartInset.horizontal` (right 48, others 16). |
| `legend` | `Widget?` | `null` | Legend beside the chart, usually `const CdsLegend()`. |
| `legendPosition` | `CdsLegendPosition` | `bottom` | `top`, `bottom`, `left` or `right`. A top or bottom legend adds to `height`. |
| `enableScrubbing` | `bool` | `false` | Drag, long-press and drag, or arrow keys to inspect values. |
| `onScrubberPositionChange` | `ValueChanged<int?>?` | `null` | Scrubbed data index, or null when scrubbing ends. |
| `width` | `double?` | `null` | Defaults to the parent width. |
| `height` | `double?` | `null` | Canvas height. Defaults to the parent height, or 160 when unbounded. |
| `accessibilityLabel` | `String?` | `null` | Screen reader label. Defaults to each series: label, lowest, highest, latest. |
| `getScrubberAccessibilityLabel` | `String Function(int)?` | `null` | Screen reader value for a data index. |
| `children` | `List<Widget>` | `const []` | Extra elements painted on top, such as `CdsScrubber` or `CdsReferenceLine`. |

`CdsBarPlot` draws the bars inside a `CdsCartesianChart`; it takes `seriesIds` plus the bar options above. `cdsBarLayout(data, ...)` returns the computed `CdsBarGeometry` list for custom painters.

## Examples

### Stacked with a gap

```dart
const CdsBarChart(
  height: 220,
  stacked: true,
  stackGap: 2,
  showXAxis: true,
  showYAxis: true,
  legend: CdsLegend(),
  xAxis: CdsAxisConfig(data: ['Mon', 'Tue', 'Wed', 'Thu']),
  yAxisStyle: CdsYAxis(showGrid: true),
  series: [
    CdsChartSeries(id: 'buys', label: 'Buys', data: [30, 42, 25, 50], color: CdsColor.fgPositive),
    CdsChartSeries(id: 'sells', label: 'Sells', data: [20, 18, 33, 21], color: CdsColor.fgNegative),
  ],
)
```

### Horizontal

```dart
const CdsBarChart(
  height: 160,
  layout: CdsChartLayout.horizontal,
  showYAxis: true,
  yAxis: CdsAxisConfig(data: ['A', 'B', 'C']),
  yAxisStyle: CdsYAxis(position: CdsYAxisPosition.left),
  series: [CdsChartSeries(id: 'a', data: [12, 30, 21])],
)
```

## Accessibility

- The chart is one semantics container labeled with a summary of every series (lowest, highest and latest value). Override it with `accessibilityLabel` when values need units.
- With `enableScrubbing`, the chart is adjustable: its value reads the scrubbed (or latest) point, and screen reader users swipe up and down to step through points. `getScrubberAccessibilityLabel` formats that value.
- Keyboard: focus the chart, then Left and Right (Up and Down in horizontal charts) move the scrubber, Home and End jump to the ends, Escape clears. A focus ring shows for keyboard focus.
- Pair series colors with a legend or labels; color alone never identifies a series.

## Motion

- On first data, lines and areas reveal from the start edge over 500ms and bars grow from the baseline; points and beacons fade in after 350ms (CDS accessory timing).
- Data changes morph every element from its current shape to the new one with the CDS update spring (stiffness 900, damping 120). Point arrays of different lengths are resampled, so switching datasets never jumps. A resize snaps instead of morphing.
- Scrubbing follows the finger 1:1 and snaps to the nearest data index. A selection haptic fires only when the index changes.
- Reduced motion: everything changes instantly. Nothing animates at rest.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `series` (`BarSeries`) | `series` (`CdsChartSeries`) |
| `stacked`, `layout`, `barPadding`, `borderRadius`, `fillOpacity` | same names |
| `stackGap`, `barMinSize`, `roundBaseline` | same names |
| `stackMinSize`, `stroke`, `strokeWidth` | not ported |
| `BarComponent`, `BarStackComponent`, `transitions` | not ported |
| `BarPlot` | `CdsBarPlot` |
