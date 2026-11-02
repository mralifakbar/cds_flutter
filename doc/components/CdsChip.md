# CdsChip

A compact, pill-shaped element for filters, quick selections and short status. Pressable only when `onPress` is set.

CDS reference: https://cds.coinbase.com/components/inputs/Chip

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsChip(label: 'Gainers', onPress: () => setState(() => filter = 'gainers'))
```

## When to use / when not to

- Use for filter rows, suggestions and small toggles.
- Use `CdsMediaChip` when the chip leads with an asset icon or avatar, and `CdsInputChip` for removable values.
- Do not use as a primary action; use `CdsButton`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String?` | `null` | Text in the middle. |
| `child` | `Widget?` | `null` | Custom middle content; overrides `label`. |
| `start` | `Widget?` | `null` | Leading widget. |
| `end` | `Widget?` | `null` | Trailing widget. |
| `onPress` | `VoidCallback?` | `null` | Makes the chip pressable. |
| `size` | `CdsChipSize` | `s` | `s`: 16/8px padding, `headline`. `xs`: 12/6px padding, `label1`. |
| `active` | `bool` | `false` | Inverts the color scheme inside the chip. |
| `activeBackground` | `CdsColor?` | `null` | Background while active; disables inversion. |
| `activeColor` | `CdsColor?` | `null` | Label color while active; disables inversion. |
| `background` | `CdsColor` | `bgSecondary` | |
| `color` | `CdsColor` | `fg` | Label color. |
| `font` | `CdsFont?` | by size | Overrides the label ramp entry. |
| `maxWidth` | `double` | `200` | Content past this truncates with an ellipsis. |
| `numberOfLines` | `int` | `1` | |
| `gap` | `double` | `1` | Space token between slots and label. |
| `paddingX`, `paddingY`, `paddingStart`, `paddingEnd` | `double?` | by size | Space token overrides. |
| `borderRadius` | `int` | `700` | Radius token (40px). |
| `disabled` | `bool` | `false` | Dims and blocks presses. |
| `feedback` | `CdsHapticFeedback` | `light` | Haptic on press. |
| `semanticLabel` | `String?` | `null` | Replaces the read label. |
| `semanticHint` | `String?` | `null` | |
| `excludeChildSemantics` | `bool` | `false` | Read `semanticLabel` alone. |
| `selected` | `bool?` | `null` | Selected state for screen readers. Pass it for filter chips. |
| `focusNode`, `autofocus` | | | Keyboard focus. |

## Examples

### Filter row

```dart
CdsHStack(gap: 1, wrap: true, children: [
  for (final f in ['All', 'Gainers', 'Losers'])
    CdsChip(label: f, active: filter == f, selected: filter == f, onPress: () => setState(() => filter = f)),
])
```

### With slots, small size

```dart
CdsChip(
  label: 'Sort',
  size: CdsChipSize.xs,
  end: const CdsIcon(CdsIconName.caretDown, size: CdsIconSize.xs),
  onPress: openSort,
)
```

### Explicit active colors

```dart
CdsChip(label: 'Pro', active: true, activeBackground: CdsColor.bgPrimary, activeColor: CdsColor.fgInverse)
```

When you set `activeBackground` or `activeColor`, icons in `start` and `end` are not recolored; give them a matching `color`.

## Accessibility

- A pressable chip is a button; its label is the visible text unless `semanticLabel` is set. Pass `selected` so filter state is announced.
- The hit area is padded to 44px even for `xs`.
- Tab focuses; Enter and Space press.

## Motion

Pressable chips tint and scale to 0.98 on pointer-down (`CdsPressable`). Static chips do not animate.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` (string) | `label` |
| `children` (node) | `child` |
| `start`, `end`, `onPress`, `size`, `active`, `activeBackground`, `activeColor`, `background`, `color`, `font`, `maxWidth`, `numberOfLines`, `gap`, `borderRadius` | same names |
| `compact` (deprecated) | `size: CdsChipSize.xs` |
| `inverted`, `invertColorScheme` (deprecated) | `active` |
| `accessibilityLabel` | `semanticLabel` |
