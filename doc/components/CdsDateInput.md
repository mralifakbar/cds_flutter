# CdsDateInput

A text field for typing a date, masked as `mm/dd/yyyy` by default, with built-in validation. Reach for it when people know the date already, such as a date of birth.

CDS reference: https://cds.coinbase.com/components/other/DateInput

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsDateInput(
  label: 'Date of birth',
  date: birthday,
  onChangeDate: (d) => setState(() => birthday = d),
  error: error,
  onErrorDate: (e) => setState(() => error = e),
)
```

## When to use / when not to

Use it for dates people type faster than they browse to. When seeing the week matters, use `CdsDatePicker` (typed field plus calendar) or `CdsCalendar`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `date` | `DateTime?` | required | The date shown. A non-null date replaces the text; null leaves the text alone so an incomplete value can be edited. |
| `onChangeDate` | `ValueChanged<DateTime?>` | required | Called with the parsed date when the text becomes a complete valid date, and with null when a complete date is edited or turns invalid. |
| `error` | `CdsDateInputValidationError?` | `null` | Current error, shown as negative helper text. Pass back what `onErrorDate` reports. |
| `onErrorDate` | `ValueChanged<CdsDateInputValidationError?>?` | `null` | Called after `onChangeDate` when validation fails, and with null when a previous non-custom error no longer applies. |
| `required` | `bool` | `false` | Leaving the field incomplete after typing reports a `required` error. |
| `separator` | `String` | `'/'` | Single character between fields. |
| `dateOrder` | `CdsDateOrder` | `CdsDateOrder.mdy` | `mdy`, `dmy` or `ymd`. |
| `minDate` | `DateTime?` | `null` | Earliest valid day, inclusive. |
| `maxDate` | `DateTime?` | `null` | Latest valid day, inclusive. |
| `disabledDates` | `List<DateTime>` | `const []` | Days that are rejected with `disabledDateError`. |
| `disabledDateRanges` | `List<DateTimeRange>` | `const []` | Inclusive ranges that are rejected. |
| `requiredError` | `String` | `'This field is required'` | Message for `required` errors. |
| `invalidDateError` | `String` | `'Please enter a valid date'` | Message for impossible dates (02/30/2026) and dates over 100 years outside `minDate`/`maxDate`. |
| `disabledDateError` | `String` | `'Date unavailable'` | Message for dates outside the range or in the disabled set. |
| `label` | `String?` | `null` | Field label and accessibility label. |
| `labelNode` | `Widget?` | `null` | Custom label widget. |
| `labelVariant` | `CdsInputLabelVariant` | `outside` | Label above or inside the field. |
| `placeholder` | `String?` | `'   /   /'` | Blanks around the separator, as in CDS. |
| `helperText` | `String?` | error message, else the pattern (`mm/dd/yyyy`) | Text under the field. |
| `variant` | `CdsInputVariant?` | `negative` with an error, else `foregroundMuted` | Field sentiment. |
| `size` | `CdsTextInputSize?` | `l` | Density inside the border. |
| `compact` | `bool` | `false` | Dense field with an inline label. |
| `start` | `Widget?` | `null` | Content inside the border before the text. |
| `end` | `Widget?` | `null` | Content inside the border after the text. |
| `disabled` | `bool` | `false` | Blocks editing and dims the field. |
| `readOnly` | `bool` | `false` | Shows the date without allowing edits. |
| `autofocus` | `bool` | `false` | Focus the field on first build. |
| `focusNode` | `FocusNode?` | `null` | Focus node of the text field. |
| `onChange` | `ValueChanged<String>?` | `null` | Raw text after every edit. Prefer `onChangeDate`. |
| `onFocus` / `onBlur` | `VoidCallback?` | `null` | Focus changes. |
| `onSubmitEditing` | `ValueChanged<String>?` | `null` | Keyboard done action. |
| `semanticLabel` | `String?` | `label` | Accessibility label override. |
| `semanticHint` | `String?` | helper text | Accessibility hint override. |

`CdsDateInputValidationError` has `type` (`CdsDateInputValidationErrorType.required`, `invalid`, `disabled` or `custom`) and `message`. Errors with type `custom` come from your app (for example server-side checks) and are never cleared by the input.

### Event order

As in CDS:

1. Typing into an empty field: `onChange`, `onChange`, ..., `onChangeDate`, `onErrorDate`.
2. Editing a complete date: `onChange`, `onChangeDate(null)`, `onChange`, ..., `onChangeDate`, `onErrorDate`.

### Typing rules

Only digits and the separator are accepted. The separator is inserted when the user types a digit where it belongs, a separator typed anywhere else is ignored, and pasted digits are reformatted (`03152026` becomes `03/15/2026`). The number keyboard is shown.

## Examples

### Required, no future dates

```dart
CdsDateInput(
  label: 'Date of birth',
  date: birthday,
  onChangeDate: (d) => setState(() => birthday = d),
  error: error,
  onErrorDate: (e) => setState(() => error = e),
  required: true,
  maxDate: DateTime.now(),
)
```

### Day first with dots

```dart
CdsDateInput(
  label: 'Travel date',
  date: date,
  onChangeDate: (d) => setState(() => date = d),
  dateOrder: CdsDateOrder.dmy,
  separator: '.',
)
```

### App-provided error

```dart
CdsDateInput(
  label: 'Settlement date',
  date: date,
  onChangeDate: (d) => setState(() => date = d),
  error: const CdsDateInputValidationError(
    CdsDateInputValidationErrorType.custom,
    'Markets are closed on this date. Pick another business day.',
  ),
)
```

## Accessibility

- The field reads its label and, as a hint, the expected pattern. Errors appear with an info icon and are announced as a live region.
- Everything else follows `CdsTextInput`: 44px slots, focus border, text scaling without clipping.

## Motion

Same as `CdsTextInput`: the focus border fades in with `moderate1` enter-functional easing, and is instant under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `date` / `onChangeDate` | `date` / `onChangeDate` |
| `error` / `onErrorDate` | `error` / `onErrorDate` |
| `required` | `required` |
| `separator` | `separator` |
| locale-derived field order | `dateOrder` |
| `minDate` / `maxDate` | `minDate` / `maxDate` |
| `disabledDates` (dates and tuples) | `disabledDates` + `disabledDateRanges` |
| `requiredError` / `invalidDateError` / `disabledDateError` | same names |
| `label`, `labelNode`, `labelVariant`, `placeholder`, `helperText`, `variant`, `size`, `compact`, `start`, `end`, `disabled`, `readOnly` | same names |
| `onChange` (native event) | `onChange` (text) |
| `onBlur` / `onFocus` | `onBlur` / `onFocus` |
| `accessibilityLabel` / `accessibilityHint` | `semanticLabel` / `semanticHint` |

Differences from CDS: CDS derives the field order from the device locale through `Intl`; here it is the explicit `dateOrder` parameter, defaulting to US order like CDS's default locale.
