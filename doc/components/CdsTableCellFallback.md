# CdsTableCellFallback

A loading placeholder for one table cell.

CDS reference: https://cds.coinbase.com/components/data-display/TableCellFallback

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTableRow(children: const [
  CdsTableCellFallback(title: true, subtitle: true, start: CdsCellMediaType.asset),
  CdsTableCellFallback(title: true),
])
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `bool` | `false` | 24px bar. |
| `subtitle` | `bool` | `false` | 16px bar. |
| `start` | `CdsCellMediaType?` | `null` | Leading media placeholder. |
| `end` | `CdsCellMediaType?` | `null` | Trailing media placeholder. |
| `titleWidth` | `double` | `96` | Base width in px. |
| `subtitleWidth` | `double` | `64` | Base width in px. |
| `rectWidthVariant` | `int?` | `null` | Varies widths deterministically; pass the row index. |
| `width` | `double?` | `null` | Fixed column width, like `CdsTableCell.width`. |
| `semanticLabel` | `String?` | `'Loading cell'` | |

## Accessibility

Each placeholder is one node labelled `semanticLabel`.

## Motion

None. CDS animates a shimmer; this port keeps placeholders still.

## CDS React Native mapping

| CDS prop (web) | Flutter parameter |
| --- | --- |
| `title`, `subtitle`, `start`, `end`, `rectWidthVariant`, `width` | same names |
| percentage bar widths | `titleWidth`, `subtitleWidth` in px (intrinsic columns have no width to take a percentage of) |
| `accessibilityLabel` | `semanticLabel` |
