# CdsFullscreenModalLayout

A bare full-screen surface for custom full-screen modal layouts; `showCdsFullscreenModal` adds the motion, scrim and focus trap.

CDS reference: https://cds.coinbase.com/components/overlay/FullscreenModalLayout

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
showCdsFullscreenModal<void>(
  context,
  builder: (context) => const CdsFullscreenModalLayout(
    child: Center(child: CdsText('Sample data: onboarding step 1 of 3')),
  ),
);
```

## When to use / when not to

Use when `CdsFullscreenModal`'s header and columns do not fit your design. Remember to give people a way to close (a close button calling `Navigator.pop`); Escape and back also close.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| child | `Widget` | required | The full layout. |
| background | `CdsColor` | `CdsColor.bg` | Surface color. |
| safeArea | `bool` | `true` | Keep `child` clear of the notch and home indicator. |

## Examples

### With a close button

```dart
CdsFullscreenModalLayout(
  child: Column(children: [
    Align(
      alignment: AlignmentDirectional.centerEnd,
      child: CdsIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () => Navigator.pop(context)),
    ),
    const Expanded(child: Center(child: CdsText('Sample data: your portfolio summary'))),
  ]),
)
```

## Accessibility

The route traps and restores focus. Provide your own labelled close control.

## Motion

Provided by `showCdsFullscreenModal` (fade and 80px rise, reduced motion fades only).

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `child` |
| `visible`, `onRequestClose`, `shouldCloseOnEscPress`, `restoreFocusOnUnmount`, `accessibilityLabel` | `showCdsFullscreenModal` parameters |

In CDS this component owns the motion and focus trap; in Flutter the route does, and this widget is the surface.
