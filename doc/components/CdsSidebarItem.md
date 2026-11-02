# CdsSidebarItem

A destination in a `CdsSidebar`: an icon and a title, highlighted when it is the current page.

CDS reference: https://cds.coinbase.com/components/navigation/SidebarItem

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsSidebarItem(
  icon: CdsIconName.wallet,
  title: 'Assets',
  active: route == '/assets',
  onPress: () => go('/assets'),
)
```

## When to use / when not to

Use inside `CdsSidebar` or `CdsSidebarMoreMenu`. For lists of content, use cells instead.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `icon` | `CdsIconName` | required | Shown at size `m`; the filled glyph when `active`. |
| `title` | `String` | required | Text label, `headline` (or `label1` at legal size in the condensed variant). |
| `onPress` | `VoidCallback?` | `null` | Navigates. Null disables the item. Inside a `CdsSidebarMoreMenu`, pressing also closes the menu. |
| `active` | `bool` | `false` | The current destination: `bgPrimaryWash` background, `fgPrimary` icon and title. |
| `collapsed` | `bool?` | `null` | Overrides the sidebar's collapsed state. |
| `borderRadius` | `int?` | `null` | Radius token. Defaults to 1000 (pill), or 400 in the condensed variant. |
| `accessibilityLabel` | `String?` | `null` | Read when collapsed. Defaults to `title`. |
| `focusNode` | `FocusNode?` | `null` | For moving focus programmatically. |

## Examples

### Icon only

```dart
CdsSidebarItem(icon: CdsIconName.settings, title: 'Settings', collapsed: true, onPress: openSettings)
```

## Accessibility

Built on `CdsPressable`: button role, selected state when active, focus ring, Enter and Space activate, 44px minimum hit area. Collapsed items announce the title.

## Motion

Pointer-down tint and 0.98 scale from `CdsPressable`; inactive items show the wash only while pressed or hovered. Selection haptic on press.

## CDS React Native mapping

Web only in CDS.

| CDS prop | Flutter parameter |
| --- | --- |
| `icon` | `icon` |
| `title` | `title` |
| `onClick` | `onPress` |
| `active` | `active` |
| `collapsed` | `collapsed` |
| `borderRadius` | `borderRadius` |
| `accessibilityLabel` | `accessibilityLabel` |
| `tooltipContent` | not supported (tooltips live in another package area) |
| `Component` | not supported |
