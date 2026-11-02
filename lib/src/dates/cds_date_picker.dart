import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/widgets.dart';

import '../buttons/cds_button_variant.dart';
import '../icons/cds_icon_name.dart';
import '../inputs/cds_input_stack.dart';
import '../theme/cds_theme.dart';
import 'cds_calendar.dart';
import 'cds_date_input.dart';
import 'cds_dates_internal.dart';

/// A [CdsDateInput] with a calendar button that opens a [CdsCalendar] in a
/// popover anchored to the field.
///
/// ```dart
/// CdsDatePicker(
///   label: 'Start date',
///   date: start,
///   onChangeDate: (d) => setState(() => start = d),
///   error: error,
///   onErrorDate: (e) => setState(() => error = e),
///   minDate: DateTime(2026, 1, 1),
/// )
/// ```
///
/// Picking a day sets the date and closes the calendar. Escape, a tap
/// outside, or the calendar button again closes it without changing the
/// date. Keyboard focus moves into the calendar on open and back to the
/// calendar button on close.
///
/// Event order, as in CDS:
/// 1. Picking a date: onOpen, onConfirm, onChangeDate, onErrorDate (only to
///    clear a previous error), onClose.
/// 2. Closing without picking: onOpen, onCancel, onClose.
/// 3. Typing behaves like [CdsDateInput].
class CdsDatePicker extends StatefulWidget {
  const CdsDatePicker({
    super.key,
    required this.date,
    required this.onChangeDate,
    this.error,
    this.onErrorDate,
    this.required = false,
    this.separator = '/',
    this.dateOrder = CdsDateOrder.mdy,
    this.seedDate,
    this.minDate,
    this.maxDate,
    this.disabledDates = const [],
    this.disabledDateRanges = const [],
    this.highlightedDates = const [],
    this.highlightedDateRanges = const [],
    this.currentDate,
    this.requiredError = 'This field is required',
    this.invalidDateError = 'Please enter a valid date',
    this.disabledDateError = 'Date unavailable',
    this.label,
    this.labelNode,
    this.labelVariant = CdsInputLabelVariant.outside,
    this.placeholder,
    this.helperText,
    this.variant,
    this.size,
    this.compact = false,
    this.start,
    this.disabled = false,
    this.readOnly = false,
    this.focusNode,
    this.onChange,
    this.onOpen,
    this.onClose,
    this.onConfirm,
    this.onCancel,
    this.openCalendarSemanticLabel = 'Open calendar',
    this.nextArrowSemanticLabel = 'Go to next month',
    this.previousArrowSemanticLabel = 'Go to previous month',
    this.highlightedDateSemanticHint = 'Highlighted',
    this.semanticLabel,
    this.semanticHint = 'Enter date or select from calendar using the calendar button.',
  });

  final DateTime? date;
  final ValueChanged<DateTime?> onChangeDate;
  final CdsDateInputValidationError? error;
  final ValueChanged<CdsDateInputValidationError?>? onErrorDate;
  final bool required;
  final String separator;
  final CdsDateOrder dateOrder;

  /// Month the calendar opens on when [date] is null.
  final DateTime? seedDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final List<DateTime> disabledDates;
  final List<DateTimeRange> disabledDateRanges;
  final List<DateTime> highlightedDates;
  final List<DateTimeRange> highlightedDateRanges;

  /// The day treated as today in the calendar. Defaults to [DateTime.now].
  final DateTime? currentDate;
  final String requiredError;
  final String invalidDateError;
  final String disabledDateError;
  final String? label;
  final Widget? labelNode;
  final CdsInputLabelVariant labelVariant;
  final String? placeholder;
  final String? helperText;
  final CdsInputVariant? variant;
  final CdsTextInputSize? size;
  final bool compact;
  final Widget? start;

  /// Blocks typing and the calendar button.
  final bool disabled;

  /// Shows the date without allowing changes; the calendar button is disabled.
  final bool readOnly;

  /// Focus node of the text field.
  final FocusNode? focusNode;

  /// Raw text after every edit. Prefer [onChangeDate].
  final ValueChanged<String>? onChange;
  final VoidCallback? onOpen;

  /// Fires last, after [onConfirm] or [onCancel].
  final VoidCallback? onClose;

  /// Fires when a day is picked, before [onChangeDate].
  final VoidCallback? onConfirm;

  /// Fires when the calendar closes without a pick.
  final VoidCallback? onCancel;
  final String openCalendarSemanticLabel;
  final String nextArrowSemanticLabel;
  final String previousArrowSemanticLabel;
  final String highlightedDateSemanticHint;
  final String? semanticLabel;
  final String semanticHint;

  @override
  State<CdsDatePicker> createState() => _CdsDatePickerState();
}

class _CdsDatePickerState extends State<CdsDatePicker> {
  final FocusNode _triggerNode = FocusNode(debugLabel: 'CdsDatePicker calendar button');
  bool _open = false;

  @override
  void dispose() {
    _triggerNode.dispose();
    super.dispose();
  }

  void _openPicker() {
    if (_open) {
      _dismiss();
      return;
    }
    widget.onOpen?.call();
    setState(() => _open = true);
  }

  void _close() {
    setState(() => _open = false);
    _triggerNode.requestFocus();
    widget.onClose?.call();
  }

  void _dismiss() {
    if (!_open) return;
    widget.onCancel?.call();
    _close();
  }

  void _confirm(DateTime date) {
    widget.onConfirm?.call();
    widget.onChangeDate(date);
    final error = widget.error;
    if (error != null && error.type != CdsDateInputValidationErrorType.custom) {
      widget.onErrorDate?.call(null);
    }
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final blocked = widget.disabled || widget.readOnly;
    return CdsDatesPopover(
      open: _open,
      onDismiss: _dismiss,
      popoverBuilder: (context) => CdsDatesPopoverSurface(
        child: CdsCalendar(
          autofocus: true,
          selectedDate: widget.date,
          seedDate: widget.seedDate,
          onPressDate: _confirm,
          disabled: widget.disabled,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          disabledDates: widget.disabledDates,
          disabledDateRanges: widget.disabledDateRanges,
          highlightedDates: widget.highlightedDates,
          highlightedDateRanges: widget.highlightedDateRanges,
          currentDate: widget.currentDate,
          disabledDateError: widget.disabledDateError,
          nextArrowSemanticLabel: widget.nextArrowSemanticLabel,
          previousArrowSemanticLabel: widget.previousArrowSemanticLabel,
          highlightedDateSemanticHint: widget.highlightedDateSemanticHint,
        ),
      ),
      child: CdsDateInput(
        date: widget.date,
        onChangeDate: widget.onChangeDate,
        error: widget.error,
        onErrorDate: widget.onErrorDate,
        required: widget.required,
        separator: widget.separator,
        dateOrder: widget.dateOrder,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        disabledDates: widget.disabledDates,
        disabledDateRanges: widget.disabledDateRanges,
        requiredError: widget.requiredError,
        invalidDateError: widget.invalidDateError,
        disabledDateError: widget.disabledDateError,
        label: widget.label,
        labelNode: widget.labelNode,
        labelVariant: widget.labelVariant,
        placeholder: widget.placeholder,
        helperText: widget.helperText,
        variant: widget.variant,
        size: widget.size,
        compact: widget.compact,
        start: widget.start,
        disabled: widget.disabled,
        readOnly: widget.readOnly,
        focusNode: widget.focusNode,
        onChange: widget.onChange,
        semanticLabel: widget.semanticLabel,
        semanticHint: widget.semanticHint,
        end: Padding(
          padding: EdgeInsetsDirectional.only(end: context.cds.space(0.5)),
          child: CdsInputIconButton(
            CdsIconName.calendarEmpty,
            semanticLabel: widget.openCalendarSemanticLabel,
            onPress: blocked ? null : _openPicker,
            disabled: blocked,
            variant: CdsButtonVariant.secondary,
            disableInheritFocusStyle: true,
            focusNode: _triggerNode,
          ),
        ),
      ),
    );
  }
}
