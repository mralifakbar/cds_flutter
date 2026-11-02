# CdsTextInput

A labeled text field with a bordered input area, optional `start`/`end` slots, prefix and suffix text, and helper text that reflects validation state. Reach for it for any single-line or short multiline text entry.

CDS reference: https://cds.coinbase.com/components/inputs/TextInput

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTextInput(
  label: 'Email',
  placeholder: 'satoshi@example.com',
  value: email,
  onChange: (v) => setState(() => email = v),
  keyboardType: TextInputType.emailAddress,
)
```

### Controlling the text

`CdsTextInput` supports two modes. Pick one per field.

| Mode | How | Notes |
| --- | --- | --- |
| `value` + `onChange` | Pass the current string and update it in `onChange`. | CDS style. When `value` changes from outside, the text is replaced and the caret moves to the end. |
| `controller` | Pass a `TextEditingController` you own and dispose. | Use for selection control or reading text imperatively. `value` is ignored; `onChange` still fires. |

## When to use / when not to

- Use for names, emails, amounts, addresses and other free text.
- Use `CdsTextFormField` when the field belongs to a `Form` with validators.
- Use `CdsTextArea` for long text that needs several lines and a character counter.
- Use `CdsSearchInput` for search; it has the filled pill look and a clear button.
- Do not use it to pick from a fixed list; use a select component instead.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `TextEditingController?` | `null` | Owns the text. See "Controlling the text". |
| `value` | `String?` | `null` | Text to show when no controller is given. |
| `onChange` | `ValueChanged<String>?` | `null` | Called with the full text after every edit. |
| `focusNode` | `FocusNode?` | `null` | Created internally when null. |
| `label` | `String?` | `null` | Label text. Also the accessibility label unless `semanticLabel` is set. |
| `labelNode` | `Widget?` | `null` | Custom label widget, shown instead of `label`. |
| `labelFont` | `CdsFont` | `CdsFont.label2` | Ramp entry for `label`. |
| `labelColor` | `CdsColor` | `CdsColor.fgMuted` | Color of `label`. |
| `labelVariant` | `CdsInputLabelVariant` | `outside` | `outside` puts the label above the field. `inside` puts it inside the border: stacked above the text at size `l`, inline at `m` and `s`. |
| `placeholder` | `String?` | `null` | Hint text shown while empty, in `fgMuted`. |
| `helperText` | `String?` | `null` | Text under the field, colored by `variant`. With `negative` it leads with an error icon. |
| `helperTextNode` | `Widget?` | `null` | Custom helper widget, shown instead of `helperText`. |
| `helperTextErrorIconSemanticLabel` | `String` | `'error'` | Accessibility label of the error icon. |
| `variant` | `CdsInputVariant` | `foregroundMuted` | Sentiment: `positive`, `negative`, `foreground`, `primary`, `foregroundMuted`, `secondary`. |
| `size` | `CdsTextInputSize?` | `null` (`l`) | Vertical density inside the border: `l` 16px, `m` 12px, `s` 8px vertical padding. |
| `compact` | `bool` | `false` | Size `s` with the label inline. Used only when `size` is null. |
| `start` | `Widget?` | `null` | Content inside the border before the text, for example `CdsInputIcon`. |
| `end` | `Widget?` | `null` | Content inside the border after the text, for example `CdsInputIconButton`. |
| `prefix` | `String?` | `null` | Muted text fixed before the input, for example `'$'`. |
| `suffix` | `String?` | `null` | Muted text fixed after the input (`label1`), for example `'USD'`. |
| `textAlign` | `TextAlign` | `TextAlign.start` | Aligns the typed text and the helper text. |
| `font` | `CdsFont` | `CdsFont.body` | Ramp entry for the typed text. |
| `disabled` | `bool` | `false` | Not editable, not focusable, 50% opacity. |
| `readOnly` | `bool` | `false` | Not editable but focusable and selectable. Shows a `bgSecondary` field. |
| `bordered` | `bool` | `true` | Draw the border and focus border. |
| `borderRadius` | `int` | `200` | Radius token (200 is 8px, 1000 is a pill). |
| `focusedBorderWidth` | `int?` | `null` (100) | Extra border width token while focused. |
| `inputBackground` | `CdsColor` | `CdsColor.bg` | Field background. |
| `obscureText` | `bool` | `false` | Hide characters, for passwords. Forces one line. |
| `keyboardType` | `TextInputType?` | `null` | Multiline fields default to `TextInputType.multiline`. |
| `textInputAction` | `TextInputAction?` | `null` | Keyboard action button. |
| `textCapitalization` | `TextCapitalization` | `none` | |
| `inputFormatters` | `List<TextInputFormatter>?` | `null` | Filters and reshapes input. |
| `maxLength` | `int?` | `null` | Hard character limit. No counter is drawn. |
| `minLines` | `int?` | `null` | |
| `maxLines` | `int?` | `1` | Null grows without limit. |
| `autofocus` | `bool` | `false` | |
| `autocorrect` | `bool` | `true` | |
| `enableSuggestions` | `bool` | `true` | |
| `autofillHints` | `Iterable<String>?` | `null` | For example `[AutofillHints.email]`. |
| `onSubmitEditing` | `ValueChanged<String>?` | `null` | Keyboard submit. |
| `onFocus` | `VoidCallback?` | `null` | |
| `onBlur` | `VoidCallback?` | `null` | |
| `onTap` | `VoidCallback?` | `null` | Tap on the editable area. |
| `semanticLabel` | `String?` | `null` | Overrides `label` for screen readers. |
| `semanticHint` | `String?` | `null` | Defaults to `helperText` (except for `negative`, which is announced instead). |

## Examples

### Validation states

```dart
CdsTextInput(
  label: 'Email',
  value: email,
  onChange: (v) => setState(() => email = v),
  variant: valid ? CdsInputVariant.positive : CdsInputVariant.negative,
  helperText: valid ? 'Looks good' : 'Enter a valid email address',
)
```

### Prefix and suffix

```dart
CdsTextInput(
  label: 'Amount',
  prefix: r'$',
  suffix: 'USD',
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  value: amount,
  onChange: (v) => setState(() => amount = v),
)
```

### Password with reveal button

```dart
CdsTextInput(
  label: 'Password',
  obscureText: hidden,
  value: password,
  onChange: (v) => setState(() => password = v),
  end: CdsInputIconButton(
    hidden ? CdsIconName.visible : CdsIconName.invisible,
    semanticLabel: hidden ? 'Show password' : 'Hide password',
    onPress: () => setState(() => hidden = !hidden),
  ),
)
```

### Inside label and sizes

```dart
const CdsTextInput(label: 'Name', labelVariant: CdsInputLabelVariant.inside)
const CdsTextInput(label: 'Name', labelVariant: CdsInputLabelVariant.inside, size: CdsTextInputSize.m)
const CdsTextInput(label: 'Name', compact: true)
```

### Disabled and read only

```dart
const CdsTextInput(label: 'Account ID', value: '0042', readOnly: true)
const CdsTextInput(label: 'Network', value: 'Ethereum', disabled: true)
```

## Accessibility

- The editable area is one text field node labeled with `semanticLabel ?? label` and hinted with `helperText`.
- With `variant: negative`, the helper text is a live region, so the error is announced when it appears, and it carries an info icon so the state is not color alone.
- Tapping the label, prefix or suffix focuses the field.
- Works without `MaterialApp`: Material localizations are supplied when the app does not provide them.
- Text scales with the platform setting; the field uses minimum heights, never fixed ones.

## Motion

On focus a second border fades in over the first in `CdsDurations.moderate1` with `CdsCurves.enterFunctional`, and fades out with `CdsCurves.exitFunctional`. Under reduced motion the change is instant.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `value` / `onChangeText` | `value` / `onChange` |
| `onChange` (event) | `onChange` (string) |
| `label`, `labelNode`, `labelFont`, `labelColor`, `labelVariant` | same names |
| `placeholder`, `helperText`, `variant` | same names |
| `helperTextErrorIconAccessibilityLabel` | `helperTextErrorIconSemanticLabel` |
| `size`, `compact` | `size`, `compact` |
| `start`, `end`, `suffix` | `start`, `end`, `suffix` |
| (none) | `prefix` |
| `align`, `textAlign` | `textAlign` |
| `font` | `font` |
| `disabled`, `readOnly`, `bordered`, `borderRadius`, `focusedBorderWidth`, `inputBackground` | same names |
| `secureTextEntry` | `obscureText` |
| `keyboardType`, `returnKeyType` | `keyboardType`, `textInputAction` |
| `maxLength`, `multiline`, `numberOfLines` | `maxLength`, `maxLines`, `minLines` |
| `onSubmitEditing`, `onFocus`, `onBlur` | same names |
| `accessibilityLabel`, `accessibilityHint` | `semanticLabel`, `semanticHint` |
| `enableColorSurge`, `testIDMap`, `width`, `height` | not ported |
