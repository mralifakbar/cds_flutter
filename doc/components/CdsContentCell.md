# CdsContentCell

A cell for longer content: a title with meta information beside it, a subtitle, and a description that wraps freely.

CDS reference: https://cds.coinbase.com/components/data-display/ContentCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsContentCell(
  media: const CdsCellMedia.icon(CdsIconName.bell),
  title: 'Price alert',
  meta: '2m ago',
  description: 'Bitcoin rose above your alert price.',
  onPress: openAlert,
)
```

## When to use / when not to

CDS deprecates ContentCell in favour of `CdsListCell`. Use it when the description must wrap without a line limit, such as notifications and messages.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` / `titleNode` | `String?` / `Widget?` | `null` | `headline`; two lines, or one with a description outside `condensed`. |
| `subtitle` / `subtitleNode` | `String?` / `Widget?` | `null` | `label2`, or `label1` when condensed. |
| `description` / `descriptionNode` | `String?` / `Widget?` | `null` | Muted `body`, no line limit. |
| `meta` / `metaNode` | `String?` / `Widget?` | `null` | Muted `label2` at the end of the title line. Needs a title or subtitle. In `condensed`, it moves beside the accessory. |
| `media` | `Widget?` | `null` | Leading media. |
| `accessory` | `CdsCellAccessoryType?` | `null` | |
| `accessoryNode` | `Widget?` | `null` | |
| `spacingVariant` | `CdsCellSpacingVariant` | `normal` | As in `CdsListCell`. |
| `priority` | `Set<CdsCellPriority>` | `{}` | |
| `selected` | `bool` | `false` | Fills with `background` and shows a checkmark. |
| `disabled` | `bool` | `false` | |
| `onPress` / `onLongPress` | `VoidCallback?` | `null` | |
| `alignItems` | `CrossAxisAlignment` | `start` | Vertical alignment of the row pieces. |
| `background` | `CdsColor` | `bgAlternate` | |
| `borderRadius` | `int?` | `200`, `0` when condensed | |
| `innerSpacing` / `outerSpacing` | `CdsCellSpacing?` | per variant | |
| `feedback` | `CdsHapticFeedback` | `none` | |
| `semanticLabel` / `semanticHint` | `String?` | `null` | |
| `focusNode` | `FocusNode?` | `null` | |

## Examples

### Condensed notification

```dart
CdsContentCell(
  spacingVariant: CdsCellSpacingVariant.condensed,
  title: 'Deposit received',
  meta: '9:41',
  description: 'Sample data. Your USDC deposit is available.',
  accessory: CdsCellAccessoryType.arrow,
  onPress: openDeposit,
)
```

## Accessibility

Same as `CdsListCell`: one button with merged text when pressable, selected flag when selected.

## Motion

Pointer-down tint, no scale.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title`, `subtitle`, `description`, `meta` and their `*Node` props | same names |
| `media`, `accessory`, `accessoryNode`, `spacingVariant`, `selected`, `disabled`, `onPress` | same names |
| `compact` (deprecated) | `spacingVariant: compact` |
| `accessibilityLabel`, `accessibilityHint` | `semanticLabel`, `semanticHint` |
