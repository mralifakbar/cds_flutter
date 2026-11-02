# CdsCheckboxCell

A full-width bordered row with a checkbox, a title and an optional description; the whole row is the touch target.

CDS reference: https://cds.coinbase.com/components/inputs/CheckboxCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCheckboxCell(
  title: 'Recurring buy',
  description: 'Repeat this purchase every week',
  checked: recurring,
  onChange: (value) => setState(() => recurring = value),
)
```

## When to use / when not to

- Use for opt-ins and multi-select lists where each option needs a description.
- Use `CdsCheckbox` or `CdsCheckboxGroup` for plain labels, and `CdsRadioCell` when only one row may be chosen.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | required | Title in `headline`. Also part of the accessibility label. |
| `titleNode` | `Widget?` | `null` | Custom title widget; `title` is still used for the accessibility label. |
| `description` | `String?` | `null` | Muted `body` text under the title. |
| `descriptionNode` | `Widget?` | `null` | Custom description widget. |
| `checked` | `bool` | `false` | Whether the row is selected. Controlled. |
| `onChange` | `ValueChanged<bool>?` | `null` | Called with `!checked` when the row is pressed. Null makes the row inert and dimmed. |
| `indeterminate` | `bool` | `false` | Partially selected; announced as mixed. |
| `controlColor` | `CdsColor` | `CdsColor.fgInverse` | Checkbox glyph color. |
| `controlSize` | `double?` | `null` | Checkbox size in px. Defaults to `theme.controlSize.checkboxSize`. |
| `disabled` | `bool` | `false` | Blocks interaction and dims to 50%. |
| `readOnly` | `bool` | `false` | Blocks interaction and dims, announced as read-only. |
| `padding` | `double` | `2` | Space token around the content (16px). |
| `columnGap` | `double` | `2` | Space token between the control and the text. |
| `rowGap` | `double` | `0` | Space token between title and description. |
| `borderWidth` | `int` | `100` | Resting border width token (1px). |
| `borderRadius` | `int` | `200` | Radius token (8px). |
| `background` | `CdsColor` | `CdsColor.bg` | Row fill. |
| `borderColor` | `CdsColor` | `CdsColor.bgLine` | Resting border color. |
| `pressedBorderColor` | `CdsColor` | `CdsColor.bgPrimary` | Border color while pressed. |
| `pressedBorderWidth` | `int` | `200` | Border width token while pressed (2px). |
| `semanticLabel` | `String?` | `null` | Defaults to "title, description". |
| `semanticHint` | `String?` | `null` | Defaults to "Tap to check this option", or "Tap to uncheck this option" when checked. |
| `focusNode` | `FocusNode?` | `null` | Focus node for the row. |
| `autofocus` | `bool` | `false` | Request focus on first build. |

## Examples

### Several rows

```dart
CdsVStack(
  gap: 1.5,
  children: [
    CdsCheckboxCell(title: 'Email', description: 'Weekly summary', checked: email, onChange: setEmail),
    CdsCheckboxCell(title: 'Push', description: 'Price moves over 5%', checked: push, onChange: setPush),
    const CdsCheckboxCell(title: 'SMS', description: 'Not available in your region', disabled: true),
  ],
)
```

### Disabled

```dart
const CdsCheckboxCell(title: 'Wire', description: 'Not available on weekends', disabled: true)
```

## Accessibility

- The row is one node exposing the combined label, the CDS hint, checked state (or mixed when indeterminate), enabled or read-only state and a tap action.
- Tab focuses the row and shows the focus ring; Space or Enter activates.
- Text wraps freely and the control stays centered on the title's first line at any text scale.

## Motion

- Pointer-down fades in a 2px `pressedBorderColor` border over the resting one (`CdsDurations.moderate1`, enter-functional in, exit-functional out) and the content dims to 82%.
- The control animates as on `CdsCheckbox`. A light haptic fires on press.
- Reduced motion: the pressed border and control state change immediately.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title` | `title` / `titleNode` |
| `description` | `description` / `descriptionNode` |
| `checked` | `checked` |
| `onChange(value, checked)` | `onChange(bool)` |
| `indeterminate` | `indeterminate` |
| `controlColor`, `controlSize` | `controlColor`, `controlSize` |
| `disabled` / `readOnly` | `disabled` / `readOnly` |
| `padding`, `columnGap`, `rowGap` | same names |
| `borderWidth`, `borderRadius`, `background`, `borderColor` | same names |
| `pressedBorderColor`, `pressedBorderWidth` | same names |
| `accessibilityLabel` / `accessibilityHint` | `semanticLabel` / `semanticHint` |
