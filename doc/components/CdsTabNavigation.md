# CdsTabNavigation

The top-level tab bar of a screen: a horizontally scrolling row of [CdsTabLabel]s with a [CdsTabIndicator] under the active one.

CDS reference: https://cds.coinbase.com/components/navigation/TabNavigation

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
String section = 'foryou';

CdsTabNavigation(
  accessibilityLabel: 'Home sections',
  tabs: const [
    CdsTabValue(id: 'foryou', label: 'For you'),
    CdsTabValue(id: 'portfolio', label: 'Portfolio'),
    CdsTabValue(id: 'explore', label: 'Explore'),
  ],
  value: section,
  onChange: (id) => setState(() => section = id),
)
```

## When to use / when not to

- Use directly under a navigation bar (often in its `bottom` slot) to switch between a screen's main sections.
- Use [CdsBottomNavigation](CdsBottomNavigation.md) for app destinations on phones. CDS `TabNavigation` is a top tab bar only.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| tabs | `List<CdsTabValue>` | required | Tabs in display order. |
| onChange | `ValueChanged<String>` | required | Called with the picked id. |
| value | `String?` | first tab | Id of the active tab. |
| variant | `CdsTabLabelVariant` | `primary` | `secondary` has no indicator and is deprecated in CDS. |
| background | `CdsColor` | `CdsColor.bg` | Bar background. |
| gap | `double` | `4` | Space token between tabs. |
| paddingX | `double` | `0` | Space token inset at both ends of the scrolling row. |
| role | `CdsTabNavigationRole` | `tablist` | `radiogroup` exposes the tabs as a radio group. |
| pageController | `PageController?` | `null` | Indicator follows a `PageView` swipe. |
| tabBuilder | `CdsTabContentBuilder?` | `null` | Replaces each tab's label. |
| accessibilityLabel | `String?` | `null` | Names the bar for screen readers. |

## Examples

### In a top navigation bar

```dart
CdsTopNavBar(
  child: const CdsNavigationTitle('Home'),
  bottom: CdsTabNavigation(tabs: tabs, value: section, onChange: (id) => setState(() => section = id)),
)
```

## Accessibility

- `tablist` role: tab bar with tab children and selected state. `radiogroup` role: mutually exclusive, checked state.
- Arrow keys, Home and End move the selection and scroll it into view.
- Tab hit areas are at least 44px tall.

## Motion

- Indicator springs from its current position; follows `pageController` during swipes.
- The active tab scrolls into view; the trailing edge fades while more tabs are offscreen.
- Reduced motion removes the spring and scroll animation.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `tabs` (`id`, `label`, `count`, `max`, `disabled`, `accessibilityLabel`) | `tabs` (`CdsTabValue`) |
| `tabs[].onPress` | use `onChange` |
| `value` | `value` |
| `onChange` | `onChange` |
| `variant` | `variant` |
| `background` | `background` |
| `gap` | `gap` |
| `role` | `role` |
| `Component` | `tabBuilder` |
