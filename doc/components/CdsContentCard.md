# CdsContentCard

A composable card for feed content, built from `CdsContentCardHeader`, `CdsContentCardBody` and `CdsContentCardFooter`.

CDS reference: https://cds.coinbase.com/components/cards/ContentCard

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsContentCard(
  background: CdsColor.bgAlternate,
  children: [
    const CdsContentCardHeader(title: 'Market update', subtitle: 'News', thumbnail: CdsAvatar(name: 'Market')),
    const CdsContentCardBody(title: 'Bitcoin trading volume rose 12% this week', description: 'Sample data.'),
    CdsContentCardFooter(children: [
      const CdsText.label2('Sample data', color: CdsColor.fgMuted),
      CdsButton(label: 'Share', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: share),
    ]),
  ],
)
```

## When to use / when not to

Use for news, posts and editorial content in a feed. Use `CdsMediaCard` for asset tiles and `CdsMessagingCard` for promotions.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Header, body, footer or any widgets, stacked. |
| `padding` | `double` | `2` | Space token around the content. |
| `gap` | `double` | `2` | Space token between children. |
| `borderRadius` | `int` | `500` | 24px corners. |
| `background` | `CdsColor?` | `null` | No background by default, as in CDS. |
| `bordered` | `bool` | `false` | 1px `bgLine` border. |
| `elevation` | `CdsElevation` | `none` | Shadow plus the matching surface color. |
| `minWidth` | `double` | `280` | |
| `maxWidth` | `double` | `800` | |
| `onPress` | `VoidCallback?` | `null` | Makes the whole card a button. Inner buttons stay separately pressable and reachable. |
| `feedback` | `CdsHapticFeedback` | `none` | |
| `semanticLabel` | `String?` | `null` | Required when `onPress` is set (asserted): what the card opens. |

Sub-widgets: [CdsContentCardHeader](CdsContentCardHeader.md), [CdsContentCardBody](CdsContentCardBody.md), [CdsContentCardFooter](CdsContentCardFooter.md).

## Examples

### Pressable card with inner actions

```dart
CdsContentCard(
  background: CdsColor.bgAlternate,
  onPress: openArticle,
  semanticLabel: 'Read: Staking rewards are now paid weekly',
  children: [
    CdsContentCardHeader(
      title: 'Newsroom',
      actions: CdsIconButton(CdsIconName.more, semanticLabel: 'More options', transparent: true, onPress: openMenu),
    ),
    const CdsContentCardBody(title: 'Staking rewards are now paid weekly'),
  ],
)
```

## Accessibility

A pressable card is one button labelled `semanticLabel`. Its content text remains readable and inner buttons remain separate focus stops; a tap on an inner button does not press the card.

## Motion

Pressable cards tint on pointer-down and scale to 0.98 with `CdsSprings.press`, springing back with `CdsSprings.standard` from wherever they are. No scale under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `children` |
| `padding`, `gap`, `borderRadius`, `minWidth`, `maxWidth` | same names |
| other `VStack` style props | `background`, `bordered`, `elevation` |
| (pressable via wrapping) | `onPress` + `semanticLabel` |
