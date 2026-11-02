# CdsDotStatusColor

A small colored dot that signals status, pinned to a widget or shown inline.

CDS reference: https://cds.coinbase.com/components/other/DotStatusColor

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsDotStatusColor(
  variant: CdsDotVariant.positive,
  pin: CdsDotPinPlacement.bottomEnd,
  overlap: CdsDotOverlap.circular,
  semanticLabel: 'Online',
  child: const CdsAvatar(name: 'Ada', size: CdsAvatarSize.xxl),
)
```

## When to use / when not to

Use for presence and attention markers. Color alone does not reach everyone: set `semanticLabel`, and show the status in text nearby where you can.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `CdsDotVariant` | required | `positive` (`bgPositive`), `negative` (`bgNegative`), `primary` (`bgPrimary`), `foregroundMuted` (`fgMuted`), `warning` (`bgWarning`). |
| `size` | `CdsIconSize` | `s` | Diameter: xs 12, s 16, m 24, l 32. |
| `pin` | `CdsDotPinPlacement?` | `topEnd` with a child | |
| `overlap` | `CdsDotOverlap?` | `null` | |
| `child` | `Widget?` | `null` | |
| `semanticLabel` | `String?` | `null` | The status the color stands for. Without it the dot is hidden from screen readers. |

## Accessibility

See above: always pair with `semanticLabel` or visible text.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `variant`, `size`, `pin`, `overlap` | same names |
| `children` | `child` |
| `accessibilityLabel` | `semanticLabel` |
