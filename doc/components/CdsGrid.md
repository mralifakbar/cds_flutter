# CdsGrid

Arranges children in equal-width columns that wrap into rows. Use a fixed column count, or a minimum column width so the grid adapts to the screen.

CDS reference: https://cds.coinbase.com/components/layout/Grid

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsGrid(
  columns: 2,
  gap: 2,
  children: [for (final asset in assets) AssetTile(asset)],
)
```

## When to use / when not to

Use it for tiles and dashboards where items share a column rhythm. For a single row or column, use `CdsHStack`/`CdsVStack`. For long, scrolling collections, use a `GridView` (it builds lazily).

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Cells. Wrap one in `CdsGridColumn` to span or position it. |
| `columns` | `int?` | `null` | Fixed column count. Wins over `columnMin`. |
| `columnMin` | `double?` | `null` | Minimum column width in px; the count is as many as fit (CSS `auto-fill`). |
| `gap` | `double` | `0` | Space token between rows and columns. |
| `columnGap` | `double?` | `gap` | Space token between columns. |
| `rowGap` | `double?` | `gap` | Space token between rows. |

With neither `columns` nor `columnMin`, the grid has one column. Cells in a row are stretched to the tallest cell. The grid needs a bounded width.

## Examples

### Responsive

```dart
CdsGrid(
  columnMin: 160,
  gap: 1,
  children: tiles,
)
```

### Spans

```dart
CdsGrid(
  columns: 4,
  gap: 1,
  children: [
    CdsGridColumn(colSpan: 4, child: header),
    CdsGridColumn(colSpan: 3, child: chart),
    stats,
  ],
)
```

## Accessibility

Children keep their reading order (row by row, start to end). In RTL the first column is on the right.

## Motion

None.

## CDS React Native mapping

CDS ships `Grid` for web only; this follows the web props.

| CDS prop | Flutter parameter |
| --- | --- |
| `columns` | `columns` |
| `columnMin` | `columnMin` (px) |
| `columnMax` | not ported (always `1fr`) |
| `gap`, `columnGap`, `rowGap` | same |
| `templateColumns`, `rows` | not ported |
