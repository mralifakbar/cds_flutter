# CdsSelect

A form control for choosing one option (`CdsSelect`) or several (`CdsSelect.multi`) from a list; opens a tray on phones and an anchored menu on wide screens.

CDS reference: https://cds.coinbase.com/components/inputs/Select

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsSelect<String>(
  label: 'Network',
  placeholder: 'Choose a network',
  value: network,
  onChange: (v) => setState(() => network = v),
  options: const [
    CdsSelectOption(value: 'eth', label: 'Ethereum'),
    CdsSelectOption(value: 'sol', label: 'Solana'),
  ],
)
```

## When to use / when not to

Use in forms for 4 or more options. For 2 or 3 options prefer radio buttons or a segmented control. For long lists (countries, assets) use `CdsCombobox`. For filter bars use `CdsSelectChip`. For a menu on a button use `CdsDropdown`.

## Parameters

### CdsSelect<T> (single)

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| options | `List<CdsSelectOption<T>>` | required | The choices. |
| value | `T?` | required | Selected value, or null. |
| onChange | `ValueChanged<T?>?` | required | Called with the picked value. Null disables the control. |
| label | `String?` | `null` | Shown above the control (`label2`, `fgMuted`) and as the tray title. |
| placeholder | `String?` | `null` | Shown when nothing is selected. |
| helperText | `String?` | `null` | Hint or error under the control, colored by `variant`. |
| variant | `CdsSelectVariant?` | `null` | `foreground`, `foregroundMuted`, `positive`, `negative`, `primary`, `secondary`. |
| size | `CdsSelectSize` | `CdsSelectSize.l` | Vertical padding: `s` 8, `m` 12, `l` 16. |
| disabled | `bool` | `false` | Dimmed, cannot open. |
| readOnly | `bool` | `false` | Shows the value on `bgSecondary`, cannot open. |
| start | `Widget?` | `null` | Leading content inside the control. |
| presentation | `CdsSelectPresentation` | `CdsSelectPresentation.auto` | `auto` (tray below 768px, menu from 768px), `dropdown`, `tray`. |
| accessibilityLabel | `String?` | `null` | Defaults to `label`. |
| accessibilityHint | `String?` | `null` | Screen reader hint. |
| emptyOptionsLabel | `String` | `'No options available'` | Shown when there are no options. |
| onOpen | `VoidCallback?` | `null` | Called on open. |
| onClose | `VoidCallback?` | `null` | Called on close. |

### CdsSelect<T>.multi

Same as above, with `value` typed `List<T>` and `onChange` typed `ValueChanged<List<T>>?`, plus:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| maxSelectedOptionsToShow | `int` | `3` | Chips in the control before "+N more". |
| hiddenSelectedOptionsLabel | `String` | `'more'` | Word after the hidden count. |
| selectAllLabel | `String` | `'Select all'` | First row label (shows the count). |
| clearAllLabel | `String` | `'Clear all'` | Button on the select-all row. |
| hideSelectAll | `bool` | `false` | Hide the select-all row. |
| removeSelectedOptionAccessibilityLabel | `String` | `'Remove'` | Prefix of each chip's label. |

Getters: `value` (single) and `values` (multi), `isMulti`.

### CdsSelectOption<T>

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| value | `T` | required | The value reported by `onChange`. |
| label | `String?` | `null` | Row title and control text. Falls back to `description`, then `value.toString()`. |
| description | `String?` | `null` | Muted second line. |
| disabled | `bool` | `false` | Not selectable. |
| media | `Widget?` | `null` | Leading row content. |
| accessory | `Widget?` | `null` | Trailing indicator; replaces the check mark. |
| end | `Widget?` | `null` | Trailing content, for example a balance. |

Control: 1px `bgLineHeavy` border (2px `bgLinePrimary` while open), radius 200, caret that turns while open. Menu: `bg`, 1px `bgLine`, radius 400, elevation 2, max 300px tall, same width as the control.

## Examples

### Error state

```dart
CdsSelect<String>(
  label: 'Payment method',
  value: method,
  onChange: (v) => setState(() => method = v),
  variant: CdsSelectVariant.negative,
  helperText: 'Choose a payment method to buy Bitcoin.',
  options: const [
    CdsSelectOption(value: 'bank', label: 'Bank account', description: 'Sample data: ending 1234'),
    CdsSelectOption(value: 'card', label: 'Debit card', description: 'Sample data: ending 4242'),
  ],
)
```

### Multiple choice

```dart
CdsSelect<String>.multi(
  label: 'Assets',
  placeholder: 'All assets',
  value: assets,
  onChange: (v) => setState(() => assets = v),
  options: const [
    CdsSelectOption(value: 'btc', label: 'Bitcoin'),
    CdsSelectOption(value: 'eth', label: 'Ethereum'),
    CdsSelectOption(value: 'usdc', label: 'USDC'),
  ],
)
```

## Accessibility

- The control is a button whose label combines `label` and the current value ("Network, Ethereum").
- Menu: focus moves to the selected option; Up/Down, Home/End and typeahead navigate; Enter/Space choose; Escape closes and returns focus. Tray: standard tray behavior.
- Single rows expose `selected` and show a check mark; multi rows expose a toggled check box.
- Helper text is visible text, not color alone. Rows and chips have 44px targets.

## Motion

The caret turns over `fast3`. Menus use dropdown motion (fade, 16px slide, slight scale from the control, `moderate3`); trays use tray physics. Reduced motion: fades and instant caret.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `type: 'single' \| 'multi'` | `CdsSelect` / `CdsSelect.multi` |
| `options` (incl. groups) | `options` (flat list; groups not ported) |
| `value`, `onChange` | `value`, `onChange` (typed `T`) |
| `label`, `placeholder`, `helperText`, `variant`, `size`, `disabled`, `readOnly` | same |
| `startNode` | `start` |
| `maxSelectedOptionsToShow`, `hiddenSelectedOptionsLabel`, `selectAllLabel`, `clearAllLabel`, `hideSelectAll`, `emptyOptionsLabel`, `removeSelectedOptionAccessibilityLabel` | same |
| `accessibilityLabel`, `accessibilityHint` | same |
| `SelectControlComponent`, `SelectDropdownComponent`, `SelectOptionComponent` | not customizable |
| (mobile always opens a Tray) | `presentation` (`auto` adds the wide-screen menu) |

`CdsSelectVariant` mirrors CDS `InputVariant`; it is named for select so it does not clash with the text input family.
