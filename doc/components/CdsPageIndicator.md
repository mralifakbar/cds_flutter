# CdsPageIndicator

A row of dots showing which page of a paged view is visible; the active dot stretches into a short bar. `CdsCarousel` uses it as its pagination, and you can pair it with your own `PageView`.

CDS reference: none. This is a cds_flutter extra built from CDS tokens.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsPageIndicator(
  totalPages: 4,
  activePageIndex: page,
  onPressPage: (index) => controller.goToPage(index),
)
```

## When to use / when not to

Use it under paged content to show position. Do not use it as the only way to navigate: the dots are small. Pair it with swipe or previous/next buttons.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `totalPages` | `int` | required | Number of dots. |
| `activePageIndex` | `int` | required | Zero-based active page. |
| `onPressPage` | `ValueChanged<int>?` | `null` | Called with a page index when its dot is pressed. Null makes the dots display-only. |
| `accessibilityLabel` | `String Function(int)?` | `Go to page N` | Label for each dot. |

Dots are 4px tall, 4px wide (24px when active), radius token 100, 4px apart, `bgPrimary` when active and `bgLine` otherwise.

## Examples

### With a PageView

```dart
PageView(
  controller: pageController,
  onPageChanged: (i) => setState(() => page = i),
  children: pages,
),
CdsPageIndicator(
  totalPages: pages.length,
  activePageIndex: page,
  onPressPage: (i) => pageController.animateToPage(i, duration: CdsDurations.moderate3, curve: CdsCurves.global),
)
```

## Accessibility

Each dot is a button with `selected` state and a label. Hit areas are padded to 44px tall; horizontally they are the dot plus its share of the gap, so they stay small.

## Motion

The width change animates over `fast1` with `CdsCurves.global`; instant under reduced motion.

## CDS React Native mapping

| CDS prop (`DefaultCarouselPagination`) | Flutter parameter |
| --- | --- |
| `totalPages` | `totalPages` |
| `activePageIndex` | `activePageIndex` |
| `onPressPage` | `onPressPage` |
| `paginationAccessibilityLabel` | `accessibilityLabel` |
| `variant` (`'pill'`, deprecated) | not ported |
