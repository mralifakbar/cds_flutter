# CdsToast

A brief message at the bottom of the screen that confirms an action, optionally with one action button; shown with `showCdsToast`.

CDS reference: https://cds.coinbase.com/components/overlay/Toast

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
showCdsToast(context, 'Address copied');

showCdsToast(
  context,
  'Sent 25 USDC',
  action: CdsToastAction(label: 'Undo', onPress: undoSend),
);
```

## When to use / when not to

Use to confirm something that just happened. Do not use for errors that need action (use `CdsBanner` or inline errors) or for anything the person must read (toasts disappear).

## Parameters

### showCdsToast

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| context | `BuildContext` | required | Finds the nearest `CdsToastHost`, or the root `Overlay`. |
| text | `String` | required | Message in `headline`. |
| action | `CdsToastAction?` | `null` | One button at the end. Pressing it runs `onPress` and hides the toast. |
| duration | `Duration?` | `null` | Time on screen. Defaults to `cdsToastDuration(text, hasAction:)`. |
| variant | `CdsColor?` | `null` | Color of the one-time tint flash on arrival. Defaults to `bgPrimary`. |
| accessibilityLabel | `String?` | `null` | Announcement text. Defaults to the text plus the action label. |
| onDidHide | `VoidCallback?` | `null` | Called after the toast leaves. |

Durations (CDS toast tokens): 5000ms, plus 2000ms with an action, plus 300ms per 10 characters past 50 (`cdsToastDuration`). Constants: `cdsToastDefaultDuration`, `cdsToastActionDuration`.

### CdsToastAction

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| label | `String` | required | Button label. |
| onPress | `VoidCallback` | required | Called on press. |

### CdsToastHost

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| child | `Widget` | required | The app subtree. |
| bottomOffset | `double?` | `null` | Distance from the bottom. Defaults to the bottom safe-area inset. |

`CdsToastHost.of(context)` returns the `CdsToastController` (nearest host, or the root overlay's when there is no host). Controller: `show(...)`, `hide()`, `clearQueue()`, `hasActiveToast`, `queueLength`.

### CdsToast

The surface only (`text`, `action`, `onActionPress`); use it for previews. `bgAlternate`, 1px `bgLine` border, radius 200, elevation 2.

## Examples

### Host under MaterialApp

```dart
MaterialApp(
  builder: (context, child) => CdsToastHost(child: child!),
  home: const HomePage(),
)
```

### Clear pending toasts

```dart
CdsToastHost.of(context).clearQueue();
```

## Accessibility

- Announced to screen readers when it finishes entering (`SemanticsService.sendAnnouncement`) and marked as a live region.
- The timer pauses while the toast is touched, so people can read it or reach the action.
- The action is a `CdsButton` with a 44px hit area.

## Motion

- Enters by fading in and rising 25px (`moderate3`, enterFunctional) with a single 30% tint flash; leaves the same way (exitFunctional).
- Swipe down, left or right to dismiss: the toast follows the finger, upward drags resist, and release velocity decides between dismissing (with the momentum spring) and springing back.
- Toasts queue: the next one enters after the current one leaves.
- Reduced motion: short fade, no rise or flash.

## CDS React Native mapping

| CDS API | Flutter |
| --- | --- |
| `useToast().show(text, options)` | `showCdsToast(context, text, ...)` |
| `useToast().hide()` | `CdsToastHost.of(context).hide()` |
| `useToast().clearQueue()` | `CdsToastHost.of(context).clearQueue()` |
| `ToastProvider` / `toastBottomOffset` | `CdsToastHost` / `bottomOffset` (optional) |
| `action: {label, onPress}` | `CdsToastAction(label:, onPress:)` |
| `duration`, `variant`, `accessibilityLabel`, `onDidHide` | same names |
