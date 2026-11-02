# CdsCheckbox

A checkbox with an optional label, for turning one option on or off or selecting several items from a list.

CDS reference: https://cds.coinbase.com/components/inputs/Checkbox

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCheckbox(
  label: 'Remember this device',
  checked: remember,
  onChange: (value) => setState(() => remember = value),
)
```

## When to use / when not to

- Use for independent options the user can combine, or for a single opt-in such as accepting terms.
- Use `indeterminate` on a parent checkbox when only some of its children are checked.
- Use `CdsSwitch` for a setting that takes effect immediately, and `CdsRadio` / `CdsRadioGroup` when exactly one option may be chosen.
- For a list of options use `CdsCheckboxGroup` or `CdsControlGroup.checkbox`; for rich rows with a description use `CdsCheckboxCell`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `checked` | `bool` | `false` | Whether the box is checked. Controlled. |
| `onChange` | `ValueChanged<bool>?` | `null` | Called with `!checked` on tap. Null makes the checkbox inert and dimmed. |
| `indeterminate` | `bool` | `false` | Partially selected. Shows a minus glyph unless `checked` is also true; announced as mixed. |
| `label` | `String?` | `null` | Label next to the box. Also the accessibility label. |
| `labelNode` | `Widget?` | `null` | Custom label widget. Takes precedence over `label`. |
| `disabled` | `bool` | `false` | Blocks interaction and dims to 50%. |
| `readOnly` | `bool` | `false` | Blocks interaction and dims, but is announced as read-only rather than disabled. |
| `controlColor` | `CdsColor` | `CdsColor.fgInverse` | Glyph color. |
| `background` | `CdsColor?` | `null` | Box fill in both states. Defaults to `bg` off, `bgPrimary` on. |
| `borderColor` | `CdsColor?` | `null` | Box border in both states. Defaults to `bgLineHeavy` off, `bgPrimary` on. |
| `borderRadius` | `int` | `100` | Radius token (4px). |
| `borderWidth` | `int` | `100` | Border width token (1px). |
| `elevation` | `CdsElevation` | `CdsElevation.none` | Box shadow. |
| `controlSize` | `double?` | `null` | Box size in px. Defaults to `theme.controlSize.checkboxSize` (20). The glyph is four fifths of it. |
| `font` | `CdsFont` | `CdsFont.body` | Label ramp entry. |
| `color` | `CdsColor?` | `null` | Fixed label color. By default the label moves from `fgMuted` to `fg` when checked. |
| `semanticLabel` | `String?` | `null` | Replaces the label for screen readers. Required when there is no `label`. |
| `semanticHint` | `String?` | `null` | Extra hint read after the label. |
| `focusNode` | `FocusNode?` | `null` | Focus node for the control. |
| `autofocus` | `bool` | `false` | Request focus on first build. |

## Examples

### Indeterminate parent

```dart
final all = selected.length == assets.length;
CdsCheckbox(
  label: 'All assets',
  checked: all,
  indeterminate: selected.isNotEmpty && !all,
  onChange: (v) => setState(() => selected = v ? {...assets} : {}),
)
```

### Without a visible label

```dart
CdsCheckbox(
  semanticLabel: 'Select Bitcoin',
  checked: selected.contains('btc'),
  onChange: (v) => toggle('btc', v),
)
```

### Disabled and read-only

```dart
const CdsCheckbox(label: 'Unavailable', disabled: true)
const CdsCheckbox(label: 'Required', checked: true, readOnly: true)
```

## Accessibility

- Exposes checked state (`checked: true/false`, or `mixed` when indeterminate), the label, enabled state and a tap action. Read-only boxes are announced as read-only.
- The hit area is padded to at least 44x44 even though the box is 20px.
- Tab focuses the checkbox and shows the CDS focus ring; Space or Enter toggles.
- The box centers on the label's first line and follows text scaling; long labels wrap.

## Motion

- On change the glyph scales from 0.9 to 1 and fades in over `CdsDurations.moderate1` with `CdsCurves.enterFunctional` (out with `CdsCurves.global`), and fill, border and label color cross-fade with it. Toggling mid-animation reverses from the current value.
- Press feedback: the row dims to 82% opacity on pointer-down. A light haptic fires on toggle.
- Reduced motion: the new state appears immediately.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `checked` | `checked` |
| `onChange(value, checked)` | `onChange(bool)` (groups handle values) |
| `indeterminate` | `indeterminate` |
| `children` | `label` / `labelNode` |
| `disabled` / `readOnly` | `disabled` / `readOnly` |
| `controlColor`, `background`, `borderColor`, `borderRadius`, `borderWidth`, `elevation`, `controlSize` | same names |
| `font`, `color` | `font`, `color` |
| `accessibilityLabel` / `accessibilityHint` | `semanticLabel` / `semanticHint` |
| `value` | not needed; see `CdsControlGroup` |
