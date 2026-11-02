# CdsSidebar

Vertical app navigation for tablet and desktop layouts, holding `CdsSidebarItem`s and an optional `CdsSidebarMoreMenu`.

CDS reference: https://cds.coinbase.com/components/navigation/Sidebar

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
Row(
  children: [
    CdsSidebar(
      autoCollapse: true,
      children: [
        CdsSidebarItem(icon: CdsIconName.home, title: 'Home', active: true, onPress: () {}),
        CdsSidebarItem(icon: CdsIconName.trading, title: 'Trade', onPress: () {}),
        CdsSidebarItem(icon: CdsIconName.wallet, title: 'Assets', onPress: () {}),
      ],
    ),
    const Expanded(child: Page()),
  ],
)
```

## When to use / when not to

Use on screens 768px and wider for top-level destinations. On phones, use `CdsBottomNavigation` or `CdsTabNavigation` instead.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Usually `CdsSidebarItem`s and a `CdsSidebarMoreMenu`. |
| `logo` | `Widget?` | `null` | Shown above the items. Never pass Coinbase marks. |
| `logoBuilder` | `Widget Function(bool collapsed)?` | `null` | Builds the logo for the collapsed state; wins over `logo`. |
| `collapsed` | `bool?` | `null` | Forces the collapsed state. Overrides `autoCollapse`. |
| `autoCollapse` | `bool` | `false` | Collapse to icons when the screen is narrower than 768px (`cdsSidebarAutoCollapseBreakpoint`). |
| `renderEnd` | `Widget Function(bool collapsed)?` | `null` | Content pinned to the bottom, 32px below the items. |
| `variant` | `CdsSidebarVariant` | `CdsSidebarVariant.defaultVariant` | `defaultVariant` (icon and title in a row) or `condensed` (title under the icon). |
| `width` | `double?` | `null` | Overrides the width: 240 expanded, 87 collapsed, 88 condensed. |
| `accessibilityLabel` | `String` | `'Sidebar'` | Label for the navigation group. |

Descendants read the collapsed state and variant through `CdsSidebarScope.maybeOf(context)`.

## Examples

### Condensed rail

```dart
CdsSidebar(
  variant: CdsSidebarVariant.condensed,
  children: [
    CdsSidebarItem(icon: CdsIconName.home, title: 'Home', active: true, onPress: () {}),
    CdsSidebarItem(icon: CdsIconName.trading, title: 'Trade', onPress: () {}),
  ],
)
```

### Collapse toggle in the footer

```dart
CdsSidebar(
  collapsed: collapsed,
  renderEnd: (isCollapsed) => CdsIconButton(
    isCollapsed ? CdsIconName.caretRight : CdsIconName.caretLeft,
    semanticLabel: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
    onPress: () => setState(() => collapsed = !collapsed),
  ),
  children: items,
)
```

## Accessibility

- The sidebar is a semantics group labelled `accessibilityLabel`; items are buttons, and the active item has the selected state.
- Collapsed items read their title even though only the icon shows.
- Up and Down arrow keys move focus between items; Tab order follows visual order.
- The end border uses `bgLine`, padding 16px (12px condensed) horizontally and 16px vertically.

## Motion

Width changes animate over `CdsDurations.moderate2` with `CdsCurves.global`; under reduced motion they are instant. Titles hide immediately when collapsing so nothing overflows while the width animates.

## CDS React Native mapping

CDS ships Sidebar for web only; this port follows the web API.

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `children` |
| `logo` (element or function) | `logo` / `logoBuilder` |
| `collapsed` | `collapsed` |
| `autoCollapse` | `autoCollapse` |
| `renderEnd` | `renderEnd` |
| `variant` (`'default'`, `'condensed'`) | `variant` (`defaultVariant`, `condensed`) |
| `width` | `width` |
| `accessibilityLabel` | `accessibilityLabel` |
