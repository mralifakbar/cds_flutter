# CdsTabs

A row of text tabs with a 2px underline that springs to the active tab. Reach for it to switch between sibling views inside a screen section.

CDS reference: https://cds.coinbase.com/components/navigation/Tabs

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
String tab = 'crypto';

CdsTabs(
  accessibilityLabel: 'Portfolio sections',
  tabs: const [
    CdsTabValue(id: 'crypto', label: 'Crypto'),
    CdsTabValue(id: 'nfts', label: 'NFTs'),
    CdsTabValue(id: 'defi', label: 'DeFi'),
  ],
  activeTab: tab,
  onChange: (id) => setState(() => tab = id),
)
```

## When to use / when not to

- Use for two to five peer views that share one screen region.
- Use [CdsSegmentedTabs](CdsSegmentedTabs.md) for a compact pill control (Buy / Sell).
- Use [CdsTabNavigation](CdsTabNavigation.md) for the top-level tab bar of a screen, especially when tabs may overflow and need to scroll.
- Use [CdsTabbedChips](CdsTabbedChips.md) for nested or filter-like tabs.
- Use [CdsBottomNavigation](CdsBottomNavigation.md) to switch between app destinations on phones.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| tabs | `List<CdsTabValue>` | required | Tabs in display order. |
| activeTab | `String?` | required | Id of the active tab. `null` shows no active tab and no underline. |
| onChange | `ValueChanged<String>` | required | Called with the picked tab's id. Not called when the active tab is tapped again. |
| disabled | `bool` | `false` | Disables every tab. |
| color | `CdsColor` | `CdsColor.fg` | Inactive label color. |
| activeColor | `CdsColor` | `CdsColor.fgPrimary` | Active label color. |
| activeBackground | `CdsColor` | `CdsColor.bgPrimary` | Underline color. |
| background | `CdsColor?` | `null` | Fill behind the tab row. |
| font | `CdsFont` | `CdsFont.headline` | Label font. |
| gap | `double` | `4` | Space token between tabs (4 = 32px). |
| borderRadius | `int?` | `null` | Radius token for the row background. |
| pageController | `PageController?` | `null` | Makes the underline follow a `PageView` swipe 1:1. |
| tabBuilder | `CdsTabContentBuilder?` | `null` | `(context, tab, active) => Widget`. Replaces each tab's label content; focus, press and semantics stay managed. |
| indicatorBuilder | `CdsTabsIndicatorBuilder?` | `null` | `(context, x, width, animate) => Widget`. Replaces the underline. The widget fills the tab row; `x` is measured from its left edge. |
| accessibilityLabel | `String?` | `null` | Names the tab list for screen readers. |

`CdsTabValue`:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| id | `String` | required | Unique within the list. |
| label | `String` | required | Visible text. |
| disabled | `bool` | `false` | The tab cannot be selected and is skipped by arrow keys. |
| count | `int?` | `null` | Badge after the label when greater than zero. |
| max | `int?` | `null` (99) | Counts above this show as `max+`. |
| accessibilityLabel | `String?` | `null` | Read instead of `label`. |

## Examples

### Count badges

```dart
CdsTabs(
  tabs: const [
    CdsTabValue(id: 'inbox', label: 'Inbox', count: 3),
    CdsTabValue(id: 'sent', label: 'Sent'),
  ],
  activeTab: folder,
  onChange: (id) => setState(() => folder = id),
)
```

### Synced with a PageView

```dart
final pages = PageController();

Column(
  children: [
    CdsTabs(
      tabs: tabs,
      activeTab: tabs[index].id,
      pageController: pages,
      onChange: (id) {
        final next = tabs.indexWhere((t) => t.id == id);
        pages.animateToPage(next, duration: CdsDurations.moderate3, curve: CdsCurves.global);
      },
    ),
    Expanded(
      child: PageView(
        controller: pages,
        onPageChanged: (i) => setState(() => index = i),
        children: panels,
      ),
    ),
  ],
)
```

### No initial selection

```dart
CdsTabs(tabs: tabs, activeTab: null, onChange: (id) => setState(() => tab = id))
```

## Accessibility

- The row is a tab bar (`SemanticsRole.tabBar`) and each tab has `SemanticsRole.tab`, a selected state and a tap action.
- Left and Right arrows move the selection and focus to the previous or next enabled tab (mirrored in RTL); Home and End jump to the first and last. Selection follows focus.
- Each tab's hit area is at least 44px tall.
- The underline is excluded from semantics; selection is announced through the selected state, not color.

## Motion

- The underline position and width spring with `CdsSprings.standard` from their current values, so a second tap mid-flight redirects without a jump.
- With `pageController`, the underline tracks the page offset exactly during a swipe and springs the last bit when the page settles.
- Layout changes (rotation, count badges appearing) move the underline without animation.
- Reduced motion places the underline instantly.
- Selection changes fire a selection haptic.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `tabs` | `tabs` (`CdsTabValue`) |
| `activeTab` (tab object) | `activeTab` (tab id) |
| `onChange` (tab object) | `onChange` (tab id) |
| `disabled` | `disabled` |
| `color`, `activeColor` | `color`, `activeColor` |
| `activeBackground` | `activeBackground` |
| `background` | `background` |
| `font` | `font` |
| `gap` | `gap` (CDS has no default; examples use 4) |
| `TabComponent` | `tabBuilder` |
| `TabsActiveIndicatorComponent` | `indicatorBuilder` |
| `accessibilityLabel` | `accessibilityLabel` |
| `onActiveTabElementChange` | not ported; the active tab scrolls into view automatically in scrolling variants |
