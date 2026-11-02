# CdsTimePicker

A time field: type `hh:mm`, switch AM/PM, or pick from hour and minute columns in a popover opened by the clock button. CDS has no time picker; this one is built from CDS inputs and tokens.

CDS reference: none (extra component, styled after https://cds.coinbase.com/components/other/DatePicker)

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

`TimeOfDay` comes from `package:flutter/material.dart`.

## Usage

```dart
CdsTimePicker(
  label: 'Reminder time',
  value: time,
  onChange: (t) => setState(() => time = t),
)
```

## When to use / when not to

Use it for a time of day (alert times, call-back windows). For durations, use a numeric `CdsTextInput` with a unit suffix instead.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `TimeOfDay?` | required | The time shown. A non-null value replaces the text. |
| `onChange` | `ValueChanged<TimeOfDay?>` | required | Called with the time when typed text becomes complete and valid, with null when a complete time is edited or turns invalid, and immediately on picks from the columns. |
| `use24HourFormat` | `bool?` | `MediaQuery.alwaysUse24HourFormatOf` | 24-hour clock (`00` to `23`) or 12-hour with an AM/PM button. |
| `minuteInterval` | `int` | `1` | Step of the minute column. Must divide 60. Typed minutes are accepted as entered. |
| `minTime` | `TimeOfDay?` | `null` | Earliest valid time, inclusive. |
| `maxTime` | `TimeOfDay?` | `null` | Latest valid time, inclusive. |
| `required` | `bool` | `false` | Leaving the field empty after typing shows `requiredError`. |
| `onError` | `ValueChanged<String?>?` | `null` | Validation message, or null when it clears. |
| `requiredError` | `String` | `'This field is required'` | Message for an emptied required field. |
| `invalidTimeError` | `String` | `'Please enter a valid time'` | Message for impossible or incomplete times. |
| `disabledTimeError` | `String` | `'Time unavailable'` | Message for times outside `minTime`/`maxTime`. |
| `label` | `String?` | `null` | Field label. |
| `placeholder` | `String?` | `'hh:mm'` | Placeholder text. |
| `helperText` | `String?` | message, else `'hh:mm'` or `'hh:mm (24-hour)'` | Text under the field. |
| `variant` | `CdsInputVariant?` | `negative` with a message, else `foregroundMuted` | Field sentiment. |
| `size` | `CdsTextInputSize?` | `l` | Density inside the border. |
| `compact` | `bool` | `false` | Dense field with an inline label. |
| `disabled` | `bool` | `false` | Blocks typing, the AM/PM button and the clock button. |
| `readOnly` | `bool` | `false` | Shows the time without allowing changes. |
| `focusNode` | `FocusNode?` | `null` | Focus node of the text field. |
| `onOpen` / `onClose` | `VoidCallback?` | `null` | Popover opened or closed. |
| `openPickerSemanticLabel` | `String` | `'Open time picker'` | Label of the clock button. |
| `doneLabel` | `String` | `'Done'` | Label of the button that closes the popover. |
| `semanticLabel` | `String?` | `label` | Accessibility label override. |

The validation message is transient UI state derived from the typed text; `value` stays controlled.

## Examples

### 12-hour, 15 minute steps

```dart
CdsTimePicker(
  label: 'Price alert time',
  value: time,
  onChange: (t) => setState(() => time = t),
  use24HourFormat: false,
  minuteInterval: 15,
)
```

### Business hours only

```dart
CdsTimePicker(
  label: 'Call back time',
  value: time,
  onChange: (t) => setState(() => time = t),
  use24HourFormat: true,
  minTime: const TimeOfDay(hour: 9, minute: 0),
  maxTime: const TimeOfDay(hour: 17, minute: 0),
)
```

## Accessibility

- The AM/PM button reads "AM" or "PM" with the hint "Switch to PM" or "Switch to AM".
- In the popover, each column is a labeled group ("Hour", "Minute", "AM or PM"); items read "Hour 9", "Minute 30" and expose `selected`. Unavailable items are disabled.
- Opening moves focus to the selected hour (or the first hour). Arrow keys move between items, Enter or Space picks, Escape or a tap outside closes, and focus returns to the clock button.
- Errors show with an info icon and are announced as a live region. Column items stop growing at 1.4x text scale so the 40px rows stay legible.

## Motion

The popover scales from 0.95 and fades from the field edge over `moderate1` (enter-functional in, exit-functional out). Picks give a selection haptic. Under reduced motion the popover appears and disappears at once.

## CDS React Native mapping

CDS has no TimePicker. Parameters follow the `CdsDatePicker` naming: `value`/`onChange` for the controlled value, `...Error` strings for messages, `onOpen`/`onClose` for the popover.
