# CdsModal

A dialog surface for a focused task (header, scrollable body, footer actions), shown above the current route with `showCdsModal`.

CDS reference: https://cds.coinbase.com/components/overlay/Modal

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
final confirmed = await showCdsModal<bool>(
  context,
  builder: (context) => CdsModal(children: [
    const CdsModalHeader(title: 'Send USDC'),
    const CdsModalBody(child: CdsText('Review the transfer before sending.')),
    CdsModalFooter(
      primaryAction: CdsButton(label: 'Send USDC', onPress: () => Navigator.pop(context, true)),
      secondaryAction: CdsButton(
        label: 'Cancel',
        variant: CdsButtonVariant.secondary,
        onPress: () => Navigator.pop(context, false),
      ),
    ),
  ]),
);
```

## When to use / when not to

Use for a task that needs the person's full attention but is short: confirming details, editing one setting, choosing from a few options.

Do not use for a yes/no confirmation (use `CdsAlert`), for pickers on phones (use `CdsTray`), for multi-step flows that need the whole screen (use `CdsFullscreenModal`), or for information that should not block the page (use `CdsBanner` or `CdsToast`).

## Parameters

### showCdsModal<T>

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| context | `BuildContext` | required | Context used to find the navigator. |
| builder | `WidgetBuilder` | required | Builds the modal, usually a `CdsModal`. |
| disableOverlayPress | `bool` | `false` | When true, tapping the scrim does not close the modal. |
| shouldCloseOnEscPress | `bool` | `true` | When false, Escape does nothing. |
| restoreFocusOnUnmount | `bool` | `true` | Return keyboard focus to the trigger on close. |
| accessibilityLabel | `String?` | `null` | Names the route for screen readers. |
| useRootNavigator | `bool` | `true` | Push on the root navigator. |
| routeSettings | `RouteSettings?` | `null` | Name and arguments for the route. |

Returns `Future<T?>` that completes with the value passed to `Navigator.pop(context, value)`, or `null` when closed by scrim, Escape, back button or the header close button.

### CdsModal

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| children | `List<Widget>` | required | Usually `CdsModalHeader`, `CdsModalBody`, `CdsModalFooter`, in that order. |
| onRequestClose | `VoidCallback?` | `null` | Called by the header close button. Defaults to `Navigator.maybePop`. |
| hideDividers | `bool` | `false` | Remove header and footer dividers and the body's vertical padding. |
| hideCloseButton | `bool` | `false` | Hide the close button in `CdsModalHeader`. |
| width | `double?` | `null` | Fixed card width on wide screens. |
| maxWidth | `double` | `cdsModalMaxWidth` (612) | Card width cap on wide screens. |
| maxHeight | `double?` | `null` | Card height cap. Defaults to the screen height minus 80px above and below. |
| background | `CdsColor?` | `null` | Surface color. Defaults to the elevation surface (`bgElevation2`). |
| borderRadius | `int` | `200` | Radius token for the card on wide screens. |
| elevation | `CdsElevation` | `CdsElevation.level2` | Shadow and surface level. |
| dangerouslyDisableResponsiveness | `bool` | `false` | Keep the centered card on narrow screens. |

Layout: below `cdsModalFullscreenBreakpoint` (768px) the modal fills the screen with square corners and safe-area padding, as CDS does on phones. From 768px it is a centered card, 24px side margin, up to 612px wide.

## Examples

### Hide dividers

```dart
CdsModal(
  hideDividers: true,
  children: [
    const CdsModalHeader(title: 'Price alert set'),
    const CdsModalBody(child: CdsText('Sample data: we will notify you when Bitcoin reaches 70,000 USD.')),
    CdsModalFooter(primaryAction: CdsButton(label: 'Done', onPress: () => Navigator.pop(context))),
  ],
)
```

### Keep the modal open on scrim tap

```dart
showCdsModal<void>(
  context,
  disableOverlayPress: true,
  builder: (context) => CdsModal(children: [
    const CdsModalHeader(title: 'Unsaved changes'),
    const CdsModalBody(child: CdsText('Save your recurring buy before leaving.')),
    CdsModalFooter(primaryAction: CdsButton(label: 'Save recurring buy', onPress: () => Navigator.pop(context))),
  ]),
);
```

## Accessibility

- The route is a separate semantics scope (`scopesRoute`), named by `accessibilityLabel` when given.
- Focus moves into the modal and is trapped there: Tab and Shift+Tab cycle inside. On close, focus returns to the trigger.
- Escape and the Android back button close the modal unless `shouldCloseOnEscPress` is false (Escape only).
- The header title is marked as a heading; close and back buttons have labels (`closeAccessibilityLabel`, `backAccessibilityLabel`) and 44px hit areas.
- The body scrolls, so text at 2x scale never overflows.

## Motion

CDS modal tokens: the dialog fades in over `fast1` and scales from 0.98 to 1 over `moderate3` (enterFunctional); the scrim fades in over `moderate1`. Exit fades and scales back over `fast1` (global curve). Under reduced motion both directions are a `fast1` fade with no scale.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `visible` | Call `showCdsModal`; close with `Navigator.pop` |
| `onRequestClose` | `CdsModal.onRequestClose` (header close) and route pop |
| `onDidClose` | `await showCdsModal(...)` |
| `children` | `children` |
| `hideDividers` | `hideDividers` |
| `hideCloseButton` | `hideCloseButton` |
| `disableOverlayPress` (web) | `showCdsModal(disableOverlayPress:)` |
| `shouldCloseOnEscPress` (web) | `showCdsModal(shouldCloseOnEscPress:)` |
| `restoreFocusOnUnmount` (web) | `showCdsModal(restoreFocusOnUnmount:)` |
| `accessibilityLabel` | `showCdsModal(accessibilityLabel:)` |
| `width`, `maxWidth`, `maxHeight`, `background`, `borderRadius`, `elevation` | same names |
| `dangerouslyDisableResponsiveness` (web) | `dangerouslyDisableResponsiveness` |

Notes: the hidden scale is 0.98, from the CDS `modal` animation tokens. The responsive layout follows CDS web (fullscreen below 768px, card above), which matches CDS mobile's fullscreen modal on phones.
