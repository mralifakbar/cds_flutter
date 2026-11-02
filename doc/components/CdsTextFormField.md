# CdsTextFormField

A `CdsTextInput` that takes part in a Flutter `Form`: validators, autovalidate, save and reset. Reach for it when a screen collects several fields and checks them together.

CDS reference: https://cds.coinbase.com/components/inputs/TextInput (CDS has no form-field variant; this is the Flutter `FormField` integration of TextInput.)

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
final formKey = GlobalKey<FormState>();

Form(
  key: formKey,
  child: CdsTextFormField(
    label: 'Email',
    validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email address' : null,
    onSaved: (v) => email = v ?? '',
  ),
)

// On submit:
if (formKey.currentState!.validate()) formKey.currentState!.save();
```

## When to use / when not to

- Use inside a `Form` when fields are validated together on submit or as the user types.
- Use `CdsTextInput` with your own `variant`/`helperText` when one field validates itself.

## Behavior

- While the field has an error (from `validator` or `forceErrorText`), it shows `CdsInputVariant.negative` and the error message as helper text, with an error icon. The message is announced to screen readers when it appears.
- Without an error it shows the `variant` and `helperText` you passed.
- The text lives in a `TextEditingController`. Pass `controller` to own it, or `initialValue` to let the field create one. Not both.
- `FormState.reset()` restores `initialValue` (or the controller's text at creation).

## Parameters

Form parameters:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `TextEditingController?` | `null` | Owns the text. Edits made to it update the form value. |
| `initialValue` | `String?` | `null` (`''`) | Starting text when no controller is given. |
| `validator` | `FormFieldValidator<String>?` | `null` | Return an error message, or null when valid. |
| `onSaved` | `FormFieldSetter<String>?` | `null` | Called by `FormState.save()`. |
| `autovalidateMode` | `AutovalidateMode?` | `null` (`disabled`) | For example `AutovalidateMode.onUserInteraction`. |
| `forceErrorText` | `String?` | `null` | Shows this error regardless of `validator`. |
| `restorationId` | `String?` | `null` | |
| `onChange` | `ValueChanged<String>?` | `null` | Called with the full text after every edit. |

Visual and input parameters, with the same types, defaults and meaning as on [CdsTextInput](CdsTextInput.md): `focusNode`, `label`, `labelNode`, `labelVariant`, `placeholder`, `helperText`, `helperTextErrorIconSemanticLabel`, `variant`, `size`, `compact`, `start`, `end`, `prefix`, `suffix`, `textAlign`, `font`, `disabled`, `readOnly`, `bordered`, `borderRadius`, `inputBackground`, `obscureText`, `keyboardType`, `textInputAction`, `textCapitalization`, `inputFormatters`, `maxLength`, `minLines`, `maxLines` (default `1`), `autofocus`, `autocorrect`, `enableSuggestions`, `autofillHints`, `onSubmitEditing`, `onFocus`, `onBlur`, `semanticLabel`.

`disabled: true` also sets the `FormField` `enabled` flag to false, so the field skips validation.

## Examples

### Validate as the user types

```dart
CdsTextFormField(
  label: 'Email',
  keyboardType: TextInputType.emailAddress,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email address' : null,
)
```

### Server-side error

```dart
CdsTextFormField(
  label: 'Promo code',
  forceErrorText: serverError, // e.g. 'This code has expired'
)
```

### Save and reset

```dart
CdsButton(label: 'Save', onPress: () {
  if (formKey.currentState!.validate()) formKey.currentState!.save();
})
CdsButton(label: 'Reset', variant: CdsButtonVariant.secondary, onPress: () => formKey.currentState!.reset())
```

## Accessibility

Same as `CdsTextInput`: a labeled text field node, helper text as its hint, and errors in a live region with an error icon so the state is not color alone.

## Motion

Same as `CdsTextInput`: the focus border cross-fades in `moderate1`; instant under reduced motion. Switching to the error state changes colors without animation.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| TextInput props | same as `CdsTextInput` |
| (none) | `validator`, `onSaved`, `autovalidateMode`, `forceErrorText`, `initialValue` |
