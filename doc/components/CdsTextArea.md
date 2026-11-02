# CdsTextArea

A multiline `CdsTextInput` for longer text such as notes or a support message. It grows from `minLines` to `maxLines`, then scrolls, and can show a character counter.

CDS reference: https://cds.coinbase.com/components/inputs/TextInput (CDS uses TextInput with `multiline`; this wraps that setup.)

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTextArea(
  label: 'Message',
  placeholder: 'Describe what happened',
  value: message,
  onChange: (v) => setState(() => message = v),
  maxLength: 280,
)
```

Control it with `value` + `onChange`, or with a `controller`, exactly like `CdsTextInput`.

## When to use / when not to

- Use for text that can run to several lines: feedback, notes, descriptions.
- Use `CdsTextInput` for short single-line values.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `TextEditingController?` | `null` | Owns the text when given. |
| `value` | `String?` | `null` | Text to show when no controller is given. |
| `onChange` | `ValueChanged<String>?` | `null` | Full text after every edit. |
| `focusNode` | `FocusNode?` | `null` | |
| `label` | `String?` | `null` | |
| `labelNode` | `Widget?` | `null` | |
| `placeholder` | `String?` | `null` | |
| `helperText` | `String?` | `null` | Colored by `variant`. |
| `helperTextErrorIconSemanticLabel` | `String` | `'error'` | |
| `variant` | `CdsInputVariant` | `foregroundMuted` | |
| `minLines` | `int` | `3` | Visible lines when empty. |
| `maxLines` | `int?` | `6` | Lines before scrolling. Null grows without limit. |
| `maxLength` | `int?` | `null` | Character limit. Shows a `count/max` counter at the end of the helper row; it turns `fgNegative` at the limit. |
| `textAlign` | `TextAlign` | `TextAlign.start` | |
| `font` | `CdsFont` | `CdsFont.body` | |
| `disabled` | `bool` | `false` | |
| `readOnly` | `bool` | `false` | |
| `bordered` | `bool` | `true` | |
| `borderRadius` | `int` | `200` | Radius token. |
| `inputBackground` | `CdsColor` | `CdsColor.bg` | |
| `keyboardType` | `TextInputType?` | `null` (`multiline`) | |
| `textInputAction` | `TextInputAction?` | `null` (`newline`) | |
| `textCapitalization` | `TextCapitalization` | `sentences` | |
| `inputFormatters` | `List<TextInputFormatter>?` | `null` | |
| `autofocus` | `bool` | `false` | |
| `autocorrect` | `bool` | `true` | |
| `enableSuggestions` | `bool` | `true` | |
| `onFocus` | `VoidCallback?` | `null` | |
| `onBlur` | `VoidCallback?` | `null` | |
| `semanticLabel` | `String?` | `null` | |
| `counterSemanticLabel` | `String Function(int count, int max)?` | `null` | Counter's accessibility label. Defaults to `'$count of $max characters'`. |

## Examples

### Error state

```dart
const CdsTextArea(
  label: 'Reason',
  variant: CdsInputVariant.negative,
  helperText: 'Add a reason to continue',
)
```

### Fixed height that scrolls

```dart
CdsTextArea(label: 'Notes', minLines: 4, maxLines: 4, controller: notesController)
```

## Accessibility

The field is one multiline text field node labeled with `label`. The counter reads as "12 of 280 characters". Negative helper text is a live region with an error icon.

## Motion

Same as `CdsTextInput`: the focus border cross-fades in `moderate1`; instant under reduced motion. The field grows line by line without animation.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `multiline` | always on |
| `numberOfLines` | `minLines` |
| `maxLength` | `maxLength` (plus counter) |
| other TextInput props | same as `CdsTextInput` |
