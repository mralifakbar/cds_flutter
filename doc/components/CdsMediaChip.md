# CdsMediaChip

A chip that leads with media, such as an asset icon or avatar, with the tighter padding CDS uses around it.

CDS reference: https://cds.coinbase.com/components/inputs/MediaChip

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsMediaChip(label: 'Base', start: networkLogo, onPress: () => pick('base'))
```

`start` is any widget. This package does not ship asset logos or avatars; CDS uses a 24px circle.

## When to use / when not to

- Use when the media identifies the option faster than text (assets, networks, people).
- Use `CdsChip` when there is no media.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String?` | `null` | Text after the media. |
| `child` | `Widget?` | `null` | Custom middle content; overrides `label`. |
| `start` | `Widget?` | `null` | Leading media. |
| `end` | `Widget?` | `null` | Trailing icon, e.g. a caret. |
| `onPress` | `VoidCallback?` | `null` | Makes the chip pressable. |
| `size` | `CdsChipSize` | `s` | |
| `active`, `activeBackground`, `activeColor` | | `false`, `null`, `null` | As on `CdsChip`. |
| `background` | `CdsColor` | `bgSecondary` | |
| `color` | `CdsColor` | `fg` | |
| `maxWidth` | `double` | `200` | |
| `numberOfLines` | `int` | `1` | |
| `disabled` | `bool` | `false` | |
| `feedback` | `CdsHapticFeedback` | `light` | |
| `semanticLabel`, `semanticHint` | `String?` | `null` | Give a `semanticLabel` when there is no `label`. |
| `excludeChildSemantics` | `bool` | `false` | |
| `selected` | `bool?` | `null` | Selected state for screen readers. |
| `focusNode`, `autofocus` | | | |

### Padding rules

Spacing comes from `cdsMediaChipSpacing({required bool start, required bool label, required bool end, CdsChipSize size})`, a port of CDS `getMediaChipSpacingProps`. Values are space tokens:

| Slots | Start | End | Vertical | Gap |
| --- | --- | --- | --- | --- |
| label only | 2 (xs 1.5) | 2 (xs 1.5) | 1 (xs 0.75) | 1 |
| media only | 1 | 1 | 1 | 1 |
| media + end | 1 | 1.5 | 1 | 0.75 |
| media + label | 1 | 2 (xs 1.5) | 1 (xs 0.75) | 0.75 |
| label + end | 2 (xs 1.5) | 1.5 | 1 (xs 0.75) | 0.75 |
| media + label + end | 1 | 1.5 | 1 (xs 0.75) | 0.75 |

## Examples

### Network picker

```dart
CdsHStack(gap: 1, wrap: true, children: [
  for (final n in networks)
    CdsMediaChip(
      label: n.name,
      start: n.logo,
      active: selected == n.id,
      selected: selected == n.id,
      onPress: () => setState(() => selected = n.id),
    ),
])
```

### Media with a caret

```dart
CdsMediaChip(
  start: assetLogo,
  end: const CdsIcon(CdsIconName.caretDown, size: CdsIconSize.xs),
  semanticLabel: 'Choose asset',
  onPress: openAssetPicker,
)
```

## Accessibility

Same as `CdsChip`. Media-only chips need `semanticLabel`.

## Motion

Same as `CdsChip`.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `label` / `child` |
| `start`, `end`, `size`, `active`, `onPress` | same names |
| `accessibilityLabel` | `semanticLabel` |
