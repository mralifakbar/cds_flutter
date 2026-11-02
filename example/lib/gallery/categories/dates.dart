import 'package:cds_flutter/cds_flutter.dart';
// The dates barrel is exported from cds_flutter.dart once the maintainer adds it.
import 'package:flutter/material.dart';

import '../demo.dart';

/// Demos for the date and time components.
final CdsDemoCategory datesCategory = CdsDemoCategory(
  title: 'Dates',
  description: 'Calendar, typed dates, date and time pickers.',
  icon: CdsIconName.calendar,
  demos: [
    CdsDemo(
      title: 'CdsCalendar',
      description: 'Month grid with min/max, unavailable and highlighted days.',
      docPath: 'doc/components/CdsCalendar.md',
      builder: (_) => const _CalendarDemo(),
    ),
    CdsDemo(
      title: 'CdsDateInput',
      description: 'Masked date entry with validation.',
      docPath: 'doc/components/CdsDateInput.md',
      builder: (_) => const _DateInputDemo(),
    ),
    CdsDemo(
      title: 'CdsDatePicker',
      description: 'Typed date plus a calendar popover.',
      docPath: 'doc/components/CdsDatePicker.md',
      builder: (_) => const _DatePickerDemo(),
    ),
    CdsDemo(
      title: 'CdsTimePicker',
      description: 'Typed time with AM/PM and hour and minute columns.',
      docPath: 'doc/components/CdsTimePicker.md',
      builder: (_) => const _TimePickerDemo(),
    ),
  ],
);

String _formatDate(DateTime? d) =>
    d == null ? 'None' : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class _CalendarDemo extends StatefulWidget {
  const _CalendarDemo();

  @override
  State<_CalendarDemo> createState() => _CalendarDemoState();
}

class _CalendarDemoState extends State<_CalendarDemo> {
  DateTime? _selected;
  DateTime? _bounded;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Default',
          caption: 'Selected: ${_formatDate(_selected)}',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: CdsCalendar(selectedDate: _selected, onPressDate: (d) => setState(() => _selected = d)),
          ),
        ),
        DemoSection(
          title: 'Next 30 days, weekends unavailable',
          caption: 'Sample data: highlighted days mark scheduled transfers.',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: CdsCalendar(
              selectedDate: _bounded,
              onPressDate: (d) => setState(() => _bounded = d),
              minDate: today,
              maxDate: today.add(const Duration(days: 30)),
              disabledDates: [
                for (var i = 0; i <= 30; i++)
                  if (today.add(Duration(days: i)).weekday >= DateTime.saturday) today.add(Duration(days: i)),
              ],
              highlightedDates: [today.add(const Duration(days: 3)), today.add(const Duration(days: 10))],
            ),
          ),
        ),
        DemoSection(
          title: 'Disabled',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: CdsCalendar(disabled: true, selectedDate: today, onPressDate: (_) {}),
          ),
        ),
      ],
    );
  }
}

class _DateInputDemo extends StatefulWidget {
  const _DateInputDemo();

  @override
  State<_DateInputDemo> createState() => _DateInputDemoState();
}

class _DateInputDemoState extends State<_DateInputDemo> {
  DateTime? _birthday;
  CdsDateInputValidationError? _birthdayError;
  DateTime? _european;
  CdsDateInputValidationError? _europeanError;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Required, no future dates',
          caption: 'Value: ${_formatDate(_birthday)}',
          child: CdsDateInput(
            label: 'Date of birth',
            date: _birthday,
            onChangeDate: (d) => setState(() => _birthday = d),
            error: _birthdayError,
            onErrorDate: (e) => setState(() => _birthdayError = e),
            required: true,
            maxDate: DateTime.now(),
          ),
        ),
        DemoSection(
          title: 'Day first with dots',
          caption: 'Value: ${_formatDate(_european)}',
          child: CdsDateInput(
            label: 'Travel date',
            date: _european,
            onChangeDate: (d) => setState(() => _european = d),
            error: _europeanError,
            onErrorDate: (e) => setState(() => _europeanError = e),
            dateOrder: CdsDateOrder.dmy,
            separator: '.',
          ),
        ),
        DemoSection(
          title: 'Custom error',
          child: CdsDateInput(
            label: 'Settlement date',
            date: DateTime(2026, 1, 5),
            onChangeDate: (_) {},
            error: const CdsDateInputValidationError(
              CdsDateInputValidationErrorType.custom,
              'Markets are closed on this date. Pick another business day.',
            ),
          ),
        ),
        DemoSection(
          title: 'Disabled',
          child: CdsDateInput(label: 'Disabled', date: DateTime(2026, 1, 5), onChangeDate: (_) {}, disabled: true),
        ),
      ],
    );
  }
}

class _DatePickerDemo extends StatefulWidget {
  const _DatePickerDemo();

  @override
  State<_DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<_DatePickerDemo> {
  DateTime? _date;
  CdsDateInputValidationError? _error;
  String _lastEvent = 'None';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Recurring buy start date',
          caption: 'Value: ${_formatDate(_date)}. Last event: $_lastEvent',
          child: CdsDatePicker(
            label: 'Start date',
            date: _date,
            onChangeDate: (d) => setState(() => _date = d),
            error: _error,
            onErrorDate: (e) => setState(() => _error = e),
            required: true,
            minDate: DateTime(now.year, now.month, now.day),
            maxDate: DateTime(now.year + 1, now.month, now.day),
            onConfirm: () => setState(() => _lastEvent = 'confirm'),
            onCancel: () => setState(() => _lastEvent = 'cancel'),
          ),
        ),
        DemoSection(
          title: 'Compact',
          child: CdsDatePicker(
            label: 'Date',
            compact: true,
            date: _date,
            onChangeDate: (d) => setState(() => _date = d),
          ),
        ),
        DemoSection(
          title: 'Disabled',
          child: CdsDatePicker(label: 'Date', date: null, onChangeDate: (_) {}, disabled: true),
        ),
      ],
    );
  }
}

class _TimePickerDemo extends StatefulWidget {
  const _TimePickerDemo();

  @override
  State<_TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<_TimePickerDemo> {
  TimeOfDay? _reminder = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? _window;

  String _formatTime(TimeOfDay? t) =>
      t == null ? 'None' : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: '12-hour, 15 minute steps',
          caption: 'Value: ${_formatTime(_reminder)}',
          child: CdsTimePicker(
            label: 'Price alert time',
            value: _reminder,
            onChange: (t) => setState(() => _reminder = t),
            use24HourFormat: false,
            minuteInterval: 15,
          ),
        ),
        DemoSection(
          title: '24-hour, business hours only',
          caption: 'Value: ${_formatTime(_window)}. Allowed 09:00 to 17:00.',
          child: CdsTimePicker(
            label: 'Call back time',
            value: _window,
            onChange: (t) => setState(() => _window = t),
            use24HourFormat: true,
            minuteInterval: 5,
            minTime: const TimeOfDay(hour: 9, minute: 0),
            maxTime: const TimeOfDay(hour: 17, minute: 0),
          ),
        ),
        DemoSection(
          title: 'Disabled',
          child: CdsTimePicker(label: 'Time', value: _reminder, onChange: (_) {}, disabled: true),
        ),
      ],
    );
  }
}
