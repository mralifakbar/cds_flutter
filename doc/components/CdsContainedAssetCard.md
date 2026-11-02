# CdsContainedAssetCard

A compact asset tile: a header (usually a logo) over a subtitle, title and description, with extra content in the large size.

CDS reference: https://cds.coinbase.com/components/cards/ContainedAssetCard

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsContainedAssetCard(
  header: CdsRemoteImage(source: btcLogo, size: CdsAvatarSize.xl, shape: CdsShape.circle),
  subtitle: 'BTC',
  title: r'$64,201.10',
  description: '+2.4% today',
  onPress: () => openAsset('BTC'),
)
```

## When to use / when not to

CDS deprecates this card; prefer `CdsMediaCard` for new screens.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `Widget` | required | |
| `title` / `titleNode` | `String?` / `Widget?` | `null` | One `headline` line. Required. |
| `subtitle` / `subtitleNode` | `String?` / `Widget?` | `null` | One muted `legal` line. |
| `description` / `descriptionNode` | `String?` / `Widget?` | `null` | One muted `label2` line. |
| `size` | `CdsAssetCardSize` | `s` | `s`: 156px square. `l`: 327 to 359px wide, `child` fills the end half. |
| `child` | `Widget?` | `null` | Large-size content. |
| `minWidth` / `maxWidth` | `double?` | per size | |
| `onPress` | `VoidCallback?` | `null` | |
| `semanticLabel` | `String?` | subtitle, title, description | |

The card is at least 156px tall and grows with large text instead of clipping.

## Accessibility

A pressable card is one button labelled from its text.

## Motion

Pressable cards tint and scale to 0.98 on pointer-down; no scale under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `header`, `size`, `onPress`, `minWidth`, `maxWidth` | same names |
| `title`, `subtitle`, `description` (string / node) | `x` / `xNode` |
| `children` | `child` |
