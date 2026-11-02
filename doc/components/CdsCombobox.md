# CdsCombobox

A `CdsSelect` with a search field at the top of its options, for long lists such as countries or assets.

CDS reference: https://cds.coinbase.com/components/inputs/Combobox

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCombobox<String>(
  label: 'Country',
  value: country,
  onChange: (v) => setState(() => country = v),
  options: const [
    CdsSelectOption(value: 'us', label: 'United States'),
    CdsSelectOption(value: 'gb', label: 'United Kingdom'),
    CdsSelectOption(value: 'de', label: 'Germany'),
  ],
)
```

## When to use / when not to

Use when people know what they are looking for and the list is long (10 or more). For short lists use `CdsSelect`.

## Parameters

All `CdsSelect` parameters (`options`, `value`, `onChange`, `label`, `placeholder`, `helperText`, `variant`, `size`, `disabled`, `readOnly`, `start`, `presentation`, `accessibilityLabel`, `accessibilityHint`, `emptyOptionsLabel`, `onOpen`, `onClose`), plus:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| searchText | `String?` | `null` | Controlled search text. |
| onSearch | `ValueChanged<String>?` | `null` | Called as the search text changes. |
| filterFunction | `CdsComboboxFilter<T>?` | `null` | `List<CdsSelectOption<T>> Function(List<CdsSelectOption<T>> options, String searchText)`. Defaults to `cdsDefaultComboboxFilter`: label or description contains the text, ignoring case. |
| defaultSearchText | `String` | `''` | Initial search text when uncontrolled. |
| searchPlaceholder | `String` | `'Search'` | Search field placeholder. |

`CdsCombobox.multi` adds `maxSelectedOptionsToShow` (3), `hiddenSelectedOptionsLabel` ('more') and `removeSelectedOptionAccessibilityLabel` ('Remove'). Comboboxes have no select-all row.

When no option matches, `emptyOptionsLabel` is shown.

## Examples

### Custom filter (prefix match)

```dart
CdsCombobox<String>(
  label: 'Asset',
  value: asset,
  onChange: (v) => setState(() => asset = v),
  filterFunction: (options, text) => [
    for (final o in options)
      if (o.displayLabel.toLowerCase().startsWith(text.toLowerCase())) o,
  ],
  options: const [
    CdsSelectOption(value: 'btc', label: 'Bitcoin'),
    CdsSelectOption(value: 'eth', label: 'Ethereum'),
  ],
)
```

## Accessibility

The search field is focused when the options open and labelled with its placeholder; a labelled clear button appears once text is entered. Typeahead is off (typing goes to the search field); arrow keys still move through options once focus is in the list.

## Motion

Same as `CdsSelect`.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `searchText`, `onSearch` | same |
| `filterFunction` | `filterFunction` |
| `defaultSearchText` | same |
| `hideSearchInput` | not ported (use `CdsSelect`) |
| `type: 'multi'` | `CdsCombobox.multi` |
| Select props | same as `CdsSelect` |

The search field sits at the top of the menu or tray instead of inside the control.
