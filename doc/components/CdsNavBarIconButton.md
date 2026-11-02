# CdsNavBarIconButton

A 40x40 transparent icon button sized for navigation bars, with a 44px hit area.

CDS reference: https://cds.coinbase.com/components/navigation/TopNavBar (`NavBarIconButton`)

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: close)
```

## When to use / when not to

- Use in the `start` and `end` slots of [CdsTopNavBar](CdsTopNavBar.md), [CdsNavigationBar](CdsNavigationBar.md) and [CdsPageHeader](CdsPageHeader.md).
- Use `CdsIconButton` elsewhere; it has a visible background.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| name | `CdsIconName` | required (positional) | Icon. |
| semanticLabel | `String` | required | What the button does, for screen readers. |
| onPress | `VoidCallback?` | `null` | Null disables the button. |
| active | `bool` | `false` | Filled glyph. |
| size | `CdsIconSize` | `CdsIconSize.m` | Icon size. |
| color | `CdsColor` | `CdsColor.fg` | Icon color. |
| disabled | `bool` | `false` | Disables the button. |
| feedback | `CdsHapticFeedback` | `light` | Haptic on press. |

## Examples

### Toggled state

```dart
CdsNavBarIconButton(CdsIconName.star, semanticLabel: 'Watchlist', active: watched, onPress: toggleWatch)
```

## Accessibility

- Button role with `semanticLabel`; Enter and Space activate; visible focus ring.
- 44x44 hit area around the 40px visual.

## Motion

Press feedback from `CdsPressable`: `bgSecondary` tint appears on pointer-down and the button scales to 0.98 (no scale under reduced motion).

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `name` | `name` |
| `accessibilityLabel` | `semanticLabel` |
| `onPress` | `onPress` |
| `active` | `active` |
| `size` | `size` |
| `color` | `color` |
| `disabled` | `disabled` |
