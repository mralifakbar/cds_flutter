# CdsModalBody

The scrollable content area of a `CdsModal`, between header and footer.

CDS reference: https://cds.coinbase.com/components/overlay/ModalBody

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsModalBody(child: CdsText('Transfers settle in about 2 minutes.'))
```

## When to use / when not to

Place it directly in `CdsModal.children`. It returns a `Flexible`, so it must be a direct child of the modal's column; wrapping it in another widget breaks the layout. Its content scrolls when taller than the space left.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| child | `Widget` | required | Body content. |
| paddingX | `double` | `3` | Horizontal space token. |
| paddingY | `double?` | `null` | Vertical space token. Defaults to 3, or 0 when the modal hides its dividers. |
| controller | `ScrollController?` | `null` | Controller for the body's scroll view. |

In a fullscreen modal (narrow screens) the body fills the remaining height so the footer sits at the bottom; in a card it takes its content height.

## Examples

### Long content

```dart
CdsModalBody(
  child: Column(children: [
    for (var i = 0; i < 20; i++) CdsText('Sample data: transaction ${i + 1}'),
  ]),
)
```

## Accessibility

Content scrolls instead of clipping, so it stays readable at 2x text scale.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `child` |
| `paddingX`, `paddingY` | `paddingX`, `paddingY` |
| ScrollView props | `controller` |
