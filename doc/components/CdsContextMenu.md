# CdsContextMenu

A menu of actions for an item, opened by long-press on touch screens, right-click with a mouse, or the context-menu key.

CDS reference: Not a CDS docs page. This is an addition that reuses CDS dropdown styling and motion.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsContextMenu(
  actions: [
    CdsContextMenuAction(label: 'Copy address', icon: CdsIconName.copy, onPress: copy),
    CdsContextMenuAction(label: 'Remove', icon: CdsIconName.trashCan, destructive: true, onPress: remove),
  ],
  child: const CdsText('Sample data: 0x12ab...9f'),
)
```

## When to use / when not to

Use for secondary actions on list items or addresses. Always offer the same actions somewhere visible too (a "More" button), because long-press is not discoverable.

## Parameters

### CdsContextMenu

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| child | `Widget` | required | The item. |
| actions | `List<CdsContextMenuAction>` | required | Menu actions. |
| disabled | `bool` | `false` | Do not open. |
| onOpen | `VoidCallback?` | `null` | Called on open. |
| onClose | `VoidCallback?` | `null` | Called on close. |
| accessibilityLabel | `String?` | `null` | Label for the menu. |

### CdsContextMenuAction

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| label | `String` | required | Action label. |
| onPress | `VoidCallback` | required | Runs after the menu closes. |
| icon | `CdsIconName?` | `null` | Leading icon. |
| destructive | `bool` | `false` | Label and icon in `fgNegative`. |
| disabled | `bool` | `false` | Not selectable. |

The menu opens at the press point (or below the item for the keyboard), 200 to 280px wide, max 360px tall.

## Examples

### Disabled action

```dart
CdsContextMenu(
  actions: [
    CdsContextMenuAction(label: 'Share', icon: CdsIconName.share, onPress: share),
    CdsContextMenuAction(label: 'Edit label', icon: CdsIconName.pencil, disabled: true, onPress: () {}),
  ],
  child: const CdsText('Sample data: Savings wallet'),
)
```

## Accessibility

Screen readers get a long-press action ("Show actions"). Keyboard: the context-menu key or Shift+F10 opens it; arrows move, Enter chooses, Escape closes and restores focus. Rows are 44px minimum.

## Motion

Fade plus a short slide and slight scale from the press point (`moderate3`, global), reversed on close; reduced motion fades.

## CDS React Native mapping

No CDS equivalent.
