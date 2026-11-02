# CdsControlGroup

A labelled set of radios, checkboxes or switches built from a list of options, with one API for single and multiple selection.

CDS reference: https://cds.coinbase.com/components/inputs/ControlGroup

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsControlGroup<String>.radio(
  label: 'Payment method',
  options: const [
    CdsControlOption(value: 'bank', label: 'Bank account'),
    CdsControlOption(value: 'card', label: 'Debit card'),
  ],
  value: method,
  onChange: (value) => setState(() => method = value),
)
```

## When to use / when not to

- Use when the options come from data and render as a plain list of controls.
- Use `CdsRadioCell` / `CdsCheckboxCell` rows instead when each option needs a description or a bordered card look.
- `CdsRadioGroup` and `CdsCheckboxGroup` are thin wrappers over this widget, kept for parity with CDS.

## Parameters

Constructors:

- `CdsControlGroup<T>.radio({required List<CdsControlOption<T>> options, required T? value, ValueChanged<T>? onChange, ...})`: single selection; `onChange` receives the selected value.
- `CdsControlGroup<T>.checkbox({required List<CdsControlOption<T>> options, required Set<T> value, ValueChanged<Set<T>>? onChange, ...})`: multiple selection; `onChange` receives the full next set.
- `CdsControlGroup<T>.switches({...same as checkbox})`: multiple selection rendered as `CdsSwitch`.

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `List<CdsControlOption<T>>` | required | Options in display order. |
| `value` | `T?` (radio) / `Set<T>` (checkbox, switches) | required | Current selection. Controlled. |
| `onChange` | `ValueChanged<T>?` (radio) / `ValueChanged<Set<T>>?` | `null` | Selection callback. Null makes every option inert. |
| `label` | `String?` | `null` | Heading above the options in `headline`. Also the group's accessibility label. |
| `labelNode` | `Widget?` | `null` | Custom heading. Takes precedence over `label`. |
| `gap` | `double` | `2` | Space token between options (16px). |
| `direction` | `Axis` | `Axis.vertical` | `Axis.horizontal` lays options in a wrapping row. |
| `disabled` | `bool` | `false` | Disables every option. |
| `controlColor` | `CdsColor?` | `null` | Radio dot color, checkbox glyph color, or switch track color when on. |
| `semanticLabel` | `String?` | `null` | Overrides `label` for screen readers. |
| `radioSemanticLabel` | `String?` | `null` | Radio only. Appended to each option's label with `{{number}}` and `{{total}}` filled in, e.g. `'{{number}} of {{total}}'`. |

`CdsControlOption<T>`:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `T` | required | Value reported through `onChange`. |
| `label` | `String?` | `null` | Option label. |
| `labelNode` | `Widget?` | `null` | Custom label widget. |
| `disabled` | `bool` | `false` | Disables this option; arrow keys skip it. |
| `readOnly` | `bool` | `false` | Read-only option. |
| `semanticLabel` | `String?` | `null` | Required when `label` is null. |
| `semanticHint` | `String?` | `null` | Extra hint. |

## Examples

### Checkboxes

```dart
CdsControlGroup<String>.checkbox(
  label: 'Contact me by',
  options: const [
    CdsControlOption(value: 'email', label: 'Email'),
    CdsControlOption(value: 'push', label: 'Push notifications'),
  ],
  value: channels,
  onChange: (next) => setState(() => channels = next),
)
```

### Switches

```dart
CdsControlGroup<String>.switches(
  label: 'Privacy',
  options: const [
    CdsControlOption(value: 'hide', label: 'Hide balances'),
    CdsControlOption(value: 'share', label: 'Share usage data'),
  ],
  value: privacy,
  onChange: (next) => setState(() => privacy = next),
)
```

### Horizontal radios

```dart
CdsControlGroup<String>.radio(
  label: 'Frequency',
  direction: Axis.horizontal,
  options: const [
    CdsControlOption(value: 'daily', label: 'Daily'),
    CdsControlOption(value: 'weekly', label: 'Weekly'),
  ],
  value: frequency,
  onChange: (v) => setState(() => frequency = v),
)
```

## Accessibility

- The group is a labelled semantics container. Radio groups use `SemanticsRole.radioGroup`.
- Radio groups are a single tab stop: Tab lands on the selected option, or the first enabled one when nothing is selected. Up/Down and Left/Right move focus and selection to the next or previous enabled option and wrap at the ends; Left/Right are mirrored in right-to-left layouts.
- Checkbox and switch groups keep every option as its own tab stop; Space toggles.

## Motion

Each control animates as documented on `CdsRadio`, `CdsCheckbox` and `CdsSwitch`. The group adds no motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `ControlComponent={Radio}` | `CdsControlGroup.radio` |
| `ControlComponent={Checkbox}` | `CdsControlGroup.checkbox` |
| `ControlComponent={Switch}` | `CdsControlGroup.switches` |
| `options` | `options` (`CdsControlOption<T>`) |
| `value` (string or array) | `value` (`T?` or `Set<T>`) |
| `onChange(value, checked)` | `onChange(T)` or `onChange(Set<T>)` |
| `label` | `label` / `labelNode` |
| `gap` | `gap` |
| `direction` | `direction` |
| `aria-label` / `accessibilityLabel` | `semanticLabel` |
| `role` | set by constructor |
