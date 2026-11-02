# CdsListCellFallback

A loading placeholder shaped like a `CdsListCell`.

CDS reference: https://cds.coinbase.com/components/data-display/ListCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
Column(children: [
  for (var i = 0; i < 4; i++)
    CdsListCellFallback(title: true, description: true, detail: true, media: CdsCellMediaType.asset, rectWidthVariant: i),
])
```

## When to use / when not to

Show while list data loads. Turn on the pieces the loaded cell will have so the layout does not jump.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `bool` | `false` | |
| `subtitle` | `bool` | `false` | |
| `description` | `bool` | `false` | |
| `detail` | `bool` | `false` | |
| `subdetail` | `bool` | `false` | |
| `helperText` | `bool` | `false` | |
| `media` | `CdsCellMediaType?` | `null` | 48px squircle for `image`, 32px circle otherwise. |
| `accessory` | `CdsCellAccessoryType?` | `null` | |
| `accessoryNode` | `Widget?` | `null` | |
| `spacingVariant` | `CdsCellSpacingVariant` | `normal` | Match the loaded cells. |
| `rectWidthVariant` | `int?` | `null` | Varies bar widths deterministically; pass the row index. |
| `innerSpacing` / `outerSpacing` | `CdsCellSpacing?` | per variant | |
| `semanticLabel` | `String?` | `'Loading'` | Read once per placeholder. |

`CdsMediaFallback(CdsCellMediaType type)` is the media placeholder on its own.

## Accessibility

Each placeholder is one node labelled `semanticLabel`; the bars are hidden. Bars use one line height of the matching font, scaled with text size.

## Motion

None. CDS sweeps a shimmer across fallbacks; this port keeps them still so nothing animates on its own.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title`, `subtitle`, `description`, `detail`, `subdetail`, `helperText`, `media`, `accessory`, `accessoryNode` | same names |
| `rectWidthVariant` | `rectWidthVariant` |
| `disableRandomRectWidth` | always on unless `rectWidthVariant` is set |
| `accessibilityLabel` | `semanticLabel` |
