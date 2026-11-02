# CdsModalHeader

The title row of a `CdsModal`, with an optional back button at the start and a close button at the end.

CDS reference: https://cds.coinbase.com/components/overlay/ModalHeader

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsModalHeader(title: 'Choose a network')
```

## When to use / when not to

Use as the first child of `CdsModal`. For custom headers (an asset icon next to the title), pass `titleWidget`. Do not use outside a modal; the close button reads its behavior from the enclosing `CdsModal`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| title | `String?` | `null` | Centered title in the `headline` style. |
| titleWidget | `Widget?` | `null` | Custom title content; overrides `title`. |
| onBackButtonClick | `VoidCallback?` | `null` | Shows a back arrow at the start when set. |
| backAccessibilityLabel | `String` | `'Back'` | Screen reader label of the back button. |
| closeAccessibilityLabel | `String` | `'Close'` | Screen reader label of the close button. |
| paddingX | `double` | `3` | Horizontal space token. |
| paddingY | `double` | `2` | Vertical space token. |

The close button calls `CdsModal.onRequestClose` (default `Navigator.maybePop`) and is hidden when `CdsModal.hideCloseButton` is true. The bottom divider is hidden when `CdsModal.hideDividers` is true.

## Examples

### Back navigation inside a modal

```dart
CdsModalHeader(
  title: 'Network fee',
  onBackButtonClick: () => setState(() => step = 0),
)
```

## Accessibility

The title is marked as a heading. Both buttons are `CdsIconButton`s with required labels and 44px hit areas.

## Motion

None of its own; buttons give press feedback through `CdsPressable`.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title` (string) | `title` |
| `title` (node) | `titleWidget` |
| `onBackButtonClick` | `onBackButtonClick` |
| `backAccessibilityLabel` | `backAccessibilityLabel` |
| `closeAccessibilityLabel` | `closeAccessibilityLabel` |
| `paddingX`, `paddingY` | `paddingX`, `paddingY` |
