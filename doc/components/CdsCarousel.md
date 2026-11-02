# CdsCarousel

A horizontally paged row of items with an optional title, previous/next buttons and dot pagination. Use it for browsable sets like featured assets or learning cards.

CDS reference: https://cds.coinbase.com/components/layout/Carousel

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCarousel(
  title: 'Top movers',
  itemWidth: 280,
  onChangePage: (page) => setState(() => this.page = page),
  children: [for (final asset in assets) AssetCard(asset)],
)
```

## When to use / when not to

Use it for a handful of parallel items the user may skim. Do not put content people must see in later pages, and prefer a vertical list when items need comparing.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Items. Each is laid out at `itemWidth`; heights are equalized to the tallest item. |
| `itemWidth` | `double?` | `null` | Item width in px. Null makes each item as wide as the carousel. |
| `gap` | `double` | `1` | Space token between items. |
| `snapMode` | `CdsCarouselSnapMode` | `page` | `item`: every item starts a page until the remaining items fit. `page`: items visible together form a page. |
| `drag` | `CdsCarouselDrag` | `snap` | `none`, `free` (momentum, stops anywhere) or `snap`. |
| `initialPage` | `int` | `0` | Page shown on first layout, without animation. Later changes are ignored. |
| `title` | `String?` | `null` | Title above the carousel, `title3`, one line. |
| `hideNavigation` | `bool` | `false` | Hides previous/next (and play/pause) buttons. |
| `hidePagination` | `bool` | `false` | Hides the dots. |
| `onChangePage` | `ValueChanged<int>?` | `null` | Called after a drag, button, dot, key or autoplay page change. |
| `onDragStart`, `onDragEnd` | `VoidCallback?` | `null` | Drag lifecycle. |
| `autoplay` | `bool` | `false` | Advances pages on a timer, wrapping to the first page. |
| `autoplayInterval` | `Duration` | `3000ms` | Time between autoplay steps. |
| `controller` | `CdsCarouselController?` | `null` | Reads `activePageIndex`/`totalPages` and calls `goToPage`. |
| `accessibilityLabel` | `String?` | `title` or `'Carousel'` | Label of the carousel node. |
| `nextPageAccessibilityLabel` | `String` | `'Next page'` | |
| `previousPageAccessibilityLabel` | `String` | `'Previous page'` | |
| `paginationAccessibilityLabel` | `String Function(int)` | `Go to page N` | Label for each dot. |
| `startAutoplayAccessibilityLabel` | `String` | `'Play Carousel'` | |
| `stopAutoplayAccessibilityLabel` | `String` | `'Pause Carousel'` | |

`CdsCarouselController` is a `ChangeNotifier`: `activePageIndex`, `totalPages` (0 before layout), `goToPage(int)`. Dispose it when you own it.

## Examples

### Narrow items that snap per item

```dart
CdsCarousel(
  itemWidth: 160,
  snapMode: CdsCarouselSnapMode.item,
  hideNavigation: true,
  children: cards,
)
```

### Driven from outside

```dart
final controller = CdsCarouselController();

CdsCarousel(controller: controller, children: cards);
controller.goToPage(2);
```

### Autoplay

```dart
CdsCarousel(title: 'Learn', autoplay: true, children: lessons)
```

## Accessibility

- The carousel is one node labeled with `accessibilityLabel`, value `Page N of M`, and scroll actions (swipe gestures in TalkBack/VoiceOver) that move to the next or previous page. Each item reports `N of M`; only visible items are in the semantics tree.
- Left and Right arrows page when the carousel has focus (mirrored in RTL); a focus ring shows.
- Buttons are `CdsIconButton`s with 44px targets. Dots have 44px tall targets but small horizontal ones, so buttons and swipe stay the primary navigation.

## Motion

- Dragging follows the finger 1:1 from where it was grabbed, with `CdsMotion.rubberband` resistance past the first and last page.
- On release, `CdsMotion.project` turns the finger's velocity into a projected resting point. `snap` picks the page nearest to it (in `page` mode, at most one page from where the drag began); `free` stops at the projection, clamped to the content.
- The settle is a spring that starts with the finger's velocity: `CdsSprings.momentum` after a flick, `CdsSprings.standard` otherwise. Buttons, dots and keys use `standard` from the current position, so presses during motion redirect smoothly.
- Haptic selection fires on page change.
- Autoplay is off by default. It stops as soon as the user drags, hovers, focuses the carousel or presses a control, and stays stopped until they press play. It never runs under reduced motion (the play button is hidden then), pauses while `TickerMode` is off, and its timer is cancelled on dispose.
- Reduced motion: page changes are instant.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` (`CarouselItem` elements) | `children` (any widgets) plus `itemWidth` |
| `drag` | `drag` |
| `snapMode` | `snapMode` |
| `initialPage` | `initialPage` |
| `hideNavigation`, `hidePagination` | same |
| `title` (string or node) | `title` (`String`) |
| `onChangePage`, `onDragStart`, `onDragEnd` | same |
| `autoplay`, `autoplayInterval` (ms) | `autoplay`, `autoplayInterval` (`Duration`) |
| accessibility label props | same names |
| `ref` (`goToPage`) | `controller` |
| `loop` | not supported |
| `NavigationComponent`, `PaginationComponent`, `paginationVariant`, `styles` | not ported |
