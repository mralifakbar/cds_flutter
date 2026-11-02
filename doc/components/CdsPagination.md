# CdsPagination

A row of page buttons with previous and next controls, for moving through paged lists and tables.

CDS reference: https://cds.coinbase.com/components/navigation/Pagination

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsPagination(
  totalPages: 12,
  activePage: page,
  onChange: (next) => setState(() => page = next),
)
```

## When to use / when not to

Use for data split into numbered pages, such as transaction history or a table, where users jump to a specific page. For a short swipeable set of cards use `CdsCarousel` with its page dots. For infinite feeds, load more on scroll instead.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `totalPages` | `int` | required | Number of pages. Values below 1 are treated as 1. |
| `activePage` | `int` | required | Current page, 1-based. Must be within `1..totalPages`. |
| `onChange` | `ValueChanged<int>` | required | Receives the page the user picked. Not called for the current page. |
| `siblingCount` | `int` | `1` | Pages shown on each side of the active page. |
| `boundaryCount` | `int` | `1` | Pages always shown at the start and end. |
| `showFirstLastButtons` | `bool` | `false` | Adds "First" and "Last" text buttons at the ends. |
| `disabled` | `bool` | `false` | Disables every control. |
| `firstPageButtonLabel` | `String` | `'First'` | Text of the first-page button. |
| `lastPageButtonLabel` | `String` | `'Last'` | Text of the last-page button. |
| `accessibilityLabel` | `String` | `'Pagination'` | Label for the whole group. |
| `accessibilityLabels` | `CdsPaginationAccessibilityLabels` | `CdsPaginationAccessibilityLabels()` | Screen reader labels: `next` ('Next page'), `previous` ('Previous page'), `first` ('First page'), `last` ('Last page'), `page` (`(n) => 'Page $n'`). |

`cdsPaginationItems({required int activePage, required int totalPages, int siblingCount = 1, int boundaryCount = 1})` returns the `List<CdsPaginationItem>` the row renders: `CdsPaginationPageItem(page, selected:)` or `CdsPaginationEllipsisItem()`. It is the CDS `usePagination` algorithm and is handy for custom layouts and tests.

## Examples

### With first and last buttons

```dart
CdsPagination(
  totalPages: 40,
  activePage: page,
  showFirstLastButtons: true,
  onChange: (next) => setState(() => page = next),
)
```

### Wider window around the active page

```dart
CdsPagination(
  totalPages: 20,
  activePage: 10,
  siblingCount: 2,
  boundaryCount: 2,
  onChange: (_) {},
)
// 1 2 ... 8 9 [10] 11 12 ... 19 20
```

## Accessibility

- The row is a semantics group labelled `accessibilityLabel`. Each page button reads "Page N"; the current page carries the selected state.
- The ellipsis is hidden from screen readers.
- Left and Right arrow keys move focus between page buttons (mirrored in RTL); Enter or Space activates.
- When previous or next becomes disabled after a press, focus moves to the first or last page button instead of being lost.
- All controls have 44px hit areas. The row wraps instead of overflowing at large text sizes.

## Motion

Buttons use `CdsPressable` press feedback (tint and 0.98 scale on pointer-down). Page changes are instant.

## CDS React Native mapping

CDS ships Pagination for web only; this port follows the web API.

| CDS prop | Flutter parameter |
| --- | --- |
| `totalPages` | `totalPages` |
| `activePage` | `activePage` |
| `onChange` | `onChange` |
| `siblingCount` | `siblingCount` |
| `boundaryCount` | `boundaryCount` |
| `showFirstLastButtons` | `showFirstLastButtons` |
| `disabled` | `disabled` |
| `firstPageButtonLabel` / `lastPageButtonLabel` | `firstPageButtonLabel` / `lastPageButtonLabel` |
| `accessibilityLabel` | `accessibilityLabel` |
| `accessibilityLabels` | `accessibilityLabels` |
| `PaginationPageButtonComponent` and other component overrides | not supported; build a custom row from `cdsPaginationItems` |
