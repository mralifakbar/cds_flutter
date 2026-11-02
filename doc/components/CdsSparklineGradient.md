# CdsSparklineGradient

A sparkline whose line darkens from left to right in light mode, with an optional dotted area.

CDS reference: https://cds.coinbase.com/components/charts/SparklineGradient

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsSparklineGradient(data: [4, 6, 5, 8, 7, 9], width: 64, height: 20, color: CdsColor.fgPositive)
```

## When to use / when not to

- Use it where CDS products use SparklineGradient: asset rows that want a little more depth than a flat line.
- It is the same as `CdsSparkline(strokeType: CdsSparklineStrokeType.gradient)` with a dotted fill. Prefer `CdsSparkline` for new code.
- CDS turns the gradient off in dark mode; so does this port.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `List<double>` | required | Values in time order. Non-finite values are skipped. |
| `height` | `double` | required | Height in logical pixels. |
| `width` | `double?` | `null` | Defaults to the parent's width. |
| `color` | `CdsColor` | `CdsColor.fgPrimary` | Line color token. The gradient runs from this color to a 30% darker shade. |
| `dangerouslySetColor` | `Color?` | `null` | Raw line color. Takes precedence over `color`. |
| `yAxisScalingFactor` | `double?` | `null` | Below 1 shows less variance, above 1 more. |
| `fill` | `bool` | `false` | Fill the area with the dot pattern. |
| `semanticLabel` | `String?` | `null` | Screen reader label. Defaults to the lowest, highest and latest value. |

## Examples

### With dotted area

```dart
const CdsSparklineGradient(data: [4, 6, 5, 8, 7, 9, 12], height: 80, fill: true)
```

## Accessibility

Same as `CdsSparkline`: one image node labeled with a value summary.

## Motion

Data changes morph over 450ms (ease-out-quint), instantly under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `path` | `data` |
| `color` | `color` or `dangerouslySetColor` |
| `yAxisScalingFactor` | `yAxisScalingFactor` |
| `children` (`SparklineArea`) | `fill: true` |
