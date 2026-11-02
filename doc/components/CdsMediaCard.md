# CdsMediaCard

A card split into a text half (with a thumbnail) and a media half.

CDS reference: https://cds.coinbase.com/components/cards/MediaCard

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsMediaCard(
  thumbnail: const CdsAvatar(name: 'Ethereum'),
  subtitle: 'ETH',
  title: 'Ethereum',
  description: 'Sample data',
  media: CdsRemoteImage(source: art, width: double.infinity, height: double.infinity, shape: CdsShape.rectangle),
  onPress: () => openAsset('ETH'),
)
```

## When to use / when not to

Use for asset and collection tiles. It replaces `CdsContainedAssetCard` and `CdsFloatingAssetCard` in CDS.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `thumbnail` | `Widget` | required | Image, avatar or icon at the top of the text half. |
| `title` / `titleNode` | `String?` / `Widget?` | `null` | Up to two `headline` lines. |
| `subtitle` / `subtitleNode` | `String?` / `Widget?` | `null` | One muted `legal` line above the title. |
| `description` / `descriptionNode` | `String?` / `Widget?` | `null` | Up to two muted `label2` lines. |
| `media` | `Widget?` | `null` | Fills its half at full height. Without media, the text half fills the card. |
| `mediaPlacement` | `CdsMediaCardMediaPlacement` | `end` | `start` or `end`. |
| `background` | `CdsColor` | `bgAlternate` | |
| `onPress` | `VoidCallback?` | `null` | |
| `feedback` | `CdsHapticFeedback` | `none` | |
| `semanticLabel` | `String?` | subtitle, title, description | Card button label when pressable. |

## Accessibility

A pressable card is one button labelled from its text.

## Motion

Pressable cards tint and scale to 0.98 on pointer-down; no scale under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title`, `subtitle`, `description` (string / node) | `x` / `xNode` |
| `thumbnail`, `media`, `mediaPlacement` | same names |
| `renderAsPressable` + `onPress` | `onPress` |
