# CdsRadio

A single radio button with an optional label. Most screens should use `CdsRadioGroup`, which manages selection and keyboard navigation for a set of radios.

CDS reference: https://cds.coinbase.com/components/inputs/Radio

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsRadio(
  label: 'Bank account',
  checked: method == 'bank',
  onChange: (_) => setState(() => method = 'bank'),
)
```

## When to use / when not to

- Use when exactly one option from a small, visible set must be chosen.
- Prefer `CdsRadioGroup` or `CdsControlGroup.radio` over hand-placed radios: they make the set one tab stop with arrow-key selection.
- Use `CdsRadioCell` when each option needs a description, and `CdsCheckbox` when several options can be chosen.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `checked` | `bool` | `false` | Whether this radio is selected. Controlled. |
| `onChange` | `ValueChanged<bool>?` | `null` | Called with `!checked` on tap. Null makes the radio inert and dimmed. |
| `label` | `String?` | `null` | Label next to the circle. Also the accessibility label. |
| `labelNode` | `Widget?` | `null` | Custom label widget. Takes precedence over `label`. |
| `disabled` | `bool` | `false` | Blocks interaction and dims to 50%. |
| `readOnly` | `bool` | `false` | Blocks interaction and dims, announced as read-only. |
| `controlColor` | `CdsColor` | `CdsColor.bgPrimary` | Dot color and checked border color. |
| `background` | `CdsColor` | `CdsColor.bg` | Circle fill. |
| `borderColor` | `CdsColor?` | `null` | Border in both states. Defaults to `bgLineHeavy` off and `controlColor` on. |
| `borderWidth` | `int` | `100` | Border width token (1px). |
| `elevation` | `CdsElevation` | `CdsElevation.none` | Circle shadow. |
| `controlSize` | `double?` | `null` | Circle size in px. Defaults to `theme.controlSize.radioSize` (20). |
| `dotSize` | `double?` | `null` | Dot diameter. Defaults to two thirds of the control size. |
| `font` | `CdsFont` | `CdsFont.body` | Label ramp entry. |
| `color` | `CdsColor?` | `null` | Fixed label color. By default `fgMuted` off and `fg` on. |
| `semanticLabel` | `String?` | `null` | Replaces the label for screen readers. Required when there is no `label`. |
| `semanticHint` | `String?` | `null` | Extra hint. |
| `focusNode` | `FocusNode?` | `null` | Focus node for the control. |
| `autofocus` | `bool` | `false` | Request focus on first build. |

## Examples

### Custom color

```dart
CdsRadio(
  label: 'Earn rewards',
  checked: true,
  controlColor: CdsColor.bgPositive,
  onChange: (_) {},
)
```

### Disabled

```dart
const CdsRadio(label: 'Wire transfer', disabled: true)
```

## Accessibility

- Exposes checked state, membership in a mutually exclusive group, the label, enabled state and a tap action.
- Hit area padded to at least 44x44. Tab focuses, Space or Enter selects. Arrow keys work inside `CdsRadioGroup`.

## Motion

- The dot scales from 0.9 to 1 and fades in over `CdsDurations.moderate1` (`CdsCurves.enterFunctional` in, `CdsCurves.global` out); the border and label color cross-fade with it, reversibly.
- Light haptic on press. Reduced motion shows the new state immediately.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `checked` | `checked` |
| `onChange(value, checked)` | `onChange(bool)` |
| `children` | `label` / `labelNode` |
| `controlColor`, `background`, `borderColor`, `borderWidth`, `elevation`, `controlSize`, `dotSize` | same names |
| `disabled` / `readOnly` | `disabled` / `readOnly` |
| `accessibilityLabel` / `accessibilityHint` | `semanticLabel` / `semanticHint` |
