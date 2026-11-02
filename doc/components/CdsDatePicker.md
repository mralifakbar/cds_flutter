# CdsDatePicker

A typed date field with a calendar button that opens a `CdsCalendar` in a popover anchored to the field. Use it when people may either type a date or browse to it.

CDS reference: https://cds.coinbase.com/components/other/DatePicker

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsDatePicker(
  label: 'Start date',
  date: start,
  onChangeDate: (d) => setState(() => start = d),
  error: error,
  onErrorDate: (e) => setState(() => error = e),
)
```

## When to use / when not to

Use it for scheduling and ranges where the week matters. For dates people know by heart, `CdsDateInput` alone is quicker. For an always-visible month, use `CdsCalendar`.

## Parameters

All typing and validation parameters behave as in `CdsDateInput`: `date`, `onChangeDate`, `error`, `onErrorDate`, `required`, `separator`, `dateOrder`, `minDate`, `maxDate`, `disabledDates`, `disabledDateRanges`, `requiredError`, `invalidDateError`, `disabledDateError`, `label`, `labelNode`, `labelVariant`, `placeholder`, `helperText`, `variant`, `size`, `compact`, `start`, `disabled`, `readOnly`, `focusNode`, `onChange`, `semanticLabel`. The `end` slot holds the calendar button.

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `date` | `DateTime?` | required | The date shown and selected in the calendar. |
| `onChangeDate` | `ValueChanged<DateTime?>` | required | Called from typing (see `CdsDateInput`) and when a day is picked. |
| `seedDate` | `DateTime?` | `null` | Month the calendar opens on when `date` is null. |
| `highlightedDates` | `List<DateTime>` | `const []` | Days drawn with `fgPrimary` text in the calendar. |
| `highlightedDateRanges` | `List<DateTimeRange>` | `const []` | Highlighted ranges. |
| `currentDate` | `DateTime?` | `DateTime.now()` | The day treated as today in the calendar. |
| `onOpen` | `VoidCallback?` | `null` | The calendar opened. |
| `onConfirm` | `VoidCallback?` | `null` | A day was picked. Fires before `onChangeDate`. |
| `onCancel` | `VoidCallback?` | `null` | The calendar closed without a pick. |
| `onClose` | `VoidCallback?` | `null` | Fires last, after `onConfirm` or `onCancel`. |
| `openCalendarSemanticLabel` | `String` | `'Open calendar'` | Label of the calendar button. |
| `nextArrowSemanticLabel` | `String` | `'Go to next month'` | Passed to the calendar. |
| `previousArrowSemanticLabel` | `String` | `'Go to previous month'` | Passed to the calendar. |
| `highlightedDateSemanticHint` | `String` | `'Highlighted'` | Passed to the calendar. |
| `semanticHint` | `String` | `'Enter date or select from calendar using the calendar button.'` | Hint on the text field. |
| `disabled` | `bool` | `false` | Blocks typing and the calendar button. |
| `readOnly` | `bool` | `false` | Shows the date; the calendar button is disabled. |

### Event order

As in CDS:

1. Picking a date: `onOpen`, `onConfirm`, `onChangeDate`, `onErrorDate(null)` (only when a non-custom error was showing), `onClose`.
2. Closing without picking: `onOpen`, `onCancel`, `onClose`.
3. Typing: see `CdsDateInput`.

## Examples

### Within the next year

```dart
final now = DateTime.now();
CdsDatePicker(
  label: 'First purchase',
  date: date,
  onChangeDate: (d) => setState(() => date = d),
  error: error,
  onErrorDate: (e) => setState(() => error = e),
  required: true,
  minDate: DateTime(now.year, now.month, now.day),
  maxDate: DateTime(now.year + 1, now.month, now.day),
)
```

### Track open and close

```dart
CdsDatePicker(
  label: 'Date',
  date: date,
  onChangeDate: (d) => setState(() => date = d),
  onConfirm: () => setState(() => lastEvent = 'picked'),
  onCancel: () => setState(() => lastEvent = 'dismissed'),
)
```

## Accessibility

- The calendar button is labeled "Open calendar". Opening moves focus into the calendar on the selected day, today, or the first available day; closing returns focus to the calendar button.
- Escape closes the calendar. Tapping outside the field and the popover closes it too.
- The calendar keeps its own keyboard support (arrows, Page Up/Down, Home/End, Enter). See `CdsCalendar`.

## Motion

The popover grows from the edge of the field it is attached to: scale from 0.95 and fade in over `moderate1` with enter-functional easing, and leave the same way with exit-functional easing. It opens below the field, or above it when there is not enough room below. Under reduced motion it appears and disappears at once.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `date` / `onChangeDate` / `error` / `onErrorDate` | same names |
| `onOpen` / `onClose` / `onConfirm` / `onCancel` | same names |
| `seedDate`, `minDate`, `maxDate`, `highlightedDates`, `disabledDates` | same names, plus `...Ranges` lists for tuples |
| `openCalendarAccessibilityLabel` | `openCalendarSemanticLabel` |
| `nextArrowAccessibilityLabel` / `previousArrowAccessibilityLabel` | `nextArrowSemanticLabel` / `previousArrowSemanticLabel` |
| `highlightedDateAccessibilityHint` | `highlightedDateSemanticHint` |
| `accessibilityHint` | `semanticHint` |
| `confirmText`, `confirmButtonAccessibilityHint`, `closeCalendarAccessibilityLabel` | not used (no tray footer) |
| `styles` | not ported |

Differences from CDS: CDS mobile shows the calendar in a bottom tray with a Confirm button. This port shows it in a popover anchored to the field, and picking a day confirms at once, because the shared tray component is not part of this package's dates module. The event order is unchanged.
