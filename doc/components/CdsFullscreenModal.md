# CdsFullscreenModal

A full-screen modal with a header (logo slot, title, close button), a primary content column and an optional secondary column, for flows that need the whole screen.

CDS reference: https://cds.coinbase.com/components/overlay/FullscreenModal

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
showCdsFullscreenModal<void>(
  context,
  builder: (context) => const CdsFullscreenModal(
    title: 'Verify your identity',
    primaryContent: CdsText('Have your ID ready. This takes about 3 minutes.'),
  ),
);
```

## When to use / when not to

Use for onboarding, identity verification, or a checkout with a summary panel. For a short task use `CdsModal`; for a blocking outcome message use `CdsFullscreenAlert`; for a custom full-screen layout use `CdsFullscreenModalLayout`.

## Parameters

### showCdsFullscreenModal<T>

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| context | `BuildContext` | required | Context used to find the navigator. |
| builder | `WidgetBuilder` | required | Builds a `CdsFullscreenModal` or `CdsFullscreenModalLayout`. |
| shouldCloseOnEscPress | `bool` | `true` | When false, Escape does nothing. |
| restoreFocusOnUnmount | `bool` | `true` | Return focus to the trigger on close. |
| accessibilityLabel | `String?` | `null` | Names the route for screen readers. |
| useRootNavigator | `bool` | `true` | Push on the root navigator. |
| routeSettings | `RouteSettings?` | `null` | Route name and arguments. |

Returns `Future<T?>` with the value passed to `Navigator.pop`.

### CdsFullscreenModal

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| primaryContent | `Widget` | required | Main content column (max 800px wide). |
| title | `String?` | `null` | Header title in the `title1` style. |
| logo | `Widget?` | `null` | Brand mark at the start of the header. No default: this package ships no Coinbase logos. |
| secondaryContent | `Widget?` | `null` | Below the primary content on phones; a 400px column beside it from 768px. |
| hideDivider | `bool` | `false` | Hide the divider under the header. |
| showSecondaryContentDivider | `bool` | `false` | Divider between primary and secondary content. |
| closeAccessibilityLabel | `String` | `'Close'` | Label of the close button. |
| onRequestClose | `VoidCallback?` | `null` | Close button handler. Defaults to `Navigator.maybePop`. |

Content insets follow CDS web: 32px on phones, an 80px start inset from 560px, side-by-side columns from 768px, a 240px start inset from 1280px. Content scrolls.

## Examples

### With a summary column

```dart
CdsFullscreenModal(
  title: 'Buy Bitcoin',
  primaryContent: const CdsText('Choose an amount and a payment method.'),
  secondaryContent: const CdsText('Sample data: 25 USD, fee 0.99 USD'),
  showSecondaryContentDivider: true,
)
```

## Accessibility

Focus is trapped in the modal and restored on close. Escape and the back button close it. The title is a heading. The close button is labelled and has a 44px hit area.

## Motion

CDS fullscreen modal tokens: fades in and rises 80px over `moderate3` (enterFunctional); leaves the same way over `moderate1` (exitFunctional). The scrim fades with the global curve. Reduced motion: a `fast1` fade only.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `visible`, `onRequestClose` | `showCdsFullscreenModal`, `Navigator.pop`, `onRequestClose` |
| `title` | `title` |
| `logo` | `logo` (slot only, no default logo) |
| `primaryContent` | `primaryContent` |
| `secondaryContent` | `secondaryContent` |
| `hideDivider` | `hideDivider` |
| `showSecondaryContentDivider` | `showSecondaryContentDivider` |
| `closeAccessibilityLabel` | `closeAccessibilityLabel` |
| `shouldCloseOnEscPress`, `restoreFocusOnUnmount`, `accessibilityLabel` | parameters of `showCdsFullscreenModal` |

CDS mobile has no FullscreenModal; this follows CDS web.
