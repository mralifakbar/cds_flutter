# CdsAlert

A short, interruptive message that asks the person to confirm or cancel, shown with `showCdsAlert`.

CDS reference: https://cds.coinbase.com/components/overlay/Alert

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
final remove = await showCdsAlert(
  context,
  title: 'Remove wallet?',
  body: 'You can add it again with your recovery phrase.',
  preferredActionLabel: 'Remove wallet',
  preferredActionVariant: CdsButtonVariant.negative,
  dismissActionLabel: 'Cancel',
);
if (remove == true) removeWallet();
```

## When to use / when not to

Use to confirm a destructive or irreversible action, or to report something the person must acknowledge. Keep the body to one or two sentences. Do not use for forms or long content (use `CdsModal`), or for non-blocking status (use `CdsToast` or `CdsBanner`).

## Parameters

### showCdsAlert

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| context | `BuildContext` | required | Context used to find the navigator. |
| title | `String` | required | Title in the `title3` style. |
| body | `String` | required | Message in muted `body` text. |
| preferredActionLabel | `String` | required | Label of the main button. |
| onPreferredActionPress | `VoidCallback?` | `null` | Runs before the alert closes. |
| preferredActionVariant | `CdsButtonVariant` | `CdsButtonVariant.primary` | `primary` or `negative` (destructive). |
| dismissActionLabel | `String?` | `null` | Secondary button label. No secondary button when null. |
| onDismissActionPress | `VoidCallback?` | `null` | Runs before the alert closes. |
| actionLayout | `Axis` | `Axis.horizontal` | `Axis.vertical` stacks buttons, preferred on top. |
| pictogram | `Widget?` | `null` | Illustration above the title. |
| useRootNavigator | `bool` | `true` | Push on the root navigator. |
| routeSettings | `RouteSettings?` | `null` | Route name and arguments. |

Returns `Future<bool?>`: `true` for the preferred action, `false` for the dismiss action, `null` for Escape or back.

### CdsAlert

Same `title`, `body`, `preferredActionLabel`, `onPreferredActionPress`, `preferredActionVariant`, `dismissActionLabel`, `onDismissActionPress`, `actionLayout` and `pictogram` as above, plus:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| onRequestClose | `VoidCallback?` | `null` | Replaces the default close (`Navigator.pop` with `true`/`false`). |

The card is 318px wide max with radius 200, elevation 2. Buttons wrap to 2 lines.

## Examples

### Single acknowledgement

```dart
showCdsAlert(
  context,
  title: 'Transfer submitted',
  body: 'Sample data: 0.01 BTC will arrive in about 30 minutes.',
  preferredActionLabel: 'Done',
);
```

### Long labels, stacked

```dart
showCdsAlert(
  context,
  title: 'Turn off price alerts?',
  body: 'You will stop getting notified about Bitcoin price moves.',
  preferredActionLabel: 'Turn off price alerts',
  dismissActionLabel: 'Keep price alerts',
  actionLayout: Axis.vertical,
);
```

## Accessibility

- The route is named with the title for screen readers; the title is a heading.
- A scrim tap does not close an alert: the person chooses an action. Escape and back close it with `null`.
- Focus is trapped and restored to the trigger.
- Content scrolls at large text sizes; buttons keep 44px hit areas.

## Motion

Same as CDS: the scrim fades in over `moderate1`, the card fades over `fast1` and scales from 0.98 over `moderate3`; exit over `fast1`. Reduced motion: fade only.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `visible`, `onRequestClose` | `showCdsAlert`, result future, `onRequestClose` |
| `title`, `body` | `title`, `body` |
| `pictogram` (name) | `pictogram` (`Widget` slot; illustrations are not ported) |
| `preferredActionLabel`, `onPreferredActionPress`, `preferredActionVariant` | same names |
| `dismissActionLabel`, `onDismissActionPress` | same names |
| `actionLayout` (`'horizontal' \| 'vertical'`) | `actionLayout` (`Axis`) |
