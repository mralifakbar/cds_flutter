# CdsSpinner

An indeterminate loading indicator for waits of unknown length.

CDS reference: https://cds.coinbase.com/components/feedback/Spinner

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsSpinner()
```

## When to use / when not to

Use for short, unknown waits. For buttons use their `loading` flag. For content with a known shape, use `CdsFallback`; for known progress, `CdsProgressBar`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| size | `CdsSpinnerSize` | `CdsSpinnerSize.small` | `small` 20px, `large` 36px. |
| pixelSize | `double?` | `null` | Exact diameter; overrides `size`. |
| color | `CdsColor` | `CdsColor.bgPrimary` | Arc color. |
| animating | `bool` | `true` | False hides it while keeping its space. |
| accessibilityLabel | `String` | `'Loading'` | Announced to screen readers. |

## Examples

### Large

```dart
const CdsSpinner(size: CdsSpinnerSize.large)
```

## Accessibility

A live region labelled "Loading" by default.

## Motion

Built on `CdsProgressCircle.indeterminate`: spins only while on screen; under reduced motion it holds still and still announces loading.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `size` (`'small' \| 'large'`) | `size` (`CdsSpinnerSize`) |
| `size` (number, web) | `pixelSize` |
| `color` | `color` |
| `animating` | `animating` |
| `accessibilityLabel` | `accessibilityLabel` |
