# CdsCell

The layout primitive behind `CdsListCell` and `CdsContentCell`: media, main content, intermediary, end content and accessory in a row, with optional content below.

CDS reference: https://cds.coinbase.com/components/data-display/ListCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCell(
  media: const CdsCellMedia.icon(CdsIconName.wallet),
  end: const CdsText.body(r'$120.00'),
  accessory: const CdsCellAccessory(CdsCellAccessoryType.arrow),
  onPress: openWallet,
  child: const CdsText.headline('Cash'),
)
```

## When to use / when not to

Reach for `CdsListCell` first. Use `CdsCell` for layouts the list cell cannot express.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Main content. Grows into free space. |
| `media` | `Widget?` | `null` | Fixed-size leading media. |
| `intermediary` | `Widget?` | `null` | Natural width; shrinks unless `middle` has priority. |
| `end` | `Widget?` | `null` | Grows into free space; shrinks unless `end` has priority. |
| `accessory` | `Widget?` | `null` | Fixed-size trailing widget. |
| `bottomContent` | `Widget?` | `null` | Under the row, `rowGap` away. |
| `onPress` / `onLongPress` | `VoidCallback?` | `null` | |
| `disabled` | `bool` | `false` | 50% opacity, presses blocked. |
| `selected` | `bool` | `false` | Fills with `background`; selected semantics flag. |
| `priority` | `Set<CdsCellPriority>` | `{}` | |
| `alignItems` | `CrossAxisAlignment` | `center` | |
| `gap` | `double` | `2` | Space token between row pieces. |
| `rowGap` | `double` | `1` | Space token above `bottomContent`. |
| `background` | `CdsColor` | `bgAlternate` | Selected fill. |
| `borderRadius` | `int` | `200` | |
| `bordered` | `bool` | `false` | 1px `bgLine` border. |
| `minHeight` / `maxHeight` | `double?` | `null` | Include the outer spacing. |
| `endWidth` | `double?` | `null` | Fixed end width. |
| `innerSpacing` | `CdsCellSpacing?` | `CdsCellSpacing.defaultInner` | |
| `outerSpacing` | `CdsCellSpacing?` | `CdsCellSpacing.defaultOuter` | |
| `feedback` | `CdsHapticFeedback` | `none` | |
| `semanticLabel` / `semanticHint` | `String?` | `null` | |
| `focusNode` | `FocusNode?` | `null` | |

### CdsCellSpacing

`CdsCellSpacing({double? padding, paddingX, paddingY, paddingTop, paddingBottom, paddingStart, paddingEnd, marginX})`, all space tokens. Presets: `defaultInner` (`paddingX: 2, paddingY: 1, marginX: -2`), `defaultOuter` (`paddingX: 3, paddingY: 1`), `condensedInner` (`paddingX: 3, paddingY: 1, marginX: 0`), `condensedOuter` (all 0). The negative inner `marginX` pulls the press and selection highlight 16px into the gutter while content stays aligned 24px from the edge.

## Examples

### Custom main content

```dart
CdsCell(
  bordered: true,
  child: Row(children: [const CdsText.headline('Network'), const SizedBox(width: 8), const CdsTag('Beta')]),
)
```

## Accessibility

Pressable cells are one button with merged text. Non-pressable cells form one semantics container.

## Motion

Pointer-down tint from `CdsPressable`, no scale.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `child` |
| `media`, `intermediary`, `end`, `accessory`, `bottomContent` | same names |
| `accessoryNode` | `accessory` (already a widget) |
| `detail` (deprecated) | `end` |
| `detailWidth` | `endWidth` |
| `priority`, `selected`, `disabled`, `onPress`, `innerSpacing`, `outerSpacing` | same names |
