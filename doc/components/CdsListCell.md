# CdsListCell

A row in a list: media, a title with optional subtitle and description, end detail, and a trailing accessory.

CDS reference: https://cds.coinbase.com/components/data-display/ListCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsListCell(
  spacingVariant: CdsCellSpacingVariant.condensed,
  media: CdsCellMedia.asset(source: btcLogo),
  title: 'Bitcoin',
  description: 'BTC',
  detail: r'$64,201.10',
  subdetail: '+2.4%',
  variant: CdsCellDetailVariant.positive,
  accessory: CdsCellAccessoryType.arrow,
  onPress: () => openAsset('BTC'),
)
```

## When to use / when not to

- Use for settings rows, asset lists, transaction lists and selectable options.
- Prefer `spacingVariant: condensed` for new screens; `normal` (the CDS default) and `compact` are deprecated in CDS.
- Use `CdsContentCell` when the description must wrap without a line limit.
- Avoid interactive `end` content (buttons, switches) together with `onPress`: the row is one button for screen readers.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String?` | `null` | `headline`. Two lines, or one when a description is shown outside `condensed`. |
| `titleNode` | `Widget?` | `null` | Custom title; wins over `title`. You own style and truncation. |
| `subtitle` | `String?` | `null` | One muted `label1` line between title and description. |
| `subtitleNode` | `Widget?` | `null` | |
| `description` | `String?` | `null` | Muted `body` (`label2` when condensed). One line with a title, two without, unless `multiline`. |
| `descriptionNode` | `Widget?` | `null` | |
| `detail` | `String?` | `null` | End-aligned `body` value. |
| `detailNode` | `Widget?` | `null` | |
| `subdetail` | `String?` | `null` | Line under `detail`, colored by `variant` (`body`, or `label2` when condensed). |
| `subdetailNode` | `Widget?` | `null` | |
| `variant` | `CdsCellDetailVariant` | `foregroundMuted` | `foregroundMuted`, `negative`, `positive`, `warning`. |
| `media` | `Widget?` | `null` | Leading icon, avatar or image. See `CdsCellMedia`. |
| `intermediary` | `Widget?` | `null` | Between the title stack and the end content. |
| `end` | `Widget?` | `null` | Custom end content; replaces `detail`/`subdetail`. |
| `accessory` | `CdsCellAccessoryType?` | `null` | `arrow`, `more`, `selected`, `unselected`. |
| `accessoryNode` | `Widget?` | `null` | Custom accessory; wins over `accessory`. |
| `helperText` | `Widget?` | `null` | Content under the row, usually `CdsCellHelperText`. |
| `spacingVariant` | `CdsCellSpacingVariant` | `normal` | `normal` (80px min height), `compact` (40px min height), `condensed` (no min height, no outer padding, square corners). |
| `priority` | `Set<CdsCellPriority>` | `{}` | Pieces that keep their natural width when space runs out: `start` (title), `middle` (intermediary), `end`. Others shrink in proportion to their width. |
| `selected` | `bool` | `false` | Fills with `background`, shows a checkmark, sets the selected semantics flag. |
| `disabled` | `bool` | `false` | Dims to 50% and blocks presses. |
| `disableSelectionAccessory` | `bool` | `false` | Keep `accessory` (or none) instead of the checkmark when selected. |
| `disableMultilineTitle` | `bool` | `false` | Always one title line. |
| `multiline` | `bool` | `false` | Description wraps without a limit. |
| `onPress` | `VoidCallback?` | `null` | Makes the row a button. |
| `onLongPress` | `VoidCallback?` | `null` | |
| `background` | `CdsColor` | `bgAlternate` | Fill when selected. |
| `borderRadius` | `int?` | `200`, or `0` when condensed | Radius token of the highlight. |
| `minHeight` | `double?` | per variant | Overrides the variant minimum height. |
| `detailWidth` | `double?` | `null` | Fixed width for the end content. |
| `innerSpacing` | `CdsCellSpacing?` | per variant | Content padding. Default `paddingX: 2, paddingY: 1, marginX: -2`. |
| `outerSpacing` | `CdsCellSpacing?` | per variant | Wrapper padding. Default `paddingX: 3, paddingY: 1`. |
| `feedback` | `CdsHapticFeedback` | `none` | |
| `semanticLabel` | `String?` | `null` | Replaces the label built from the row's text. |
| `semanticHint` | `String?` | `null` | |
| `focusNode` | `FocusNode?` | `null` | |

## Examples

### Selectable options

```dart
for (final currency in ['USD', 'EUR', 'GBP'])
  CdsListCell(
    spacingVariant: CdsCellSpacingVariant.condensed,
    title: currency,
    selected: currency == value,
    accessory: CdsCellAccessoryType.unselected,
    onPress: () => onChange(currency),
  )
```

### Helper text

```dart
CdsListCell(
  title: 'Bank account',
  description: 'Ending in 42',
  helperText: const CdsCellHelperText('Verification pending', variant: CdsCellHelperTextVariant.warning),
)
```

### Keep the balance whole

```dart
CdsListCell(title: longName, detail: balance, priority: const {CdsCellPriority.end})
```

### Loading, empty and error states

Show `CdsListCellFallback` rows while loading. For empty and error states, render a single explanatory row or message that names the cause and the next action, for example `CdsListCell(title: 'No transactions yet', description: 'Buy crypto to see activity here.')`.

## Accessibility

With `onPress`, the row is one button whose label merges its text; `selected` sets the selected flag. Focusable; Enter and Space activate. Helper text prefixes "Warning:" or "Error:" for screen readers, and pairs color with an icon. Text wraps or truncates; nothing clips at 2x text size.

## Motion

Pointer-down tint from `CdsPressable` (no scale, as in CDS). Reduced motion keeps the tint.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title`, `titleNode`, `subtitle`, `subtitleNode`, `description`, `descriptionNode` | same names |
| `detail`, `detailNode`, `subdetail`, `subdetailNode`, `variant` | same names |
| `media`, `intermediary`, `end`, `accessory`, `accessoryNode`, `helperText` | same names |
| `action` (deprecated) | `end` |
| `compact` (deprecated) | `spacingVariant: CdsCellSpacingVariant.compact` |
| `spacingVariant`, `priority`, `selected`, `disabled` | same names (`priority` is a `Set`) |
| `disableSelectionAccessory`, `disableMultilineTitle`, `multiline` | same names |
| `innerSpacing`, `outerSpacing` | `CdsCellSpacing` |
| `detailWidth`, `minHeight`, `borderRadius`, `background` | same names |
| `accessibilityLabel`, `accessibilityHint` | `semanticLabel`, `semanticHint` |
| `styles` | not supported; use the `*Node` slots |
