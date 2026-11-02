# CdsSparklineInteractive

A full-width price chart with period tabs. Drag across it (or long-press and drag) to read values; the header above can follow along.

CDS reference: https://cds.coinbase.com/components/charts/SparklineInteractive

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsSparklineInteractive<String>(
  data: {
    '1D': [
      CdsChartDataPoint(value: 10, date: DateTime(2025, 1, 1, 9)),
      CdsChartDataPoint(value: 14, date: DateTime(2025, 1, 1, 12)),
      CdsChartDataPoint(value: 12, date: DateTime(2025, 1, 1, 15)),
    ],
  },
  periods: const [CdsSparklinePeriod(label: '1D', value: '1D')],
  defaultPeriod: '1D',
  formatDate: (date, period) => '${date.hour}:00',
)
```

## When to use / when not to

- Use it for the main price chart on an asset screen: one series, several periods, scrubbing.
- Pair it with `CdsSparklineInteractiveHeader` through `headerNode` and update the header from `onScrub`.
- Use `CdsLineChart` for multiple series, axes or custom elements. CDS marks SparklineInteractive as deprecated in favor of LineChart.
- Provide every period's data up front, or an empty list while loading (the fallback shows).

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `Map<T, List<CdsChartDataPoint>>?` | required | Points per period, in time order. Missing or empty shows `fallback`. |
| `periods` | `List<CdsSparklinePeriod<T>>` | required | Tabs under the chart: `label` is shown, `value` keys into `data`. |
| `defaultPeriod` | `T` | required | Period selected on first build. Later selections are internal. |
| `formatDate` | `String Function(DateTime, T)` | required | Formats the five date labels shown under the chart while scrubbing, and screen reader values. |
| `onPeriodChanged` | `ValueChanged<T>?` | `null` | Called when a period tab is pressed. |
| `onScrubStart` | `VoidCallback?` | `null` | Called once when scrubbing begins. |
| `onScrub` | `ValueChanged<CdsChartScrubParams<T>>?` | `null` | Called each time the scrubbed data point changes (not on every pointer move). |
| `onScrubEnd` | `VoidCallback?` | `null` | Called when the finger lifts, the gesture cancels or Escape is pressed. |
| `disableScrubbing` | `bool` | `false` | Turns off drag, long-press and keyboard scrubbing. |
| `strokeColor` | `CdsColor` | `CdsColor.fgPrimary` | Line, scrub line and selected period color. |
| `dangerouslySetStrokeColor` | `Color?` | `null` | Raw line color, for asset brand colors. |
| `fallback` | `Widget?` | `null` | Shown when the selected period has no data. Defaults to a static placeholder line. |
| `fallbackType` | `CdsSparklineFallbackType` | `positive` | Direction of the default placeholder line. |
| `compact` | `bool` | `false` | 120px chart instead of 320px. |
| `height` | `double?` | `null` | Plot height in logical pixels. Defaults to 320, or 120 when `compact`. |
| `hidePeriodSelector` | `bool` | `false` | Hides the period tabs. |
| `fill` | `bool` | `true` | Fill the area under the line. |
| `fillType` | `CdsSparklineFillType` | `gradient` | `gradient`, or `dotted` (dots fading toward the bottom). |
| `formatHoverDate` | `String Function(DateTime, T)?` | `null` | Formats the date shown above the scrub point. Omit to hide it. |
| `formatHoverPrice` | `String Function(double)?` | `null` | Formats values for screen readers. Defaults to a plain number. |
| `headerNode` | `Widget?` | `null` | Content above the chart, usually a `CdsSparklineInteractiveHeader`. |
| `timePeriodGutter` | `double?` | `null` | Space token around the period selector. |
| `periodSelectorPlacement` | `CdsSparklinePeriodSelectorPlacement` | `below` | Put the tabs `above` or `below` the chart. |
| `yAxisScalingFactor` | `double` | `1.0` | Below 1 shows less variance, above 1 more. |
| `hideMinMaxLabel` | `bool` | `false` | Hides the highest and lowest value labels. |
| `formatMinMaxLabel` | `String Function(double)?` | `null` | Formats the highest and lowest value labels. |
| `gutter` | `double` | `3` | Space token for horizontal padding (24px). |
| `disableHorizontalPadding` | `bool` | `false` | Skip the padding when the parent already provides it. |
| `focusNode` | `FocusNode?` | `null` | Focus node for keyboard scrubbing. |

`CdsChartScrubParams<T>` carries `point` (`CdsChartDataPoint`), `period`, `index`, and the point's pixel `x` and `y`.

## Examples

### Header that follows the scrubber

```dart
class PriceChart extends StatefulWidget {
  const PriceChart({super.key, required this.points});

  final List<CdsChartDataPoint> points;

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  final _header = CdsSparklineInteractiveHeaderController();

  @override
  void dispose() {
    _header.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CdsSparklineInteractive<String>(
      data: {'1D': widget.points},
      periods: const [CdsSparklinePeriod(label: '1D', value: '1D')],
      defaultPeriod: '1D',
      formatDate: (d, _) => '${d.hour}:${d.minute.toString().padLeft(2, '0')}',
      formatHoverDate: (d, _) => '${d.month}/${d.day} ${d.hour}:00',
      onScrub: (p) => _header.update(title: '\$${p.point.value.toStringAsFixed(2)}'),
      onScrubEnd: _header.reset,
      headerNode: CdsSparklineInteractiveHeader(
        controller: _header,
        defaultLabel: 'Sample asset',
        defaultTitle: '\$${widget.points.last.value.toStringAsFixed(2)}',
      ),
    );
  }
}
```

### Compact, dotted fill, no min and max labels

```dart
CdsSparklineInteractive<int>(
  data: const {0: []},
  periods: const [CdsSparklinePeriod(label: '1W', value: 0)],
  defaultPeriod: 0,
  compact: true,
  hideMinMaxLabel: true,
  fillType: CdsSparklineFillType.dotted,
  formatDate: (d, _) => '${d.month}/${d.day}',
)
```

## Accessibility

- The chart is an adjustable node. Its label reads the period and the lowest, highest and latest value; its value reads the current point (`date, value`). Screen reader users swipe up and down to move through points.
- Keyboard: when focused, Left and Right arrows move the scrub point (the first press starts at the latest point), Escape ends scrubbing. A focus ring shows for keyboard focus.
- Period tabs are buttons with selected state, spoken names (`1D` reads "1 day") and CDS hints ("Show data for the 1 week timeframe").
- Gain and loss should also appear as text in the header, not only as the line color.

## Motion

- The scrub line follows the finger 1:1. The highlighted point, hover date and `onScrub` snap to the nearest data point, and a selection haptic fires each time that point changes.
- Switching periods morphs the line over 450ms with ease-out-quint (CDS `animatedPathConfig`), starting from wherever the line is, so quick taps never jump. The min and max labels fade back in when the morph finishes.
- Labels and the period selector cross-fade over 200ms when scrubbing starts and ends.
- Reduced motion: period changes and fades are instant. The loading placeholder is static; nothing loops.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `data` | `data` |
| `periods` | `periods` (`CdsSparklinePeriod`) |
| `defaultPeriod` | `defaultPeriod` |
| `onPeriodChanged` | `onPeriodChanged` |
| `onScrubStart`, `onScrub`, `onScrubEnd` | same names |
| `disableScrubbing` | `disableScrubbing` |
| `formatDate` | `formatDate` |
| `strokeColor` | `strokeColor` or `dangerouslySetStrokeColor` |
| `fallback`, `fallbackType` | `fallback`, `fallbackType` |
| `compact`, `hidePeriodSelector`, `fill`, `fillType` | same names |
| `formatHoverDate`, `formatHoverPrice` | same names |
| `headerNode` | `headerNode` |
| `hoverData` | not ported |
| `timePeriodGutter`, `periodSelectorPlacement` | same names |
| `yAxisScalingFactor`, `hideMinMaxLabel`, `formatMinMaxLabel` | same names |
| `gutter`, `disableHorizontalPadding` | same names |
| `allowOverflowGestures` | not needed; drags keep tracking outside the chart |
