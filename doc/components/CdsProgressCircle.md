# CdsProgressCircle

Circular progress for a known fraction, or a spinning arc while work of unknown length runs.

CDS reference: https://cds.coinbase.com/components/feedback/ProgressCircle

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsProgressCircle(progress: 0.6, size: 64, showLabel: true)
CdsProgressCircle.indeterminate(size: 24)
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `progress` | `double` | required (determinate) | 0 to 1; changes animate over `slow3` with the global curve. |
| `size` | `double` | 48 (determinate), 24 (indeterminate) | Diameter. |
| `weight` | `CdsProgressWeight` | `normal` (4px), `thin` for indeterminate | `thin` 2, `normal` 4, `semiheavy` 8, `heavy` 12. |
| `color` | `CdsColor` | `bgPrimary`, `fgMuted` for indeterminate | Arc color. The track uses `bgLine`. |
| `showLabel` | `bool` | `false` | Percentage in the center. |
| `content` | `Widget?` | `null` | Custom center content. |
| `disabled` | `bool` | `false` | |
| `animate` | `bool` | `true` | Animate value changes. Turn off when `progress` already follows a gesture. |
| `semanticLabel` | `String?` | `'Loading'` for indeterminate | |

## Motion

The indeterminate arc rotates once per second only while it is mounted and on screen. Under reduced motion it holds still and the "Loading" label carries the state.

## Accessibility

Determinate circles expose their value as a percentage; indeterminate ones use a live region.
