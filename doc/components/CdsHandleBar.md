# CdsHandleBar

The grab handle at the top of a tray: shows the sheet can be dragged, and screen reader users can activate it to dismiss.

CDS reference: https://cds.coinbase.com/components/overlay/Tray (HandleBar is part of Tray)

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsHandleBar(onAccessibilityPress: close)
```

## When to use / when not to

`CdsTray` and bottom `CdsDrawer` already include one. Use it directly only in a custom sheet.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| variant | `CdsHandleBarVariant` | `CdsHandleBarVariant.outside` | `outside`: 64x4, `bgSecondary`. `inside`: 32x4, `bgInverse` at 40%. |
| onAccessibilityPress | `VoidCallback?` | `null` | Called when a screen reader user activates the handle. |
| accessibilityLabel | `String` | `'Dismiss'` | Screen reader label. |

16px vertical padding around the 4px bar.

## Examples

### Inside variant

```dart
CdsHandleBar(variant: CdsHandleBarVariant.inside, onAccessibilityPress: close)
```

## Accessibility

Exposed as a button with `accessibilityLabel` when `onAccessibilityPress` is set.

## Motion

None; the sheet it belongs to moves.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `variant` | `variant` |
| `onAccessibilityPress` | `onAccessibilityPress` |
| `accessibilityLabel` | `accessibilityLabel` |
| `panHandlers` | not needed: the sheet handles drags |
