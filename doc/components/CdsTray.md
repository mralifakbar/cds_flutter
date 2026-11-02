# CdsTray

A bottom sheet for short tasks and pickers that follows the finger, snaps or dismisses based on release velocity, and can be grabbed mid-animation.

CDS reference: https://cds.coinbase.com/components/overlay/Tray

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
final asset = await showCdsTray<String>(
  context,
  builder: (context) => CdsTray(
    title: 'Choose an asset',
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      CdsButton(label: 'Bitcoin', variant: CdsButtonVariant.secondary, onPress: () => CdsTray.close(context, 'BTC')),
      CdsButton(label: 'Ethereum', variant: CdsButtonVariant.secondary, onPress: () => CdsTray.close(context, 'ETH')),
    ]),
  ),
);
```

## When to use / when not to

Use on phones for pickers, short forms, confirmations with context, and action lists. On wide screens prefer a `CdsModal` or an anchored `CdsPopoverPanel`/`CdsDropdown`. Do not put a multi-step flow in a tray (use `CdsFullscreenModal`).

## Parameters

### showCdsTray<T>

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| context | `BuildContext` | required | Context used to find the navigator. |
| builder | `WidgetBuilder` | required | Builds the `CdsTray`. |
| accessibilityLabel | `String?` | `null` | Names the route for screen readers. |
| useRootNavigator | `bool` | `true` | Push on the root navigator. |
| routeSettings | `RouteSettings?` | `null` | Route name and arguments. |

Returns `Future<T?>` with the value passed to `CdsTray.close(context, value)` or `Navigator.pop(context, value)`; `null` when dismissed by swipe, scrim tap, Escape, back or the handle bar. `Navigator.pop` animates the tray out along its entry path.

### CdsTray

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| child | `Widget` | required | Main content. Use a scrollable for content taller than the tray. |
| title | `String?` | `null` | Title in `title3` at the top. |
| titleWidget | `Widget?` | `null` | Custom title; overrides `title`. |
| header | `Widget?` | `null` | Fixed content under the title (stays put while `child` scrolls). |
| footer | `Widget?` | `null` | Content pinned below `child`, for example actions. |
| handleBarVariant | `CdsHandleBarVariant` | `CdsHandleBarVariant.outside` | Handle above the surface (on the scrim) or inside it. |
| hideHandleBar | `bool` | `false` | Hide the handle. |
| handleBarAccessibilityLabel | `String` | `'Dismiss'` | Screen reader label of the handle (activating it closes the tray). |
| snapPoints | `List<double>?` | `null` | Visible heights as fractions of the screen height, e.g. `[0.4, 0.9]`. Null sizes the tray to its content. |
| initialSnapPointIndex | `int?` | `null` | Index into the ascending `snapPoints` to open at. Null opens at index 0, the smallest. |
| verticalDrawerPercentageOfView | `double` | `0.75` | Max share of the screen height for a content-sized tray. |
| preventDismissGestures | `bool` | `false` | Disable swipe and scrim-tap dismissal. Escape and back still close. |
| disableSafeAreaPaddingBottom | `bool` | `false` | Skip the bottom safe-area inset under the content. |
| onCloseComplete | `VoidCallback?` | `null` | Called after the tray leaves, when rendered without `showCdsTray`. |
| onOpenComplete | `VoidCallback?` | `null` | Called when the entry animation settles. |
| accessibilityLabel | `String?` | `null` | Label for the tray. Defaults to `title`. |
| reduceMotion | `bool?` | `null` | Overrides the platform reduced-motion setting. |

Static: `CdsTray.close(BuildContext context, [Object? result])` closes the tray containing `context` with an animation.

Surface: radius 600 (32px) on the top corners, `bgElevation2` with the elevation 2 shadow, 1px `bgLine` border in dark mode, bottom safe-area padding.

## Examples

### Snap points with a scrolling list

```dart
showCdsTray<void>(
  context,
  builder: (context) => CdsTray(
    title: 'Recent activity',
    snapPoints: const [0.5, 0.9],
    initialSnapPointIndex: 0,
    child: ListView(children: [
      for (var i = 1; i <= 30; i++) CdsText('Sample data: transfer $i'),
    ]),
  ),
);
```

Pulling down at the top of the list moves the tray; pushing a lowered tray up raises it before the list scrolls again.

### Declarative, inside a Stack

```dart
if (showFees)
  CdsTray(
    title: 'Network fee',
    onCloseComplete: () => setState(() => showFees = false),
    child: const CdsText('Fees go to the network, not to this app.'),
  ),
```

## Accessibility

- Separate semantics scope; focus moves into the tray, is trapped and is restored on close.
- Escape and back close it. The handle bar is a labelled button for screen reader users ("Dismiss").
- The title is a heading. Keep long content in a scrollable so 2x text never overflows.

## Motion

- Drag follows the finger 1:1 from where it was grabbed. Above the open position it rubberbands (`CdsMotion.rubberband`), stretching the surface so no gap shows.
- On release the velocity is projected (`CdsMotion.project`) and the nearest of the snap points or the dismiss position wins; a gesture heading up never dismisses. The release velocity is handed to `CdsMotion.springTo` with `CdsSprings.sheet`. A selection haptic fires when it settles on a different snap point.
- Every animation starts from the current position: grabbing the tray while it is entering, settling or leaving (before it is off screen) continues from where it is.
- Enters from below and leaves the same way. The scrim dims in proportion to how far the tray is open.
- Reduced motion: the tray appears and leaves with a short fade, drags still follow the finger, and releases snap without a spring.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` (node or render prop) | `child`; close with `CdsTray.close(context)` instead of `handleClose` |
| `title` (string / node) | `title` / `titleWidget` |
| `header`, `footer` | `header`, `footer` |
| `handleBarVariant`, `hideHandleBar`, `handleBarAccessibilityLabel` | same |
| `verticalDrawerPercentageOfView` | same |
| `preventDismissGestures` | same |
| `onCloseComplete`, `onOpenComplete` | same |
| `disableSafeAreaPaddingBottom` | same |
| `reduceMotion` | same |
| `accessibilityLabel` | same |
| (none) | `snapPoints`, `initialSnapPointIndex` (addition) |

CDS animates trays with fixed-duration timings; this port uses springs with velocity projection, per the package motion contract.
