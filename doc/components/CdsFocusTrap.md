# CdsFocusTrap

Keeps keyboard focus inside its child while on screen and hands it back to the previously focused widget when removed.

CDS reference: https://cds.coinbase.com/components/overlay/FocusTrap

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsFocusTrap(
  onEscPress: close,
  child: const MyCustomDialog(),
)
```

## When to use / when not to

Every CDS modal overlay (modal, alert, tray, drawer, popover, dropdown) already uses it. Use it directly only for custom overlays.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| child | `Widget` | required | Content to trap focus in. |
| onEscPress | `VoidCallback?` | `null` | Called on Escape while focus is inside. |
| disableFocusTrap | `bool` | `false` | Let Tab leave the child at the ends. |
| restoreFocusOnUnmount | `bool` | `true` | Refocus the previously focused widget on unmount. |
| disableAutoFocus | `bool` | `false` | Do not move focus in on mount. |
| disableArrowKeyNavigation | `bool` | `true` | When false, Up/Down also move focus. |

## Examples

### Arrow keys move between buttons

```dart
CdsFocusTrap(
  disableArrowKeyNavigation: false,
  child: Column(children: [
    CdsButton(label: 'Buy Bitcoin', onPress: buy),
    CdsButton(label: 'Sell Bitcoin', onPress: sell),
  ]),
)
```

## Accessibility

Tab and Shift+Tab wrap inside the trap. Focus restoration runs after the trap is torn down so the closing overlay cannot steal it back.

## Motion

None.

## CDS React Native mapping

| CDS prop (web) | Flutter parameter |
| --- | --- |
| `children` | `child` |
| `onEscPress` | `onEscPress` |
| `disableFocusTrap` | `disableFocusTrap` |
| `restoreFocusOnUnmount` | `restoreFocusOnUnmount` |
| `disableArrowKeyNavigation` | `disableArrowKeyNavigation` (default `true` here, `false` in CDS) |
| `focusTabIndexElements`, `respectNegativeTabIndex`, `includeTriggerInFocusTrap` | not applicable to Flutter focus |

The arrow-key default differs from CDS so arrow keys keep working inside multi-line text fields.
