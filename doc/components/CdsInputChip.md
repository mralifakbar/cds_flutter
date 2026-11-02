# CdsInputChip

A removable chip for a value the user entered or picked, such as a selected asset in a multi-select. Pressing it removes the value.

CDS reference: https://cds.coinbase.com/components/inputs/InputChip

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsInputChip(label: 'BTC', onPress: () => setState(() => selected.remove('BTC')))
```

## When to use / when not to

- Use to show chosen values that can be removed one at a time.
- Do not use for filters that toggle on and off; use `CdsChip` with `active`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | required | The value. |
| `onPress` | `VoidCallback?` | `null` | Removes the value. `null` shows a non-interactive chip. |
| `start` | `Widget?` | `null` | Leading media. |
| `size` | `CdsChipSize` | `s` | |
| `active` | `bool` | `true` | Inverted colors, as in CDS. |
| `activeBackground`, `activeColor` | `CdsColor?` | `null` | Paint explicit active colors instead of inverting. |
| `maxWidth` | `double` | `200` | |
| `disabled` | `bool` | `false` | |
| `feedback` | `CdsHapticFeedback` | `light` | |
| `semanticLabel` | `String?` | `'Remove $label'` | |
| `focusNode` | `FocusNode?` | `null` | |

## Examples

### Selected assets

```dart
CdsHStack(gap: 1, wrap: true, children: [
  for (final a in selected)
    CdsInputChip(label: a, onPress: () => setState(() => selected.remove(a))),
])
```

### Not inverted

```dart
CdsInputChip(label: 'ETH', active: false, onPress: remove)
```

## Accessibility

Announced as a button labeled "Remove BTC" (from `semanticLabel`); the close icon is decorative. After removal, move focus to a sensible neighbor if the removed chip had keyboard focus.

## Motion

Same as `CdsChip`.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` / `value` (deprecated) | `label` |
| `onPress`, `start`, `active`, `size` | same names |
| `accessibilityLabel` (default `Remove ${children}`) | `semanticLabel` (same default) |
