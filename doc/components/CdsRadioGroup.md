# CdsRadioGroup

A labelled set of radio buttons with single selection and arrow-key navigation.

CDS reference: https://cds.coinbase.com/components/inputs/RadioGroup

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsRadioGroup<String>(
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

- Use for two to about seven mutually exclusive options that should all be visible.
- For longer lists use a select (see the overlays category). For options with descriptions use `CdsRadioCell` rows.
- This is a thin wrapper over `CdsControlGroup.radio`; both behave identically.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `List<CdsControlOption<T>>` | required | Options in display order. See `CdsControlGroup` for `CdsControlOption`. |
| `value` | `T?` | required | Selected value, or null for none. Controlled. |
| `onChange` | `ValueChanged<T>?` | `null` | Called with the value the user selects. |
| `label` | `String?` | `null` | Heading in `headline`. Also the group's accessibility label. |
| `labelNode` | `Widget?` | `null` | Custom heading. |
| `gap` | `double` | `2` | Space token between options. |
| `direction` | `Axis` | `Axis.vertical` | `Axis.horizontal` lays options in a wrapping row. |
| `disabled` | `bool` | `false` | Disables every option. |
| `controlColor` | `CdsColor` | `CdsColor.bgPrimary` | Dot and checked border color. |
| `semanticLabel` | `String?` | `null` | Overrides `label` for screen readers. |
| `radioSemanticLabel` | `String?` | `null` | Appended to each option's label with `{{number}}` and `{{total}}` replaced, e.g. `'{{number}} of {{total}}'`. |

## Examples

### Horizontal

```dart
CdsRadioGroup<String>(
  label: 'Frequency',
  direction: Axis.horizontal,
  gap: 3,
  options: const [
    CdsControlOption(value: 'daily', label: 'Daily'),
    CdsControlOption(value: 'weekly', label: 'Weekly'),
    CdsControlOption(value: 'monthly', label: 'Monthly'),
  ],
  value: frequency,
  onChange: (v) => setState(() => frequency = v),
)
```

### Disabled option and position announcements

```dart
CdsRadioGroup<String>(
  label: 'Payment method',
  radioSemanticLabel: '{{number}} of {{total}}',
  options: const [
    CdsControlOption(value: 'bank', label: 'Bank account'),
    CdsControlOption(value: 'gift', label: 'Gift card', disabled: true),
  ],
  value: method,
  onChange: (v) => setState(() => method = v),
)
```

## Accessibility

- Semantics container with `SemanticsRole.radioGroup` and the group label; each radio reports checked state and mutually exclusive group membership.
- One tab stop: Tab lands on the selected option (or the first enabled one), and the next Tab leaves the group.
- Arrow Down/Right select the next enabled option, Up/Left the previous, wrapping at the ends. Left and Right are mirrored in right-to-left layouts. Disabled options are skipped.

## Motion

Each radio's dot scales and fades in over `CdsDurations.moderate1`, reversibly; see `CdsRadio`. Reduced motion shows changes immediately.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `options` (`Record<value, label>`) | `options` (`List<CdsControlOption<T>>`) |
| `value` | `value` |
| `onChange(value, checked)` | `onChange(T)` |
| `label` | `label` / `labelNode` |
| `direction`, `gap` | `direction`, `gap` |
| `controlColor` | `controlColor` |
| `radioAccessibilityLabel` | `radioSemanticLabel` |
| `accessibilityLabel` | `semanticLabel` |
