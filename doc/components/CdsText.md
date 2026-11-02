# CdsText

Text set in the CDS type ramp, colored with semantic tokens.

CDS reference: https://cds.coinbase.com/components/typography/Text

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsText('Portfolio', font: CdsFont.title1)
CdsText.label2('Updated 2 min ago', color: CdsColor.fgMuted)
```

## The ramp

| Font | Size / line height | Weight | Typical use |
| --- | --- | --- | --- |
| `display1` | 64 / 72 | 400 | Hero numbers |
| `display2` | 48 / 56 | 400 | |
| `display3` | 40 / 48 | 400 | Balance on a home screen |
| `title1` | 28 / 36 | 600 | Screen titles |
| `title2` | 28 / 36 | 400 | Large values |
| `title3` | 20 / 28 | 600 | Section titles |
| `title4` | 20 / 28 | 400 | |
| `headline` | 16 / 24 | 600 | Cell titles, button labels |
| `body` | 16 / 24 | 400 | Paragraphs (default) |
| `label1` | 14 / 20 | 600 | Emphasised small text |
| `label2` | 14 / 20 | 400 | Secondary details |
| `caption` | 13 / 16 | 600, uppercase | Overlines |
| `legal` | 13 / 16 | 400 | Disclosures |

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `String` | required (positional) | The text. |
| `font` | `CdsFont` | `body` | Ramp entry. Named constructors (`CdsText.title1(...)`) set it for you. |
| `color` | `CdsColor` | `fg` | Semantic color token. |
| `dangerouslySetColor` | `Color?` | `null` | Raw color escape hatch. |
| `mono` | `bool` | `false` | Use the monospace family for this ramp entry. |
| `tabularNumbers` | `bool` | `false` | Equal-width digits for prices and counters. |
| `align` | `TextAlign?` | `null` | |
| `maxLines` | `int?` | `null` | Truncates with an ellipsis when set. |
| `overflow` | `TextOverflow?` | ellipsis when `maxLines` is set | |
| `softWrap` | `bool?` | `null` | |
| `textTransform` | `CdsTextTransform?` | from the font | Override `caption`'s uppercase. |
| `underline` | `bool` | `false` | |
| `semanticsLabel` | `String?` | `null` | Uppercased text is read as written by default. |

`CdsText.rich(InlineSpan span, ...)` renders spans that inherit the ramp style.

## Examples

```dart
CdsText(r'$12,408.22', font: CdsFont.display3, tabularNumbers: true)
CdsText.label1('+2.4%', color: CdsColor.fgPositive)
CdsText.legal('Prices are indicative.', color: CdsColor.fgMuted)
```

## Accessibility

Scales with the platform text size. Uppercase captions are announced in their original case.

## CDS React Native mapping

| CDS | Flutter |
| --- | --- |
| `<Text font="title1">` / `<TextTitle1>` | `CdsText(font: CdsFont.title1)` / `CdsText.title1()` |
| `color="fgMuted"` | `color: CdsColor.fgMuted` |
| `mono`, `tabularNumbers`, `align`, `numberOfLines` | `mono`, `tabularNumbers`, `align`, `maxLines` |
