# CdsLineChart

A line chart with optional area fill, points, axes and scrubbing, built on `CdsCartesianChart`.

CDS reference: https://cds.coinbase.com/components/charts/LineChart

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsLineChart(
  height: 200,
  showArea: true,
  enableScrubbing: true,
  series: [CdsLineSeries(id: 'prices', data: [10, 22, 29, 45, 98, 45, 22], color: CdsColor.fgPositive)],
  children: [CdsScrubber()],
)
```

## When to use / when not to

- Use it for values over time or across ordered categories, one or many series.
- Add `CdsScrubber` to `children` with `enableScrubbing: true` so people can read exact values.
- Use `CdsBarChart` for discrete comparisons and `CdsSparkline` for tiny inline trends.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `series` | `List<CdsLineSeries>` | `const []` | Series with optional per-series overrides of the styling below. |
| `curve` | `CdsChartCurve` | `bump` | `bump`, `catmullRom`, `linear`, `monotone`, `natural`, `step`, `stepBefore`, `stepAfter`, `basis`. |
| `type` | `CdsChartLineType` | `solid` | `solid` or `dotted`. |
| `showArea` | `bool` | `false` | Fill under each line. |
| `areaType` | `CdsChartAreaType` | `gradient` | `gradient` (30% to 0% toward the baseline), `solid` or `dotted`. |
| `strokeWidth` | `double` | `2` | Line width. |
| `opacity` | `double` | `1` | Opacity of lines, areas and points. |
| `points` | `bool` | `false` | Draw a `CdsPoint` at every value. |
| `connectNulls` | `bool` | `false` | Bridge null values instead of leaving gaps. |
| `showXAxis`, `showYAxis` | `bool` | `false` | Render the axes. |
| `xAxis`, `yAxis` | `CdsAxisConfig` | `const CdsAxisConfig()` | Scale configuration. See `CdsCartesianChart`. |
| `xAxisStyle` | `CdsXAxis?` | `null` | Visual options for the x axis, used when `showXAxis` is true. |
| `yAxisStyle` | `CdsYAxis?` | `null` | Visual options for the y axis, used when `showYAxis` is true. |
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
| `focusNode` | `FocusNode?` | `null` | Focus node for keyboard scrubbing. |

`CdsLineSeries` adds nullable `curve`, `type`, `showArea`, `areaType`, `strokeWidth`, `opacity`, `points` and `connectNulls` to `CdsChartSeries`; set values override the chart-level ones.

To compose lines by hand, use `CdsLine(seriesId: ...)` inside a `CdsCartesianChart`. It takes the same styling plus `stroke`/`dangerouslySetStroke`, `pointBuilder` (return a `CdsPoint` or null per value) and `animate`.

## Examples

### Two series with axes and a legend

```dart
CdsLineChart(
  height: 240,
  showXAxis: true,
  showYAxis: true,
  legend: const CdsLegend(),
  xAxis: const CdsAxisConfig(data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
  yAxisStyle: CdsYAxis(showGrid: true, tickLabelFormatter: (v) => '\$${v.toInt()}'),
  series: const [
    CdsLineSeries(id: 'a', label: 'Series A', data: [12, 18, 15, 22, 20]),
    CdsLineSeries(id: 'b', label: 'Series B', data: [8, 9, 14, 11, 16], color: CdsColor.fgWarning, type: CdsChartLineType.dotted),
  ],
)
```

### Gaps and points

```dart
const CdsLineChart(
  height: 160,
  points: true,
  series: [CdsLineSeries(id: 'a', data: [4, 6, null, 7, 9])],
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
| `series` (`LineSeries`) | `series` (`CdsLineSeries`) |
| `curve`, `type`, `showArea`, `areaType` | same names |
| `strokeWidth`, `opacity`, `points`, `connectNulls` | same names (`points` function form: `CdsLine.pointBuilder`) |
| `showXAxis`, `showYAxis` | same names |
| `xAxis`, `yAxis` (config and visuals) | `xAxis`/`yAxis` (config) and `xAxisStyle`/`yAxisStyle` (visuals) |
| `LineComponent`, `AreaComponent` | not ported; compose `CdsLine`/`CdsArea` in `CdsCartesianChart` |
| `transition`, `transitions` | not ported; CDS default timing is built in |
| other `CartesianChart` props | same as `CdsCartesianChart` |
