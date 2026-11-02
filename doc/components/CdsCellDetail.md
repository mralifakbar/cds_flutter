# CdsCellDetail

End-aligned detail and subdetail text of a cell, such as a balance and its change.

CDS reference: https://cds.coinbase.com/components/data-display/ListCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsCellDetail(detail: r'$4,201.10', subdetail: '+2.4%', variant: CdsCellDetailVariant.positive)
```

## When to use / when not to

`CdsListCell` builds this from `detail` and `subdetail`. Use it in `CdsCell.end`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `detail` | `String?` | `null` | One `body` line. |
| `detailNode` | `Widget?` | `null` | Wins over `detail`. |
| `subdetail` | `String?` | `null` | One line colored by `variant`. |
| `subdetailNode` | `Widget?` | `null` | Wins over `subdetail`. |
| `variant` | `CdsCellDetailVariant` | `foregroundMuted` | `foregroundMuted`, `negative`, `positive`, `warning`. |
| `subdetailFont` | `CdsFont` | `label2` | |

## Accessibility

Pair color with a sign or word ("+2.4%", "Failed") so meaning does not rest on color.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| all props | same names |
