import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../inputs/cds_input_stack.dart';
import '../inputs/cds_text_input.dart';
import 'cds_dates_internal.dart';

/// Why a [CdsDateInput] rejected its value.
enum CdsDateInputValidationErrorType {
  /// The field is required and was left incomplete.
  required,

  /// The text is not a real date (e.g. 02/30/2026), or it is more than 100
  /// years outside `minDate`/`maxDate`.
  invalid,

  /// A real date that is before `minDate`, after `maxDate` or in `disabledDates`.
  disabled,

  /// Set by the app, e.g. from server-side validation. Never cleared by the input.
  custom,
}

/// A validation error reported by [CdsDateInput] and [CdsDatePicker].
@immutable
class CdsDateInputValidationError {
  const CdsDateInputValidationError(this.type, this.message);

  final CdsDateInputValidationErrorType type;

  /// Shown as the field's helper text.
  final String message;

  @override
  bool operator ==(Object other) =>
      other is CdsDateInputValidationError && other.type == type && other.message == message;

  @override
  int get hashCode => Object.hash(type, message);

  @override
  String toString() => 'CdsDateInputValidationError(${type.name}, $message)';
}

/// Order of the month, day and year fields in a typed date.
enum CdsDateOrder {
  /// mm/dd/yyyy, the CDS default (en-US).
  mdy,

  /// dd/mm/yyyy.
  dmy,

  /// yyyy/mm/dd.
  ymd,
}

/// Parses, formats and validates typed dates for one order and separator.
@immutable
class _DateFormat {
  const _DateFormat(this.order, this.separator);

  final CdsDateOrder order;
  final String separator;

  List<String> get _parts => switch (order) {
        CdsDateOrder.mdy => const ['mm', 'dd', 'yyyy'],
        CdsDateOrder.dmy => const ['dd', 'mm', 'yyyy'],
        CdsDateOrder.ymd => const ['yyyy', 'mm', 'dd'],
      };

  /// "mm/dd/yyyy". Also the default helper text.
  String get pattern => _parts.join(separator);

  int get length => pattern.length;

  List<int> get separatorIndices {
    final first = _parts[0].length;
    return [first, first + 1 + _parts[1].length];
  }

  DateTime? parse(String text) {
    final values = text.split(separator);
    if (values.length != 3) return null;
    int? year, month, day;
    for (var i = 0; i < 3; i++) {
      final n = int.tryParse(values[i]);
      if (n == null || values[i].length != _parts[i].length) return null;
      switch (_parts[i]) {
        case 'yyyy':
          year = n;
        case 'mm':
          month = n;
        case 'dd':
          day = n;
      }
    }
    final date = DateTime(year!, month!, day!);
    // Reject values like 30/30/2015 that would roll over into another month.
    if (date.month != month || date.year != year || date.day != day) return null;
    return date;
  }

  String format(DateTime date) {
    String part(String p) => switch (p) {
          'yyyy' => date.year.toString().padLeft(4, '0'),
          'mm' => date.month.toString().padLeft(2, '0'),
          _ => date.day.toString().padLeft(2, '0'),
        };
    return _parts.map(part).join(separator);
  }
}

/// Keeps typed text to digits and separators, inserts the separator when the
/// user skips it, and reformats pasted digits.
class _DateMaskFormatter extends TextInputFormatter {
  _DateMaskFormatter(this.format);

  final _DateFormat format;

  bool _hasInvalidChars(String text) {
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char != format.separator && (rune < 0x30 || rune > 0x39)) return true;
    }
    return false;
  }

  TextEditingValue _collapsed(String text) =>
      TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final old = oldValue.text;
    if (text == old) return newValue;
    if (text.length < old.length) return _hasInvalidChars(text) ? oldValue : newValue;

    final sep = format.separator;
    final indices = format.separatorIndices;
    if (text.length == old.length + 1 && text.startsWith(old)) {
      if (text.length > format.length || _hasInvalidChars(text)) return oldValue;
      var result = text;
      final last = result.substring(result.length - 1);
      final expectSeparator = indices.contains(result.length - 1);
      if (expectSeparator && last != sep) {
        result = '${result.substring(0, result.length - 1)}$sep$last';
      }
      if (!expectSeparator && last == sep) return oldValue;
      final separatorCount = sep.allMatches(result).length;
      if (result.contains('$sep$sep') || separatorCount > indices.length || result.length > format.length) {
        return oldValue;
      }
      return _collapsed(result);
    }

    // Paste or an edit in the middle: rebuild from the digits.
    if (_hasInvalidChars(text)) return oldValue;
    final digits = text.replaceAll(sep, '');
    final buffer = StringBuffer();
    for (final rune in digits.runes) {
      if (indices.contains(buffer.length)) buffer.write(sep);
      if (buffer.length >= format.length) break;
      buffer.writeCharCode(rune);
    }
    return _collapsed(buffer.toString());
  }
}

/// A text field for typing a date, masked as `mm/dd/yyyy` by default.
///
/// ```dart
/// CdsDateInput(
///   label: 'Date of birth',
///   date: birthday,
///   onChangeDate: (d) => setState(() => birthday = d),
///   error: error,
///   onErrorDate: (e) => setState(() => error = e),
///   required: true,
///   maxDate: DateTime.now(),
/// )
/// ```
///
/// Controlled: [date] and [error] come from the app. [onChangeDate] fires
/// with the parsed date once the text is complete and valid, and with null
/// when a complete date is edited back to incomplete. [onErrorDate] fires
/// after [onChangeDate] when validation fails, and with null when a previous
/// non-custom error no longer applies.
///
/// Event order, as in CDS:
/// 1. Typing into an empty field: onChange, onChange, ..., onChangeDate, onErrorDate.
/// 2. Editing a complete date: onChange, onChangeDate(null), onChange, ..., onChangeDate, onErrorDate.
///
/// When [required] is set, leaving the field after typing an incomplete
/// date reports a [CdsDateInputValidationErrorType.required] error.
class CdsDateInput extends StatefulWidget {
  const CdsDateInput({
    super.key,
    required this.date,
    required this.onChangeDate,
    this.error,
    this.onErrorDate,
    this.required = false,
    this.separator = '/',
    this.dateOrder = CdsDateOrder.mdy,
    this.minDate,
    this.maxDate,
    this.disabledDates = const [],
    this.disabledDateRanges = const [],
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
    this.end,
    this.disabled = false,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.onChange,
    this.onFocus,
    this.onBlur,
    this.onSubmitEditing,
    this.semanticLabel,
    this.semanticHint,
  });

  /// The date shown. A non-null date replaces the text; null leaves the text
  /// alone so the user can keep editing an incomplete value.
  final DateTime? date;
  final ValueChanged<DateTime?> onChangeDate;

  /// Shown as negative helper text. Pass back what [onErrorDate] reports.
  final CdsDateInputValidationError? error;
  final ValueChanged<CdsDateInputValidationError?>? onErrorDate;

  /// Report an error when the user leaves the field incomplete after typing.
  final bool required;

  /// Single character between the fields.
  final String separator;
  final CdsDateOrder dateOrder;

  /// Earliest valid day, inclusive.
  final DateTime? minDate;

  /// Latest valid day, inclusive.
  final DateTime? maxDate;
  final List<DateTime> disabledDates;
  final List<DateTimeRange> disabledDateRanges;
  final String requiredError;
  final String invalidDateError;
  final String disabledDateError;
  final String? label;
  final Widget? labelNode;
  final CdsInputLabelVariant labelVariant;

  /// Defaults to blanks around the separators, e.g. `"   /   /"`.
  final String? placeholder;

  /// Defaults to the [error] message, or the format pattern (`mm/dd/yyyy`).
  final String? helperText;

  /// Defaults to negative while there is an [error], otherwise foregroundMuted.
  final CdsInputVariant? variant;
  final CdsTextInputSize? size;
  final bool compact;
  final Widget? start;
  final Widget? end;
  final bool disabled;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Raw text after every edit. Prefer [onChangeDate].
  final ValueChanged<String>? onChange;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final ValueChanged<String>? onSubmitEditing;
  final String? semanticLabel;
  final String? semanticHint;

  @override
  State<CdsDateInput> createState() => _CdsDateInputState();
}

class _CdsDateInputState extends State<CdsDateInput> {
  late _DateFormat _format = _DateFormat(widget.dateOrder, widget.separator);
  late _DateMaskFormatter _mask = _DateMaskFormatter(_format);
  late final TextEditingController _controller =
      TextEditingController(text: widget.date == null ? '' : _format.format(widget.date!));
  late bool _hadCompleteDate = widget.date != null;
  late bool _hasTyped = widget.date != null;

  @override
  void didUpdateWidget(CdsDateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.separator.length == 1, 'separator must be a single character');
    if (oldWidget.separator != widget.separator || oldWidget.dateOrder != widget.dateOrder) {
      _format = _DateFormat(widget.dateOrder, widget.separator);
      _mask = _DateMaskFormatter(_format);
      if (widget.date != null) _controller.text = _format.format(widget.date!);
    }
    if (!_sameDate(oldWidget.date, widget.date)) {
      _hadCompleteDate = widget.date != null;
      final date = widget.date;
      if (date != null) {
        final text = _format.format(date);
        if (text != _controller.text) {
          _controller.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
        }
      }
    }
  }

  static bool _sameDate(DateTime? a, DateTime? b) => (a == null && b == null) || cdsSameDay(a, b);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CdsDateInputValidationError? _validate(String text) {
    CdsDateInputValidationErrorType? type;
    final date = _format.parse(text);
    final min = widget.minDate == null ? null : cdsMidnight(widget.minDate!);
    final max = widget.maxDate == null ? null : cdsMidnight(widget.maxDate!);
    if (widget.required && text.length != _format.length) {
      type = CdsDateInputValidationErrorType.required;
    } else if (date == null) {
      type = CdsDateInputValidationErrorType.invalid;
    } else if ((min != null && date.isBefore(DateTime(min.year - 100, min.month, min.day))) ||
        (max != null && date.isAfter(DateTime(max.year + 100, max.month, max.day)))) {
      type = CdsDateInputValidationErrorType.invalid;
    } else if ((min != null && date.isBefore(min)) ||
        (max != null && date.isAfter(max)) ||
        cdsDateSet(widget.disabledDates, widget.disabledDateRanges).contains(date)) {
      type = CdsDateInputValidationErrorType.disabled;
    }
    if (type == null) return null;
    final message = switch (type) {
      CdsDateInputValidationErrorType.required => widget.requiredError,
      CdsDateInputValidationErrorType.invalid => widget.invalidDateError,
      CdsDateInputValidationErrorType.disabled => widget.disabledDateError,
      CdsDateInputValidationErrorType.custom => _format.pattern,
    };
    return CdsDateInputValidationError(type, message);
  }

  bool get _hasClearableError =>
      widget.error != null && widget.error!.type != CdsDateInputValidationErrorType.custom;

  void _handleChange(String text) {
    _hasTyped = true;
    widget.onChange?.call(text);
    final complete = text.length == _format.length;
    if (complete) {
      final error = _validate(text);
      widget.onChangeDate(error == null ? _format.parse(text) : null);
      if (error != null) {
        widget.onErrorDate?.call(error);
      } else if (_hasClearableError) {
        widget.onErrorDate?.call(null);
      }
    } else {
      if (_hadCompleteDate) widget.onChangeDate(null);
      if (_hasClearableError) widget.onErrorDate?.call(null);
    }
    _hadCompleteDate = complete;
  }

  void _handleBlur() {
    widget.onBlur?.call();
    if (!widget.required || !_hasTyped) return;
    final error = _validate(_controller.text);
    if (error != null && error != widget.error) widget.onErrorDate?.call(error);
  }

  @override
  Widget build(BuildContext context) {
    final sep = widget.separator;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 164),
      child: CdsTextInput(
        controller: _controller,
        onChange: _handleChange,
        focusNode: widget.focusNode,
        label: widget.label,
        labelNode: widget.labelNode,
        labelVariant: widget.labelVariant,
        placeholder: widget.placeholder ?? '   $sep   $sep',
        helperText: widget.helperText ?? widget.error?.message ?? _format.pattern,
        variant: widget.variant ??
            (widget.error != null ? CdsInputVariant.negative : CdsInputVariant.foregroundMuted),
        size: widget.size,
        compact: widget.compact,
        start: widget.start,
        end: widget.end,
        disabled: widget.disabled,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [_mask],
        maxLength: _format.length,
        onFocus: widget.onFocus,
        onBlur: _handleBlur,
        onSubmitEditing: widget.onSubmitEditing,
        semanticLabel: widget.semanticLabel,
        semanticHint: widget.semanticHint,
      ),
    );
  }
}
