# CdsProgressBarWithFixedLabels

A progress bar with fixed numeric labels at its start and end, placed above, below or beside the track.

CDS reference: https://cds.coinbase.com/components/feedback/ProgressBarWithFixedLabels

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsProgressBarWithFixedLabels(
  progress: 0.3,
  startLabel: CdsProgressBarLabel(30),
  endLabel: CdsProgressBarLabel(100),
  labelPlacement: CdsProgressLabelPlacement.below,
)
```

## When to use / when not to

Use when the start and end values matter (raised versus goal). For a label that follows the fill, use `CdsProgressBarWithFloatLabel`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| progress | `double` | required | 0 to 1. |
| startLabel | `CdsProgressBarLabel?` | `null` | Label at the start. |
| endLabel | `CdsProgressBarLabel?` | `null` | Label at the end. |
| labelPlacement | `CdsProgressLabelPlacement` | `CdsProgressLabelPlacement.beside` | `above`, `below`, `beside`. |
| disabled | `bool` | `false` | Dims labels and grays the bar. |
| disableAnimateOnMount | `bool` | `false` | Labels and bar start at their values. |
| weight | `CdsProgressWeight` | `CdsProgressWeight.normal` | Bar weight. |
| color | `CdsColor` | `CdsColor.bgPrimary` | Bar fill. |
| accessibilityLabel | `String?` | `null` | Bar label. |
| child | `Widget?` | `null` | Custom bar; defaults to a `CdsProgressBar` from `progress`. |

### CdsProgressBarLabel

`const CdsProgressBarLabel(double value, {Widget Function(double value, bool disabled)? render})`. Default text is `'${value.round()}%'` in `label2` with tabular figures; the number counts from its previous value.

## Examples

### Custom label text

```dart
CdsProgressBarWithFixedLabels(
  progress: 0.6,
  startLabel: CdsProgressBarLabel(3, render: (v, _) => CdsText('Sample data: ${v.round()} of 5 steps')),
  labelPlacement: CdsProgressLabelPlacement.above,
)
```

## Accessibility

The bar exposes its percentage; labels are plain text read in order. Labels never clip at large text sizes.

## Motion

Bar and numbers animate together over `slow3` (global curve) from their current values. Reduced motion: instant.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `startLabel`, `endLabel` (`number \| {value, render}`) | `CdsProgressBarLabel(value, render:)` |
| `labelPlacement` | `labelPlacement` |
| `disabled`, `disableAnimateOnMount` | same |
| `children` (ProgressBar) | `child` (optional; built from `progress` by default) |
