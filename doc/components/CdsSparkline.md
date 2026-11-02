# CdsSparkline

A small, non-interactive trend line for list rows, cards and tables.

CDS reference: https://cds.coinbase.com/components/charts/Sparkline

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsSparkline(data: [10, 22, 29, 45, 98, 45, 22], width: 64, height: 20, color: CdsColor.fgPositive)
```

## When to use / when not to

- Use it to show the shape of a trend next to a value, such as an asset row with its price.
- Use `fill: true` for a larger standalone sparkline that needs more visual weight.
- Do not use it when people need to read exact values. Use `CdsSparklineInteractive` or `CdsLineChart` with a scrubber.
- CDS marks Sparkline as deprecated in favor of LineChart. It is ported because it is small and cheap for list rows.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `List<double>` | required | Values in time order. Non-finite values are skipped. Downsampled to one point per 3px (LTTB). |
| `height` | `double` | required | Height in logical pixels. |
| `width` | `double?` | `null` | Width in logical pixels. Defaults to the parent's width. |
| `color` | `CdsColor` | `CdsColor.fgPrimary` | Line color token. |
| `dangerouslySetColor` | `Color?` | `null` | Raw line color, for asset brand colors. Takes precedence over `color`. |
| `yAxisScalingFactor` | `double?` | `null` | Below 1 shows less variance, above 1 more (may clip). When set, the path is centered vertically. |
| `strokeType` | `CdsSparklineStrokeType` | `solid` | `gradient` darkens the line from left to right in light mode (solid in dark mode). |
| `fill` | `bool` | `false` | Fill the area under the line. |
| `fillType` | `CdsSparklineFillType` | `dotted` | `dotted` (4px dot pattern, 20% opacity light, 40% dark), `gradient` (30% to 0%), `gradientDotted` (dots fading to the bottom). |
| `semanticLabel` | `String?` | `null` | Screen reader label. Defaults to `Trend: lowest X, highest Y, latest Z`. |

## Examples

### Asset row

```dart
const CdsHStack(
  gap: 2,
  alignItems: CrossAxisAlignment.center,
  children: [
    Expanded(child: CdsText.headline('Sample asset')),
    CdsSparkline(data: [4, 6, 5, 8, 7, 9], width: 64, height: 20, color: CdsColor.fgPositive),
  ],
)
```

### Gradient fill

```dart
const CdsSparkline(
  data: [4, 6, 5, 8, 7, 9, 12, 10],
  height: 120,
  fill: true,
  fillType: CdsSparklineFillType.gradient,
)
```

### Brand color from the spectrum

```dart
CdsSparkline(
  data: const [4, 6, 5, 8],
  width: 64,
  height: 20,
  dangerouslySetColor: context.cds.spectrum.of(CdsHue.orange, 50),
)
```

## Accessibility

The sparkline is one image node. Its label summarizes the lowest, highest and latest value; pass `semanticLabel` with formatted values (currency, units) when the plain numbers are not enough. Do not rely on the line color alone to signal gain or loss; show the change as text next to it.

## Motion

New `data` morphs from the current line to the new one over 450ms with ease-out-quint (the CDS sparkline path timing). Point arrays of different lengths are resampled. Under reduced motion the line changes instantly. Nothing animates at rest.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `path` (from `useSparklinePath`) | `data` (the path is built internally) |
| `width`, `height` | `width`, `height` |
| `color` | `color` or `dangerouslySetColor` |
| `color="auto"` + `background` | not ported; pick a token |
| `yAxisScalingFactor` | `yAxisScalingFactor` |
| `strokeType` | `strokeType` |
| `fillType` | `fillType` |
| `children` (`SparklineArea`) | `fill: true` |
