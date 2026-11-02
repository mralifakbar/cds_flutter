# CdsGridColumn

Places a child of `CdsGrid` across several columns or at a specific column.

CDS reference: https://cds.coinbase.com/components/layout/GridColumn

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsGrid(
  columns: 4,
  children: [
    CdsGridColumn(colSpan: 2, child: summary),
    CdsGridColumn(colStart: 4, child: action),
  ],
)
```

## When to use / when not to

Only as a direct child of `CdsGrid`. Plain children span one column, so wrap only cells that need more.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Cell content. |
| `colSpan` | `int` | `1` | Columns to cover, clamped to the grid's column count. |
| `colStart` | `int?` | `null` | 1-based column to start at. If the current row is already past it, the cell moves to the next row. |

## Examples

### Full-width header

```dart
CdsGridColumn(colSpan: 12, child: header)
```

## Accessibility

No semantics of its own.

## Motion

None.

## CDS React Native mapping

| CDS prop (web) | Flutter parameter |
| --- | --- |
| `colSpan` | `colSpan` |
| `colStart` | `colStart` |
| `colEnd`, `gridColumn` | not ported; use `colStart` + `colSpan` |
