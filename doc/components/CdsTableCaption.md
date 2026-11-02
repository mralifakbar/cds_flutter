# CdsTableCaption

The title of a `CdsTable`, shown above the header in `title3`.

CDS reference: https://cds.coinbase.com/components/data-display/TableCaption

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

Only valid as part of a `CdsTable`; anywhere else it throws a `FlutterError` that says so. Parameters, examples, accessibility and the CDS mapping are documented in [CdsTable](CdsTable.md#cdstablecaption).

```dart
CdsTable(children: [
  const CdsTableCaption('Holdings'),
  CdsTableHeader(children: [CdsTableRow(children: const [CdsTableCell(title: 'Asset')])]),
  CdsTableBody(children: [CdsTableRow(onPress: openBitcoin, semanticLabel: 'Open Bitcoin', children: const [CdsTableCell(title: 'Bitcoin')])]),
  CdsTableFooter(children: [CdsTableRow(children: const [CdsTableCell(title: 'Total')])]),
])
```
