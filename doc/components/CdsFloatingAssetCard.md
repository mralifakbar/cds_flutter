# CdsFloatingAssetCard

An asset card whose media floats in its own bordered tile, with text underneath on the page background.

CDS reference: https://cds.coinbase.com/components/cards/FloatingAssetCard

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsFloatingAssetCard(
  media: CdsRemoteImage(source: art, width: double.infinity, height: double.infinity, shape: CdsShape.rectangle),
  subtitle: 'Collection',
  title: 'Genesis drop',
  description: 'Sample data',
  onPress: openCollection,
)
```

## When to use / when not to

CDS deprecates this card; prefer `CdsMediaCard` for new screens.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `media` | `Widget` | required | Fills the 156px tall tile. |
| `title` / `titleNode` | `String?` / `Widget?` | `null` | Up to three `headline` lines. Required. |
| `subtitle` / `subtitleNode` | `String?` / `Widget?` | `null` | One muted `legal` line. |
| `description` / `descriptionNode` | `String?` / `Widget?` | `null` | Up to two muted `label2` lines. |
| `size` | `CdsAssetCardSize` | `s` | Max width 156 (`s`) or 359 (`l`). |
| `onPress` | `VoidCallback?` | `null` | |
| `semanticLabel` | `String?` | subtitle, title, description | |

## Accessibility

A pressable card is one button labelled from its text.

## Motion

Pressable cards tint and scale to 0.98 on pointer-down; no scale under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `media`, `size`, `onPress` | same names |
| `title`, `subtitle`, `description` (string / node) | `x` / `xNode` |
