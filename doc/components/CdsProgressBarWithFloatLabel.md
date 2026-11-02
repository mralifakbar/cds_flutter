# CdsProgressBarWithFloatLabel

A progress bar with a numeric label that rides along with the fill, above or below the track.

CDS reference: https://cds.coinbase.com/components/feedback/ProgressBarWithFloatLabel

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsProgressBarWithFloatLabel(progress: 0.6, label: CdsProgressBarLabel(60))
```

## When to use / when not to

Use when the current value is what matters. For start and end values use `CdsProgressBarWithFixedLabels`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| progress | `double` | required | 0 to 1. |
| label | `CdsProgressBarLabel` | required | Value shown at the fill's end. |
| labelPlacement | `CdsProgressLabelPlacement` | `CdsProgressLabelPlacement.above` | `above` or `below` (`beside` asserts). |
| disabled | `bool` | `false` | Dims the label and grays the bar. |
| disableAnimateOnMount | `bool` | `false` | Start at the value. |
| weight | `CdsProgressWeight` | `CdsProgressWeight.normal` | Bar weight. |
| color | `CdsColor` | `CdsColor.bgPrimary` | Bar fill. |
| accessibilityLabel | `String?` | `null` | Bar label. |
| child | `Widget?` | `null` | Custom bar. |

The label's end edge tracks the fill's end and never leaves the track. Label color `fgMuted`.

## Examples

### Below the bar

```dart
const CdsProgressBarWithFloatLabel(
  progress: 0.25,
  label: CdsProgressBarLabel(25),
  labelPlacement: CdsProgressLabelPlacement.below,
)
```

## Accessibility

The bar carries the semantic value; the floating label is excluded to avoid reading the number twice.

## Motion

Label position and number animate with the bar over `slow3` (global curve). Reduced motion: instant.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `label` | `label` (`CdsProgressBarLabel`) |
| `labelPlacement` | `labelPlacement` |
| `progress`, `disabled`, `disableAnimateOnMount` | same |
| `children` | `child` |
