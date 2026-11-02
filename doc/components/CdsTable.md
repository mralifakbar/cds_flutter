# CdsTable

A data table built from `CdsTableCaption`, `CdsTableHeader`, `CdsTableBody` and `CdsTableFooter`, with rows of `CdsTableCell`s.

CDS reference: https://cds.coinbase.com/components/data-display/Table

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTable(
  variant: CdsTableVariant.ruled,
  children: [
    const CdsTableCaption('Holdings'),
    CdsTableHeader(children: [
      CdsTableRow(children: const [
        CdsTableCell(title: 'Asset'),
        CdsTableCell(title: 'Balance', alignItems: CrossAxisAlignment.end),
      ]),
    ]),
    CdsTableBody(children: [
      for (final h in holdings)
        CdsTableRow(
          onPress: () => openHolding(h),
          semanticLabel: 'Open ${h.name}',
          children: [
            CdsTableCell(title: h.name, subtitle: h.symbol),
            CdsTableCell(title: h.balance, alignItems: CrossAxisAlignment.end),
          ],
        ),
    ]),
  ],
)
```

## When to use / when not to

Use for tabular data people compare across columns. On phones, prefer `CdsListCell` lists for one or two values per item.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | `CdsTableCaption`, `CdsTableHeader`, `CdsTableBody`, `CdsTableFooter`. Rendered in table order regardless of list order. |
| `variant` | `CdsTableVariant` | `standard` | `standard` (no lines), `ruled` (lines between rows), `graph` (lines between rows and columns). |
| `bordered` | `bool` | `false` | 1px `bgLine` border, 8px corners. |
| `tableLayout` | `CdsTableLayout` | `auto` | `auto`: columns size to content, extra width is shared, the table scrolls horizontally when wider than its parent. `fixed`: columns share the width (`FlexColumnWidth`), no horizontal scroll. |
| `compact` | `bool` | `false` | 8px cell padding instead of 16px. |
| `cellPaddingX` / `cellPaddingY` | `double?` | `2` (`1` compact) | Space tokens for every cell. |
| `columnWidths` | `Map<int, TableColumnWidth>?` | `null` | Per-column widths; win over `CdsTableCell.width`. |
| `height` | `double?` | `null` | Fixed height; rows scroll vertically. |
| `maxHeight` | `double?` | `null` | Rows scroll vertically past it. |
| `semanticLabel` | `String?` | `null` | Table name for screen readers. |

### CdsTableHeader / CdsTableBody / CdsTableFooter

`const CdsTableHeader({required List<CdsTableRow> children})`, same for body and footer. Header cells use muted `headline` and are marked as headers; body cells use `body` in `fg`; footer cells use `body` in `fgMuted`.

### CdsTableRow

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | `CdsTableCell` or `CdsTableCellFallback`, one per column. Short rows are padded with empty cells. |
| `backgroundColor` | `CdsColor?` | `null` | |
| `color` | `CdsColor?` | `null` | Text color for the row's cells. |
| `disableHoverIndicator` | `bool` | `false` | Body rows tint on hover (gray 5 at 35%) unless set. |
| `onPress` | `VoidCallback?` | `null` | Tap on any cell, or Enter/Space when the row's first cell has focus. |
| `semanticLabel` | `String?` | `null` | Row button label, e.g. "Open Bitcoin". |

### CdsTableCaption

`const CdsTableCaption(String text, {TextAlign align = TextAlign.start, CdsColor? color, CdsColor? backgroundColor})` renders `title3` above the header (with a bottom line in `ruled` and `graph`). `CdsTableCaption.custom(child: ...)` takes any widget.

See also [CdsTableCell](CdsTableCell.md) and [CdsTableCellFallback](CdsTableCellFallback.md).

## Examples

### Sortable column

```dart
CdsTableCell(
  title: 'Price',
  sortDirection: sortBy == 'price' ? direction : CdsTableSortDirection.none,
  onPress: () => toggleSort('price'),
  alignItems: CrossAxisAlignment.end,
)
```

### Loading rows

```dart
CdsTableBody(children: [
  for (var i = 0; i < 5; i++)
    CdsTableRow(children: [
      CdsTableCellFallback(title: true, subtitle: true, start: CdsCellMediaType.asset, rectWidthVariant: i),
      CdsTableCellFallback(title: true, rectWidthVariant: i),
    ]),
])
```

### Empty and error states

Render one row with the message in the first cell, for example `CdsTableRow(children: const [CdsTableCell(title: 'No trades yet', subtitle: 'Place an order to see it here.')])`, or replace the table with an explanation and a retry button.

## Accessibility

Header cells are marked as headers; sortable cells announce "Sorted ascending", "Sorted descending" or "Not sorted". Pressable rows put one focus stop and button role on the first cell, with `semanticLabel`. Cell text wraps by default, so large text grows rows instead of clipping.

## Motion

Pressable rows tint on pointer-down and clear on release. Hover tint is instant. No other motion.

## CDS React Native mapping

Table is a CDS web component; this is a Flutter port of `@coinbase/cds-web` tables.

| CDS prop | Flutter parameter |
| --- | --- |
| `variant="default"` | `variant: CdsTableVariant.standard` (`default` is reserved in Dart) |
| `variant="graph"` / `"ruled"` | same names |
| `bordered`, `tableLayout`, `compact`, `height`, `maxHeight` | same names |
| `cellSpacing` (`inner` / `outer`) | `cellPaddingX`, `cellPaddingY` (net padding) |
| `accessibilityLabel` | `semanticLabel` |
| `TableHeader sticky` | not supported |
| `TableRow fullWidth`, `TableCell colSpan` | not supported (Flutter's `Table` has no column spanning) |
| `TableRow onClick` | `onPress` |
