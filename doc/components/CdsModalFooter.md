# CdsModalFooter

The action row at the bottom of a `CdsModal`: one primary action and an optional secondary action.

CDS reference: https://cds.coinbase.com/components/overlay/ModalFooter

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsModalFooter(
  primaryAction: CdsButton(label: 'Save', onPress: save),
  secondaryAction: CdsButton(label: 'Cancel', variant: CdsButtonVariant.secondary, onPress: close),
)
```

## When to use / when not to

Use as the last child of `CdsModal`. Use `direction: Axis.vertical` when labels are too long to sit side by side.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| primaryAction | `Widget` | required | Usually a `CdsButton`. |
| secondaryAction | `Widget?` | `null` | Usually a secondary `CdsButton`. |
| direction | `Axis` | `Axis.horizontal` | Horizontal: secondary then primary, equal widths. Vertical: primary on top. |
| paddingX | `double` | `3` | Horizontal space token. |
| paddingY | `double` | `2` | Vertical space token. |

`CdsButton` actions are stretched to full width automatically (CDS sets `block` on footer buttons). Other widgets are laid out as given. Buttons are 8px apart.

## Examples

### Stacked actions

```dart
CdsModalFooter(
  direction: Axis.vertical,
  primaryAction: CdsButton(label: 'Turn on two-step verification', onPress: enable),
  secondaryAction: CdsButton(label: 'Not now', variant: CdsButtonVariant.secondary, onPress: close),
)
```

## Accessibility

Buttons keep their own labels and 44px hit areas. Visual order matches focus order.

## Motion

None of its own.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `primaryAction` | `primaryAction` |
| `secondaryAction` | `secondaryAction` |
| `direction` | `direction` (`Axis`) |
| `paddingX`, `paddingY` | `paddingX`, `paddingY` |
