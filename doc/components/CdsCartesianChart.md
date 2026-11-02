# CdsCartesianChart

The shared chart frame: it computes scales from the series, reserves space for axes, handles scrubbing, and paints chart elements given as children.

CDS reference: https://cds.coinbase.com/components/charts/CartesianChart

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsCartesianChart(
  height: 200,
  enableScrubbing: true,
  series: [CdsChartSeries(id: 'prices', data: [10, 22, 29, 45, 98, 45, 22])],
  children: [
    CdsYAxis(showGrid: true),
    CdsLine(seriesId: 'prices'),
    CdsScrubber(),
  ],
)
```

## When to use / when not to

- Use it to combine element types: bars with a line, reference lines, labeled points.
- Use `CdsLineChart`, `CdsAreaChart` or `CdsBarChart` when one element type is enough; they build this for you.
- Children paint in order. Put axes first so grid lines sit behind data, and `CdsScrubber` last.
- Elements read the chart through `CdsCartesianChartScope.of(context)`, which exposes scales, the drawing area and series for custom painters.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `series` | `List<CdsChartSeries>` | `const []` | Data series. Elements refer to them by `id`. |
| `layout` | `CdsChartLayout` | `vertical` | `vertical`: x is the category axis. `horizontal`: y is the category axis. |
| `xAxis` | `CdsAxisConfig` | `const CdsAxisConfig()` | Scale for x. The category axis defaults to `linear` with a `strict` domain of 0 to length - 1. |
| `yAxis` | `CdsAxisConfig` | `const CdsAxisConfig()` | Scale for y. The value axis defaults to a `nice` domain over every value (stacked totals when series share a `stackId`). |
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
| `autofocus` | `bool` | `false` | Focus the chart on first build. |

### CdsChartSeries

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | `String` | required | Unique id. |
| `data` | `List<double?>` | `const []` | Values in category order. `null` (or NaN) leaves a gap. |
| `label` | `String?` | `null` | Name for legends, beacon labels and screen readers. |
| `color` | `CdsColor?` | `null` | Color token. Defaults to `fgPrimary`. |
| `dangerouslySetColor` | `Color?` | `null` | Raw color, for spectrum palettes: `context.cds.spectrum.of(CdsHue.blue, 60)`. |
| `stackId` | `String?` | `null` | Series sharing a stack id stack on each other (positives up, negatives down). |
| `legendShape` | `CdsLegendShape` | `circle` | `circle`, `square`, `squircle` or `pill`. |

### CdsAxisConfig

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `scaleType` | `CdsAxisScaleType?` | `null` | `linear` or `band`. Defaults to `linear`; bar charts default the category axis to `band`. |
| `data` | `List<String>?` | `null` | Category labels; also sets the number of positions. |
| `domain` | `CdsAxisDomain?` | `null` | Fix `min` and/or `max`. Unset sides come from the data. |
| `domainLimit` | `CdsDomainLimit?` | `null` | `nice` rounds outward (value axis default), `strict` uses exact bounds (category axis default). |
| `categoryPadding` | `double?` | `null` | Empty fraction of each band, 0 to 1. Defaults to 0.3. |
| `baseline` | `double?` | `null` | Value bars and areas grow from. Defaults to 0. |
| `includeBaseline` | `bool` | `false` | Extend a computed domain to contain the baseline. Bar and area charts turn it on. |

## Examples

### Bars with a price line and a target

```dart
const CdsCartesianChart(
  height: 240,
  xAxis: CdsAxisConfig(scaleType: CdsAxisScaleType.band, data: ['Q1', 'Q2', 'Q3', 'Q4']),
  yAxis: CdsAxisConfig(includeBaseline: true),
  legend: CdsLegend(),
  series: [
    CdsChartSeries(id: 'volume', label: 'Volume', data: [40, 55, 38, 61], color: CdsColor.bgLineHeavy),
    CdsChartSeries(id: 'price', label: 'Price', data: [52, 48, 57, 60]),
  ],
  children: [
    CdsXAxis(),
    CdsYAxis(showGrid: true),
    CdsBarPlot(seriesIds: ['volume']),
    CdsLine(seriesId: 'price', curve: CdsChartCurve.monotone),
    CdsReferenceLine(dataY: 50, label: 'Target'),
  ],
)
```

### Reading the scrubbed index

```dart
CdsCartesianChart(
  height: 200,
  enableScrubbing: true,
  onScrubberPositionChange: (index) => debugPrint('scrubbed '),
  series: const [CdsChartSeries(id: 'a', data: [3, 5, 4, 6])],
  children: const [CdsLine(seriesId: 'a'), CdsScrubber()],
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
| `series` | `series` (`CdsChartSeries`) |
| `children` | `children` |
| `layout` | `layout` |
| `animate` | `animate` |
| `xAxis`, `yAxis` (config) | `xAxis`, `yAxis` (`CdsAxisConfig`, one axis each) |
| `inset` | `inset` |
| `legend` (`true` or node) | `legend` (`const CdsLegend()` or any widget) |
| `legendPosition` | `legendPosition` |
| `enableScrubbing`, `onScrubberPositionChange` | same names |
| `getScrubberAccessibilityLabel` | `getScrubberAccessibilityLabel` |
| `accessibilityLabel` | `accessibilityLabel` |
| `width`, `height` | `width`, `height` |
| `fontFamilies`, `fontProvider` | not needed; labels use the theme typography |
| series `gradient` | not ported |
