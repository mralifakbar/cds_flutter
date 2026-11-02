# CdsBottomNavigation

A phone bottom tab bar in CDS style: icon plus label per destination, the active one drawn with the filled glyph and `fgPrimary`, at least 44px targets and the bottom safe area applied.

CDS reference: none. This is a cds_flutter extra built from CDS tokens. CDS React Native leaves the bottom tab bar to the app's navigator, and `TabNavigation` is a top tab bar only.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
String destination = 'home';

CdsBottomNavigation(
  items: const [
    CdsBottomNavigationItem(id: 'home', icon: CdsIconName.home, label: 'Home'),
    CdsBottomNavigationItem(id: 'trade', icon: CdsIconName.trading, label: 'Trade'),
    CdsBottomNavigationItem(id: 'wallet', icon: CdsIconName.wallet, label: 'Wallet'),
  ],
  value: destination,
  onChange: (id) => setState(() => destination = id),
)
```

## When to use / when not to

- Use for three to five top-level destinations of a phone app.
- On tablets and desktop prefer [CdsSidebar](CdsSidebar.md).
- Do not use for switching views inside one screen; use [CdsTabs](CdsTabs.md).

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| items | `List<CdsBottomNavigationItem>` | required | Destinations in display order. |
| value | `String` | required | Id of the selected destination. |
| onChange | `ValueChanged<String>` | required | Called with the picked id. |
| background | `CdsColor` | `CdsColor.bg` | Bar background. |
| bordered | `bool` | `true` | Hairline (`bgLine`) above the bar. |
| showLabels | `bool` | `true` | `false` shows icons only; labels are still read by screen readers. |
| respectSafeArea | `bool` | `true` | Pads the bottom by `MediaQuery.paddingOf(context).bottom`. |
| accessibilityLabel | `String` | `'Main navigation'` | Names the bar. |

`CdsBottomNavigationItem`:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| id | `String` | required | Unique id. |
| icon | `CdsIconName` | required | Outlined when inactive, filled (`active: true`) when selected. |
| label | `String` | required | Shown in `legal` under the icon. |
| count | `int?` | `null` | Badge on the icon when greater than zero. |
| max | `int?` | `null` (99) | Counts above this show as `max+`. |
| disabled | `bool` | `false` | Cannot be selected. |
| accessibilityLabel | `String?` | `null` | Overrides the read label (default: label, plus count when set). |

## Examples

### With a badge, in a scaffold

```dart
CdsScaffold(
  body: pages[destination]!,
  footer: CdsBottomNavigation(
    items: const [
      CdsBottomNavigationItem(id: 'home', icon: CdsIconName.home, label: 'Home'),
      CdsBottomNavigationItem(id: 'alerts', icon: CdsIconName.bell, label: 'Alerts', count: 4),
    ],
    value: destination,
    onChange: (id) => setState(() => destination = id),
  ),
)
```

## Accessibility

- Tab bar with tab children, selected state and tap action.
- Selection is shown by the filled glyph and color together, never color alone.
- Arrow keys, Home and End move the selection.
- Each item is at least 56px tall and 44px wide.

## Motion

- Items get the standard `CdsPressable` press feedback (tint and 0.98 scale on pointer-down; scale off under reduced motion).
- Selection changes fire a selection haptic.

## CDS React Native mapping

| CDS concept | Flutter parameter |
| --- | --- |
| Icon `active` glyph for the current tab | `CdsBottomNavigationItem.icon` drawn with `active: true` when selected |
| `DotCount` | `count`, `max` |
