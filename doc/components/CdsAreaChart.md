# CdsAreaChart

Filled regions under one or more series, optionally stacked, built on `CdsCartesianChart`.

CDS reference: https://cds.coinbase.com/components/charts/AreaChart

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsAreaChart(
  height: 200,
  stacked: true,
  type: CdsChartAreaType.gradient,
  series: [
    CdsAreaSeries(id: 'a', data: [4, 6, 5, 8], color: CdsColor.fgPositive),
    CdsAreaSeries(id: 'b', data: [2, 3, 4, 3], color: CdsColor.fgWarning),
  ],
)
```

## When to use / when not to

- Use it for volumes or totals over time, and `stacked: true` for part-to-whole over time.
- Use `CdsLineChart(showArea: true)` for a single price line with a soft fill.
- The value axis always includes the baseline (0 by default), so areas start from zero.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `series` | `List<CdsAreaSeries>` | `const []` | Series with optional `type`, `curve`, `fillOpacity` and `lineType` overrides. |
| `stacked` | `bool` | `false` | Stack every series without its own `stackId`. |
| `type` | `CdsChartAreaType` | `solid` | `solid`, `gradient` or `dotted`. |
| `curve` | `CdsChartCurve` | `bump` | Curve for edges. |
| `fillOpacity` | `double` | `1` | Fill opacity. |
| `connectNulls` | `bool` | `false` | Bridge null values. |
| `showLines` | `bool` | `false` | Draw a line along the top of each area. |
| `lineType` | `CdsChartLineType` | `solid` | Style of those lines. |
| `strokeWidth` | `double` | `2` | Width of those lines. |
| `showXAxis`, `showYAxis` | `bool` | `false` | Render the axes. |
| `xAxis`, `yAxis` | `CdsAxisConfig` | `const CdsAxisConfig()` | Scale configuration. |
| `xAxisStyle`, `yAxisStyle` | `CdsXAxis?`, `CdsYAxis?` | `null` | Visual axis options. |
| `layout` | `CdsChartLayout` | `vertical` | Chart orientation. |
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

For composition, `CdsArea(seriesId: ...)` inside a `CdsCartesianChart` takes `type`, `curve`, `fill`/`dangerouslySetFill`, `fillOpacity`, `connectNulls` and `animate`.

## Examples

### Stacked with outlines and a legend

```dart
CdsAreaChart(
  height: 220,
  stacked: true,
  showLines: true,
  type: CdsChartAreaType.gradient,
  legend: const CdsLegend(),
  series: [
    CdsAreaSeries(id: 'a', label: 'Series A', data: const [3, 4, 6, 5], dangerouslySetColor: context.cds.spectrum.of(CdsHue.blue, 60)),
    CdsAreaSeries(id: 'b', label: 'Series B', data: const [2, 2, 3, 4], dangerouslySetColor: context.cds.spectrum.of(CdsHue.teal, 50)),
  ],
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
| `series` (`AreaSeries`) | `series` (`CdsAreaSeries`) |
| `stacked`, `type`, `curve`, `fillOpacity`, `connectNulls` | same names |
| `showLines`, `lineType`, `strokeWidth` | same names |
| `showXAxis`, `showYAxis`, `xAxis`, `yAxis` | same names plus `xAxisStyle`/`yAxisStyle` |
| `AreaComponent`, `LineComponent`, `transitions` | not ported |
