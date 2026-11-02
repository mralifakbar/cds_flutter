# CdsTableCellSortIcon

The up and down carets of a sortable column header, with the active direction in `fgPrimary`.

CDS reference: https://cds.coinbase.com/components/data-display/TableCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsTableCellSortIcon(direction: CdsTableSortDirection.ascending)
```

`CdsTableCell(sortDirection: ...)` adds this icon for you; use it directly only in custom cells.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `direction` | `CdsTableSortDirection` | `none` | |

## Accessibility

Decorative; the cell announces the sort state.

## Motion

None.

## CDS React Native mapping

| CDS prop (web) | Flutter parameter |
| --- | --- |
| `direction` (`aria-sort` value) | `direction` |
