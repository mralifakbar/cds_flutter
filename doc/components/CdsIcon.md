# CdsIcon

A glyph from the CDS icon font: 552 icons, each drawn at 12, 16 and 24px with an outline and an active (filled) variant.

CDS reference: https://cds.coinbase.com/components/media/Icon

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsIcon(CdsIconName.arrowLeft)
CdsIcon(CdsIconName.home, active: true, color: CdsColor.fgPrimary)
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `CdsIconName` | required (positional) | Use the enum; names match CDS web (`'arrowLeft'` is `CdsIconName.arrowLeft`). `factory` is `factoryIcon`. Brand logos from the original font (Coinbase, Base, Apple, Google, social networks, PayPal) are not included. |
| `size` | `CdsIconSize` | `m` | `xs` 12, `s` 16, `m` 24, `l` 32. |
| `pixelSize` | `double?` | `null` | Exact size; overrides `size`. The closest source glyph (12/16/24) is used. |
| `active` | `bool` | `false` | Filled variant for selected states. |
| `color` | `CdsColor` | `fg` | |
| `dangerouslySetColor` | `Color?` | `null` | |
| `semanticLabel` | `String?` | `null` | Without it the icon is decorative and hidden from screen readers. |

## Finding an icon

- Browse the Icons page in the example app (search by name or keyword).
- Look up from a CDS web name: `CdsIconGlyph.byCdsName('wallet')`.
- Keyword search data lives in a separate import so apps that do not need it do not ship it:
  `import 'package:cds_flutter/cds_icon_keywords.dart';` then `cdsIconKeywords[CdsIconName.wallet]`.

## Accessibility

Decorative by default. When an icon is the only carrier of meaning (a status mark with no text), pass `semanticLabel`.

## CDS React Native mapping

| CDS | Flutter |
| --- | --- |
| `<Icon name="add" size="m" color="fgMuted" active />` | `CdsIcon(CdsIconName.add, size: CdsIconSize.m, color: CdsColor.fgMuted, active: true)` |
