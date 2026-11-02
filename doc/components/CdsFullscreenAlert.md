# CdsFullscreenAlert

A full-screen alert for important outcomes (a failed transfer, a locked account) that the person must read and respond to.

CDS reference: https://cds.coinbase.com/components/overlay/FullscreenAlert

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
final retry = await showCdsFullscreenAlert(
  context,
  title: 'Transfer failed',
  body: 'Your bank declined the transfer. Try another payment method.',
  preferredActionLabel: 'Try again',
  dismissActionLabel: 'Close',
);
```

## When to use / when not to

Use when the outcome changes what the person can do next and deserves the whole screen. For quick confirmations use `CdsAlert`.

## Parameters

### showCdsFullscreenAlert

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| context | `BuildContext` | required | Context used to find the navigator. |
| title | `String` | required | Title in `title3`. |
| body | `String` | required | Muted body text. |
| preferredActionLabel | `String` | required | Main button label. |
| onPreferredActionPress | `VoidCallback?` | `null` | Runs before closing. |
| preferredActionVariant | `CdsButtonVariant` | `CdsButtonVariant.primary` | `primary` or `negative`. |
| dismissActionLabel | `String?` | `null` | Secondary button label. |
| onDismissActionPress | `VoidCallback?` | `null` | Runs before closing. |
| heroSquare | `Widget?` | `null` | Illustration above the title. |
| closeAccessibilityLabel | `String` | `'Close'` | Close button label. |
| useRootNavigator | `bool` | `true` | Push on the root navigator. |
| routeSettings | `RouteSettings?` | `null` | Route name and arguments. |

Returns `Future<bool?>`: `true` preferred, `false` dismiss, `null` close button, Escape or back.

### CdsFullscreenAlert

Same fields as above (without navigator options), plus `onRequestClose` (`ValueChanged<bool?>?`, default `null`), which replaces `Navigator.pop(result)`.

Layout: content centered; actions at the bottom, stacked full width on phones (preferred on top) and side by side from 560px.

## Examples

### Destructive outcome

```dart
showCdsFullscreenAlert(
  context,
  title: 'Close your account?',
  body: 'Withdraw your balance first. Closed accounts cannot be reopened.',
  preferredActionLabel: 'Close account',
  preferredActionVariant: CdsButtonVariant.negative,
  dismissActionLabel: 'Keep account',
);
```

## Accessibility

Route named by the title; title is a heading; focus trapped and restored; close button labelled with a 44px hit area; content scrolls at 2x text.

## Motion

Fullscreen modal motion: fade and 80px rise (`moderate3` in, `moderate1` out). Reduced motion: fade only.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `visible`, `onRequestClose` | `showCdsFullscreenAlert`, `onRequestClose` |
| `title`, `body` | same |
| `heroSquare` (name) | `heroSquare` (`Widget` slot) |
| `preferredActionLabel`, `onPreferredActionPress`, `preferredActionVariant` | same |
| `dismissActionLabel`, `onDismissActionPress` | same |
| `closeAccessibilityLabel` | same |

CDS mobile has no FullscreenAlert; this follows CDS web.
