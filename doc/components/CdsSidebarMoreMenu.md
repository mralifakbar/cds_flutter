# CdsSidebarMoreMenu

A "More" item in a `CdsSidebar` that opens a menu of extra destinations beside the sidebar.

CDS reference: https://cds.coinbase.com/components/navigation/SidebarMoreMenu

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsSidebarMoreMenu(
  children: [
    CdsSidebarItem(icon: CdsIconName.settings, title: 'Settings', onPress: openSettings),
    CdsSidebarItem(icon: CdsIconName.info, title: 'Help', onPress: openHelp),
  ],
)
```

## When to use / when not to

Use when a sidebar has more destinations than fit, or for secondary ones. Keep the most used destinations as top-level items.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Menu content, usually `CdsSidebarItem`s. |
| `active` | `bool` | `false` | Highlights the trigger, e.g. when the current page lives in the menu. |
| `triggerTitle` | `String` | `'More'` | Title of the trigger item (icon `moreVertical`). |
| `onOpenChange` | `ValueChanged<bool>?` | `null` | Called with true on open and false on close. |

`CdsSidebarMoreMenu.close(BuildContext context)` closes the menu from custom content inside it.

## Examples

### Custom content that closes the menu

```dart
CdsSidebarMoreMenu(
  children: [
    Builder(
      builder: (context) => CdsButton(
        label: 'Sign out',
        variant: CdsButtonVariant.secondary,
        onPress: () {
          CdsSidebarMoreMenu.close(context);
          signOut();
        },
      ),
    ),
  ],
)
```

## Accessibility

- The trigger reports the expanded state.
- On open, focus moves to the first focusable item; Up and Down move between items.
- Escape, a tap outside, or pressing an item closes the menu and returns focus to the trigger.

## Motion

The panel opens 24px to the end side of the trigger, aligned to its top, and grows from that corner: scale 0.95 to 1 with a fade over `CdsDurations.fast3` (`enterFunctional` in, `exitFunctional` out). It leaves the same way. Under reduced motion it appears and disappears instantly. Panel: `bgElevation2`, level 2 shadow, radius 400, 200 to 320px wide.

## CDS React Native mapping

Web only in CDS, where it wraps `Dropdown`.

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `children` |
| `active` | `active` |
| `triggerTitle` | `triggerTitle` |
| `onClick` | not needed; the trigger toggles the menu |
| `value` / `onChange` | not supported; use `onPress` on each item |
| `tooltipContent`, `disablePortal`, `Component` | not supported |
