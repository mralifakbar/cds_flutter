# CdsDropdown

A menu of options that opens from a trigger, with arrow-key navigation and typeahead.

CDS reference: https://cds.coinbase.com/components/overlay/PopoverPanel (CDS web Dropdown is built on the same popover)

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsDropdown<String>(
  value: currency,
  onChange: (v) => setState(() => currency = v),
  builder: (context, controller) => CdsButton(
    label: 'Currency: $currency',
    variant: CdsButtonVariant.secondary,
    onPress: controller.toggle,
  ),
  content: const [
    CdsMenuItem(value: 'USD', label: 'US Dollar'),
    CdsMenuItem(value: 'EUR', label: 'Euro'),
  ],
)
```

## When to use / when not to

Use for a short menu attached to a button. For a form field with a label and helper text, use `CdsSelect` (it switches to a tray on phones). For actions on an item, use `CdsContextMenu`.

## Parameters

### CdsDropdown<T>

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| builder | `CdsPopoverTriggerBuilder` | required | Builds the trigger; call `controller.toggle`. |
| content | `List<CdsMenuItem<T>>` | required | The options. |
| value | `T?` | `null` | Selected value (shows a check mark). |
| onChange | `ValueChanged<T>?` | `null` | Called with the chosen value. |
| disableCloseOnOptionChange | `bool` | `false` | Keep the menu open after a choice. |
| placement | `CdsPlacement` | `CdsPlacement.bottomStart` | Preferred position; flips when needed. |
| gap | `double` | `0.5` | Space token between trigger and menu. |
| width | `double?` | `null` | Fixed menu width. |
| minWidth | `double?` | `null` | Minimum menu width. |
| maxWidth | `double?` | `null` | Maximum menu width. |
| maxHeight | `double` | `cdsDropdownMaxHeight` (300) | Maximum menu height; the list scrolls. |
| block | `bool` | `false` | Trigger and menu take the parent's width. |
| disabled | `bool` | `false` | Keep the menu closed. |
| disableTypeFocus | `bool` | `false` | Turn off typeahead. |
| showOverlay | `bool` | `false` | Dim the page behind the menu. |
| controller | `CdsPopoverController?` | `null` | Control open state from outside. |
| onOpenMenu | `VoidCallback?` | `null` | Called on open. |
| onCloseMenu | `VoidCallback?` | `null` | Called on close. |
| accessibilityLabel | `String?` | `null` | Label for the menu. |
| restoreFocusOnUnmount | `bool` | `true` | Return focus to the trigger on close. |

### CdsMenuItem<T>

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| value | `T` | required | Value passed to `onChange`. |
| label | `String?` | `null` | Row title in `headline`; also used for typeahead. |
| description | `String?` | `null` | Muted second line. |
| media | `Widget?` | `null` | Leading content, for example an asset icon. |
| accessory | `Widget?` | `null` | Trailing indicator; replaces the check mark. |
| end | `Widget?` | `null` | Trailing content before the accessory, for example a balance. |
| disabled | `bool` | `false` | Not selectable. |
| onPress | `VoidCallback?` | `null` | Called on press in addition to `onChange`. |

Rows are at least 44px tall, 16px horizontal padding. The selected row has a `bgSecondary` background and a check mark.

## Examples

### With descriptions and balances

```dart
CdsDropdown<String>(
  value: account,
  onChange: (v) => setState(() => account = v),
  builder: (context, c) => CdsButton(label: 'Pay from', onPress: c.toggle),
  content: const [
    CdsMenuItem(value: 'cash', label: 'Cash', description: 'Sample data: 1,240.00 USD'),
    CdsMenuItem(value: 'card', label: 'Debit card', description: 'Sample data: ending 4242'),
  ],
)
```

## Accessibility

- Opening moves focus to the selected option (or the first one); Up/Down move, Home/End jump, typing jumps to a matching label, Enter/Space choose, Escape closes and returns focus to the trigger.
- Selected state is exposed (`selected`) and shown with a check mark, not color alone.
- Every row has a 44px minimum height.

## Motion

Same as `CdsPopoverPanel`: fade plus 16px slide and slight scale from the trigger over `moderate3`, reversed on exit; reduced motion fades. Rows give pointer-down feedback.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` (trigger) | `builder(context, controller)` |
| `content` (MenuItems) | `content` (`List<CdsMenuItem<T>>`) |
| `value`, `onChange` | `value`, `onChange` (typed `T`, not only strings) |
| `disableCloseOnOptionChange`, `disableTypeFocus`, `showOverlay`, `block`, `disabled` | same |
| `width`, `minWidth`, `maxWidth`, `maxHeight` | same |
| `onOpenMenu`, `onCloseMenu`, `onBlur` | `onOpenMenu`, `onCloseMenu` |
| `contentPosition` | `placement`, `gap` |
| ref `openMenu` / `closeMenu` | `controller.open()` / `controller.close()` |
