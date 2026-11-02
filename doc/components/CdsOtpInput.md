# CdsOtpInput

A one-time code field drawn as separate cells, for verification codes sent by SMS or email. Not part of CDS; it is built from the same field border, focus and helper text tokens as `CdsTextInput`.

CDS reference: none (extra component). Field styling follows https://cds.coinbase.com/components/inputs/TextInput

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsOtpInput(
  label: 'Verification code',
  value: code,
  onChange: (v) => setState(() => code = v),
  onComplete: verify,
)
```

Control it with `value` + `onChange`, or with a `controller`.

## When to use / when not to

- Use for short fixed-length codes: SMS or email verification, two-factor codes, PINs.
- Use `CdsTextInput` for codes of unknown length or long recovery phrases.

## Behavior

- One hidden text field drives all cells. Typing fills the next cell; backspace clears the last filled cell and moves back.
- Pasting a code fills every cell. Characters the formatter rejects are dropped and extra characters are cut at `length`.
- The platform's one-time-code autofill is enabled (`AutofillHints.oneTimeCode`).
- The caret always sits after the last character, so cells fill in order.
- `onComplete` fires each time the code reaches `length` characters.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `length` | `int` | `6` | Number of cells. Must be positive. |
| `controller` | `TextEditingController?` | `null` | Owns the code when given. |
| `value` | `String?` | `null` | Code to show when no controller is given. |
| `onChange` | `ValueChanged<String>?` | `null` | Whole code after every edit. |
| `onComplete` | `ValueChanged<String>?` | `null` | Code reached `length` characters. |
| `focusNode` | `FocusNode?` | `null` | |
| `label` | `String?` | `null` | Label above the cells. Tapping it focuses the field. |
| `helperText` | `String?` | `null` | Text under the cells, colored by `variant`. |
| `helperTextErrorIconSemanticLabel` | `String` | `'error'` | |
| `variant` | `CdsInputVariant` | `foregroundMuted` | `negative` marks every cell invalid and shows the error icon. |
| `obscureText` | `bool` | `false` | Show a dot for each character. |
| `disabled` | `bool` | `false` | Not editable, 50% opacity. |
| `autofocus` | `bool` | `false` | |
| `keyboardType` | `TextInputType` | `TextInputType.number` | |
| `inputFormatters` | `List<TextInputFormatter>?` | `null` (digits only) | Replaces the digits-only filter. |
| `font` | `CdsFont` | `CdsFont.title3` | Ramp entry for the characters. |
| `semanticLabel` | `String?` | `null` | Defaults to `label`, then `'Verification code'`. |

Cells share the available width equally with 8px gaps. Each cell is at least 52px tall (12px vertical padding plus the `title3` line height) and grows with text scale.

## Examples

### Error after a failed check

```dart
CdsOtpInput(
  value: code,
  onChange: (v) => setState(() => code = v),
  variant: failed ? CdsInputVariant.negative : CdsInputVariant.foregroundMuted,
  helperText: failed ? 'That code is not right. Check the latest SMS and try again.' : null,
)
```

### Letters and digits

```dart
CdsOtpInput(
  length: 8,
  keyboardType: TextInputType.text,
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Z0-9]'))],
  onChange: (v) => setState(() => code = v),
)
```

### PIN

```dart
const CdsOtpInput(label: 'PIN', length: 4, obscureText: true)
```

## Accessibility

- Screen readers see one text field labeled `semanticLabel ?? label ?? 'Verification code'`, with a hint that names the position, for example "Digit 3 of 6", or "All 6 digits entered". The visual cells are hidden from the semantics tree.
- With `obscureText`, the field value is obscured for screen readers too.
- `negative` helper text is a live region and carries an info icon.
- Reachable with Tab; the active cell shows the focus border.

## Motion

The active cell's focus border cross-fades in `CdsDurations.moderate1` (`enterFunctional` in, `exitFunctional` out) as it moves from cell to cell. Reduced motion makes it instant.

## CDS React Native mapping

Not in CDS. Closest equivalents:

| CDS concept | Flutter parameter |
| --- | --- |
| TextInput `variant`, `helperText`, `label` | same names |
| TextInput `secureTextEntry` | `obscureText` |
| TextInput `keyboardType` | `keyboardType` |
