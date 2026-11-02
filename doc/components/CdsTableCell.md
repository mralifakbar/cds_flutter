# CdsTableCell

One cell of a `CdsTableRow`: a title with optional subtitle, or any child, with optional start and end widgets.

CDS reference: https://cds.coinbase.com/components/data-display/TableCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsTableCell(title: 'Bitcoin', subtitle: 'BTC', start: CdsCellMedia.icon(CdsIconName.wallet))
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String?` | `null` | `headline` in the header, `body` elsewhere. |
| `subtitle` | `String?` | `null` | `label2` under the title. |
| `child` | `Widget?` | `null` | Custom content; replaces title and subtitle. Plain `Text` inherits the section style. |
| `start` | `Widget?` | `null` | Before the content. |
| `end` | `Widget?` | `null` | After the content. |
| `color` | `CdsColor?` | row color, then section default | Color of all text. |
| `titleColor` | `CdsColor?` | `null` | Wins over `color`. |
| `subtitleColor` | `CdsColor` | `fgMuted` | |
| `direction` | `CdsTableCellDirection` | `vertical` | `horizontal` lays title and subtitle in a row. |
| `justifyContent` | `MainAxisAlignment?` | `start` (vertical) / `spaceBetween` (horizontal) | |
| `alignItems` | `CrossAxisAlignment?` | `start` (vertical) / `center` (horizontal) | `end` right-aligns numeric columns (mirrored in RTL). |
| `overflow` | `TextOverflow?` | `null` | Truncates to one line. Needs a column width (`width`, `columnWidths` or `tableLayout: fixed`). |
| `width` | `double?` | `null` | Fixed column width; the first cell in a column that sets it wins. |
| `paddingX` / `paddingY` | `double?` | table padding | Space tokens. |
| `onPress` | `VoidCallback?` | `null` | Makes the cell pressable, e.g. to sort. |
| `sortDirection` | `CdsTableSortDirection?` | `null` | Marks the cell sortable: `none`, `ascending`, `descending`. Shows `CdsTableCellSortIcon`, colors the active column `fgPrimary`, sets the semantics value. |
| `semanticLabel` | `String?` | `null` | Replaces the cell's text for screen readers. |

`CdsTableCellSortIcon({CdsTableSortDirection direction = none})` is the up/down caret pair on its own.

## Examples

### Right-aligned amount

```dart
const CdsTableCell(title: r'$64,201.10', alignItems: CrossAxisAlignment.end)
```

### Truncating in a fixed column

```dart
const CdsTableCell(title: 'A long transaction memo', width: 140, overflow: TextOverflow.ellipsis)
```

## Accessibility

Header cells are marked as headers. Sort state is announced as the cell's value.

## Motion

Pressable cells tint on pointer-down (no scale).

## CDS React Native mapping

| CDS prop (web) | Flutter parameter |
| --- | --- |
| `title`, `subtitle`, `children`, `start`, `end`, `color`, `titleColor`, `subtitleColor` | `title`, `subtitle`, `child`, `start`, `end`, `color`, `titleColor`, `subtitleColor` |
| `direction`, `justifyContent`, `alignItems`, `overflow`, `width` | same names |
| `onClick` | `onPress` |
| `useSortableCell` / `aria-sort` | `sortDirection` + `onPress` |
| `innerSpacing`, `outerSpacing` | `paddingX`, `paddingY` |
| `as="th"`, `scope`, `colSpan` | not supported |
