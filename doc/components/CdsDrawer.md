# CdsDrawer

A sheet pinned to any screen edge (start, end, top or bottom) with the same drag physics as `CdsTray` along its axis.

CDS reference: closest page is https://cds.coinbase.com/components/overlay/Tray (CDS mobile ships Drawer without a docs page).

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
showCdsDrawer<void>(
  context,
  builder: (context) => const CdsDrawer(
    pin: CdsDrawerPin.start,
    child: CdsText('Sample data: account menu'),
  ),
);
```

## When to use / when not to

Use a start or end drawer for navigation menus or filter panels; a top drawer for short notices. For bottom sheets with a title, prefer `CdsTray`.

## Parameters

### showCdsDrawer<T>

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| context | `BuildContext` | required | Context used to find the navigator. |
| builder | `WidgetBuilder` | required | Builds the `CdsDrawer`. |
| accessibilityLabel | `String?` | `null` | Names the route. |
| useRootNavigator | `bool` | `true` | Push on the root navigator. |
| routeSettings | `RouteSettings?` | `null` | Route name and arguments. |

### CdsDrawer

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| child | `Widget` | required | Drawer content. Side drawers wrap it in a `SafeArea`. |
| pin | `CdsDrawerPin` | `CdsDrawerPin.bottom` | `start`, `end` (follow text direction), `top`, `bottom`. |
| hideHandleBar | `bool` | `false` | Only bottom drawers show a handle. |
| handleBarVariant | `CdsHandleBarVariant` | `CdsHandleBarVariant.outside` | Handle placement for bottom drawers. |
| handleBarAccessibilityLabel | `String` | `'Dismiss'` | Handle label. |
| verticalDrawerPercentageOfView | `double` | `0.75` | Max height share for top and bottom drawers. |
| horizontalDrawerPercentageOfView | `double` | `0.85` | Width share for start and end drawers. |
| preventDismissGestures | `bool` | `false` | Disable swipe and scrim-tap dismissal. |
| onCloseComplete | `VoidCallback?` | `null` | Called after leaving when not shown with `showCdsDrawer`. |
| onOpenComplete | `VoidCallback?` | `null` | Called when the entry settles. |
| accessibilityLabel | `String?` | `null` | Label for the drawer. |
| reduceMotion | `bool?` | `null` | Overrides the platform setting. |

Static: `CdsDrawer.close(BuildContext context, [Object? result])`.

Side drawers have square corners and full height; top drawers round their bottom corners (radius 600).

## Examples

### Filters from the end edge

```dart
showCdsDrawer<void>(
  context,
  builder: (context) => CdsDrawer(
    pin: CdsDrawerPin.end,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: CdsButton(label: 'Show top gainers', onPress: () => CdsDrawer.close(context)),
    ),
  ),
);
```

## Accessibility

Focus trapped and restored; Escape and back close; separate semantics scope. Swipe direction for start/end mirrors in right-to-left layouts.

## Motion

Same as `CdsTray`, along the drawer's axis: 1:1 drag, rubberband past open, velocity projection decides stay or dismiss, `CdsSprings.sheet` with release velocity, interruptible, exits the way it entered, scrim proportional to position. Reduced motion: fades.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `pin` (`'left' \| 'right' \| 'top' \| 'bottom'`) | `pin` (`start`, `end`, `top`, `bottom`; start/end follow text direction) |
| `children` | `child` |
| `hideHandleBar`, `handleBarVariant`, `handleBarAccessibilityLabel` | same |
| `verticalDrawerPercentageOfView` | same |
| `preventDismissGestures` | same |
| `onCloseComplete`, `onOpenComplete`, `reduceMotion`, `accessibilityLabel` | same |
