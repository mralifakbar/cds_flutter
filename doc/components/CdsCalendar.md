# CdsCalendar

A month grid for picking one date. Use it inline on a screen, or let `CdsDatePicker` show it in a popover next to a typed date.

CDS reference: https://cds.coinbase.com/components/other/Calendar

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCalendar(
  selectedDate: date,
  onPressDate: (d) => setState(() => date = d),
)
```

## When to use / when not to

Use it when the day of the week or nearby dates matter to the choice (scheduling a transfer, picking a start date). For a date the user already knows by heart, such as a date of birth, `CdsDateInput` is faster. For a field that offers both, use `CdsDatePicker`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `selectedDate` | `DateTime?` | `null` | Day drawn with the primary fill. Time of day is ignored. |
| `seedDate` | `DateTime?` | `null` | Month shown first when `selectedDate` is null. |
| `onPressDate` | `ValueChanged<DateTime>?` | `null` | Called with the pressed day at midnight. Null makes days read-only. |
| `disabled` | `bool` | `false` | Dims the calendar and blocks every interaction. |
| `hideControls` | `bool` | `false` | Hides the previous and next month arrows. |
| `disabledDates` | `List<DateTime>` | `const []` | Individual days that cannot be picked. |
| `disabledDateRanges` | `List<DateTimeRange>` | `const []` | Inclusive ranges that cannot be picked. Each day is expanded into a set, so keep ranges reasonable. |
| `highlightedDates` | `List<DateTime>` | `const []` | Days drawn with `fgPrimary` text. |
| `highlightedDateRanges` | `List<DateTimeRange>` | `const []` | Inclusive ranges drawn with `fgPrimary` text. |
| `minDate` | `DateTime?` | `null` | Earliest selectable day, inclusive. Browsing before its month is blocked. |
| `maxDate` | `DateTime?` | `null` | Latest selectable day, inclusive. Browsing after its month is blocked. |
| `currentDate` | `DateTime?` | `DateTime.now()` | The day treated as today (bordered). Pass a fixed day in tests. |
| `autofocus` | `bool` | `false` | Moves keyboard focus to the selected day, today, or the first available day on first build. |
| `disabledDateError` | `String` | `'Date unavailable'` | Accessibility hint on unavailable days. |
| `nextArrowSemanticLabel` | `String` | `'Go to next month'` | Label of the next month button. |
| `previousArrowSemanticLabel` | `String` | `'Go to previous month'` | Label of the previous month button. |
| `todaySemanticHint` | `String` | `'Today'` | Accessibility hint on today's date. |
| `highlightedDateSemanticHint` | `String` | `'Highlighted'` | Accessibility hint on highlighted dates. |

`DateTimeRange` comes from `package:flutter/material.dart`.

The first month shown is the month of `selectedDate`, then `seedDate`, then today, or `maxDate` when it is earlier than today. The calendar tracks the month being browsed itself; when `selectedDate` changes to a day in another month, it jumps there.

## Examples

### Limit to the next 30 days

```dart
final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);
CdsCalendar(
  selectedDate: date,
  onPressDate: (d) => setState(() => date = d),
  minDate: today,
  maxDate: today.add(const Duration(days: 30)),
)
```

### Unavailable and highlighted days

```dart
CdsCalendar(
  selectedDate: date,
  onPressDate: (d) => setState(() => date = d),
  disabledDateRanges: [DateTimeRange(start: DateTime(2026, 12, 24), end: DateTime(2026, 12, 26))],
  highlightedDates: [DateTime(2026, 12, 1), DateTime(2026, 12, 15)],
  disabledDateError: 'Transfers are not processed on holidays',
)
```

### One fixed month without arrows

```dart
CdsCalendar(
  seedDate: DateTime(2026, 12, 1),
  minDate: DateTime(2026, 12, 1),
  maxDate: DateTime(2026, 12, 31),
  hideControls: true,
  onPressDate: (d) {},
)
```

## Accessibility

- Each day is a button labeled like "Monday 3 November 2026", with `selected` set on the selected day and hints for today, highlighted and unavailable days.
- The month title is a header. Changing month announces the new month ("December 2026").
- The grid is one Tab stop: focus lands on the selected day, today, or the first available day. Arrow keys move by day and week (left and right swap in RTL), Page Up and Page Down by month, Home and End to the start and end of the week. Enter or Space selects. Moving past the month edge shows the adjacent month.
- Unavailable days are skipped by the keyboard and cannot receive focus.
- Days have a 44px hit area around the 40px circle. Day numbers and weekday initials stop growing at 1.4x text scale so the grid still fits a phone; the month title scales freely.
- Labels are English and weeks start on Sunday, matching CDS. Override the `...SemanticLabel`, `...SemanticHint` and `disabledDateError` strings to localize what screen readers read.

## Motion

Pressing a day gives the standard `CdsPressable` press feedback and a light haptic. Changing month fades the new grid in (`moderate1`, enter-functional easing). Under reduced motion the new month appears at once.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `selectedDate` | `selectedDate` |
| `seedDate` | `seedDate` |
| `onPressDate` | `onPressDate` |
| `disabled` | `disabled` |
| `hideControls` | `hideControls` |
| `disabledDates` (dates and `[start, end]` tuples) | `disabledDates` + `disabledDateRanges` |
| `highlightedDates` (dates and tuples) | `highlightedDates` + `highlightedDateRanges` |
| `minDate` / `maxDate` | `minDate` / `maxDate` |
| `disabledDateError` | `disabledDateError` |
| `nextArrowAccessibilityLabel` | `nextArrowSemanticLabel` |
| `previousArrowAccessibilityLabel` | `previousArrowSemanticLabel` |
| `todayAccessibilityHint` | `todaySemanticHint` |
| `highlightedDateAccessibilityHint` | `highlightedDateSemanticHint` |
| `ref.focusInitialDate()` | `autofocus` |
| `styles` | not ported |

Differences from CDS: each day sits in a 44px slot with a 4px gap (CDS uses 40px cells with an 8px gap), so circles keep the same spacing while meeting the 44px target. Unavailable days show their message as an accessibility hint rather than a tooltip. Keyboard navigation is added.
