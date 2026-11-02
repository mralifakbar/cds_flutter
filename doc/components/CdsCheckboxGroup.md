# CdsCheckboxGroup

A labelled set of checkboxes bound to a `Set` of selected values.

CDS reference: https://cds.coinbase.com/components/inputs/CheckboxGroup

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCheckboxGroup<String>(
  label: 'Assets to watch',
  options: const [
    CdsControlOption(value: 'btc', label: 'Bitcoin'),
    CdsControlOption(value: 'eth', label: 'Ethereum'),
  ],
  selectedValues: watched,
  onChange: (next) => setState(() => watched = next),
)
```

## When to use / when not to

- Use for a list of independent options where any number can be chosen.
- Use `CdsRadioGroup` when only one may be chosen and `CdsCheckboxCell` rows when options need descriptions.
- This is a thin wrapper over `CdsControlGroup.checkbox` with CDS's tighter default `gap` of 0. Each checkbox already has a 44px tall hit area, which provides the visual spacing.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `List<CdsControlOption<T>>` | required | Options in display order. See `CdsControlGroup` for `CdsControlOption`. |
| `selectedValues` | `Set<T>` | required | Checked values. Controlled. |
| `onChange` | `ValueChanged<Set<T>>?` | `null` | Called with the full next set after a checkbox toggles. |
| `label` | `String?` | `null` | Heading in `headline`. Also the group's accessibility label. |
| `labelNode` | `Widget?` | `null` | Custom heading. |
| `gap` | `double` | `0` | Space token between options. |
| `direction` | `Axis` | `Axis.vertical` | `Axis.horizontal` lays options in a wrapping row. |
| `disabled` | `bool` | `false` | Disables every option. |
| `semanticLabel` | `String?` | `null` | Overrides `label` for screen readers. |

## Examples

### Read-only and disabled options

```dart
CdsCheckboxGroup<String>(
  label: 'Send me',
  options: const [
    CdsControlOption(value: 'price', label: 'Price alerts'),
    CdsControlOption(value: 'security', label: 'Security alerts', readOnly: true),
    CdsControlOption(value: 'promo', label: 'Promotions', disabled: true),
  ],
  selectedValues: {...alerts, 'security'},
  onChange: (next) => setState(() => alerts = next..remove('security')),
)
```

## Accessibility

- A labelled semantics container; each checkbox reports its checked state, label and enabled or read-only state.
- Every checkbox is a tab stop; Space toggles the focused one.

## Motion

See `CdsCheckbox`: the glyph scales and fades over `CdsDurations.moderate1`, reversibly, and reduced motion applies changes immediately.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` (`Checkbox` elements) | `options` (`List<CdsControlOption<T>>`) |
| `selectedValues` (`Set`) | `selectedValues` (`Set<T>`) |
| `onChange(value)` (toggled value) | `onChange(Set<T>)` (next set) |
| `label` | `label` / `labelNode` |
| `accessibilityLabel` | `semanticLabel` |
