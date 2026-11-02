# CdsButtonGroup

Lays out related buttons in a row or column with the CDS 8px gap.

CDS reference: https://cds.coinbase.com/components/layout/ButtonGroup

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsButtonGroup(
  block: true,
  children: [
    CdsButton(label: 'Sell', variant: CdsButtonVariant.secondary, onPress: sell),
    CdsButton(label: 'Buy', onPress: buy),
  ],
)
```

## When to use / when not to

Use it for two or three actions that belong together, such as Buy and Sell. Keep one primary button per group.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Usually `CdsButton`s. |
| `block` | `bool` | `false` | Share the full width equally. `CdsButton` children are rebuilt with `block: true`. |
| `direction` | `Axis` | `Axis.horizontal` | `Axis.vertical` stacks the buttons at full width. |
| `accessibilityLabel` | `String?` | `null` | Names the group for screen readers. |

Without `block`, a horizontal row that runs out of width shrinks its buttons (labels ellipsize) instead of overflowing.

## Examples

### Vertical

```dart
CdsButtonGroup(
  direction: Axis.vertical,
  children: [
    CdsButton(label: 'Buy Bitcoin', onPress: buy),
    CdsButton(label: 'Not now', variant: CdsButtonVariant.secondary, onPress: dismiss),
  ],
)
```

## Accessibility

With `accessibilityLabel` the group is a labeled container; each button keeps its own semantics and 44px target.

## Motion

None beyond the buttons' own press feedback.

## CDS React Native mapping

CDS ships `ButtonGroup` for web only.

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `children` |
| `block` | `block` |
| `direction` (`'horizontal' \| 'vertical'`) | `direction` (`Axis`) |
| `accessibilityLabel` | `accessibilityLabel` |
