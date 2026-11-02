# CdsRefreshControl

Pull to refresh for a vertical scrollable: the indicator follows the finger, and releasing past a threshold reloads the content.

CDS reference: none. This is a cds_flutter extra built from CDS tokens.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsRefreshControl(
  onRefresh: loadPrices,
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: rows,
  ),
)
```

## When to use / when not to

Use on lists whose data changes on the server, such as prices or activity. Do not use as the only way to refresh; also refresh on screen focus or offer a button for users who cannot drag.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | A vertical scrollable. Use `AlwaysScrollableScrollPhysics` so short lists can be pulled. |
| `onRefresh` | `Future<void> Function()` | required | Reloads the content. The spinner shows until the future completes. |
| `triggerDistance` | `double` | `80` | Pull distance, in logical pixels, that arms a refresh. |
| `indicatorSize` | `double` | `24` | Ring diameter. |
| `semanticLabel` | `String` | `'Refreshing'` | Announced while refreshing. |
| `refreshActionLabel` | `String` | `'Refresh'` | Name of the screen reader custom action. |

## Behavior

1. Pulling down at the top of the list moves the indicator 1:1 with the finger. Past `triggerDistance` it slows with `CdsMotion.rubberband`.
2. While pulling, a determinate ring fills from 0 to 100% of `triggerDistance`. Nothing spins before release. A light haptic fires once when the threshold is crossed.
3. Releasing past the threshold calls `onRefresh`; the indicator settles at the threshold and shows `CdsProgressCircle.indeterminate` until the future completes, then springs back.
4. Releasing short of the threshold springs back without refreshing.

Works with bouncing (iOS) and clamping (Android) physics. New pulls are ignored while a refresh is running.

## Accessibility

- The indeterminate indicator is a live region announcing `semanticLabel`.
- A "Refresh" custom semantics action runs `onRefresh` without a drag.

## Motion

Return and settle use `CdsMotion.springTo` with `CdsSprings.standard`, starting from wherever the indicator is. Under reduced motion the indicator jumps to its target with no spring. The spinner runs only while `onRefresh` is pending.

## CDS React Native mapping

No CDS component. React Native apps use `RefreshControl` from React Native; `onRefresh` maps directly, and `refreshing` is driven by the returned future.
