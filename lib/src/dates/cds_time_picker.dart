import 'package:flutter/material.dart' show DayPeriod, TimeOfDay;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../buttons/cds_button_variant.dart';
import '../icons/cds_icon_name.dart';
import '../inputs/cds_input_stack.dart';
import '../inputs/cds_text_input.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_dates_internal.dart';

const double _itemHeight = 44;
const int _visibleItems = 5;

/// Keeps typed text to `hh:mm`: digits only, the colon inserted after the hour.
class _TimeMaskFormatter extends TextInputFormatter {
  TextEditingValue _collapsed(String text) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text == oldValue.text) return newValue;
    if (RegExp(r'[^0-9:]').hasMatch(text)) return oldValue;
    if (text.length < oldValue.text.length) return newValue;
    final appended = text.length == oldValue.text.length + 1 && text.startsWith(oldValue.text);
    if (appended) {
      var result = text;
      final last = result.substring(result.length - 1);
      final expectColon = result.length - 1 == 2;
      if (expectColon && last != ':') result = '${result.substring(0, 2)}:$last';
      if (!expectColon && last == ':') return oldValue;
      if (result.length > 5 || ':'.allMatches(result).length > 1) return oldValue;
      return _collapsed(result);
    }
    final digits = text.replaceAll(':', '');
    final buffer = StringBuffer();
    for (final rune in digits.runes) {
      if (buffer.length == 2) buffer.write(':');
      if (buffer.length >= 5) break;
      buffer.writeCharCode(rune);
    }
    return _collapsed(buffer.toString());
  }
}

int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

/// A time field: type `hh:mm`, switch AM/PM, or pick from hour and minute
/// columns in a popover opened by the clock button.
///
/// ```dart
/// CdsTimePicker(
///   label: 'Reminder time',
///   value: time,
///   onChange: (t) => setState(() => time = t),
///   minuteInterval: 15,
/// )
/// ```
///
/// Controlled: [value] is the time shown. [onChange] fires with the time once
/// the typed text is complete and valid, with null when a complete time is
/// edited back to incomplete or becomes invalid, and immediately when the user
/// picks from the columns. Validation messages show as negative helper text
/// and are also reported through [onError].
///
/// With a 12-hour clock the hour field accepts 01 to 12 and an AM/PM button
/// sits at the end of the field. [minuteInterval] spaces the minute column;
/// typed minutes are accepted as entered.
class CdsTimePicker extends StatefulWidget {
  const CdsTimePicker({
    super.key,
    required this.value,
    required this.onChange,
    this.use24HourFormat,
    this.minuteInterval = 1,
    this.minTime,
    this.maxTime,
    this.required = false,
    this.onError,
    this.requiredError = 'This field is required',
    this.invalidTimeError = 'Please enter a valid time',
    this.disabledTimeError = 'Time unavailable',
    this.label,
    this.placeholder,
    this.helperText,
    this.variant,
    this.size,
    this.compact = false,
    this.disabled = false,
    this.readOnly = false,
    this.focusNode,
    this.onOpen,
    this.onClose,
    this.openPickerSemanticLabel = 'Open time picker',
    this.doneLabel = 'Done',
    this.semanticLabel,
  }) : assert(minuteInterval > 0 && 60 % minuteInterval == 0, 'minuteInterval must divide 60');

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChange;

  /// Defaults to the platform setting (`MediaQuery.alwaysUse24HourFormatOf`).
  final bool? use24HourFormat;

  /// Step of the minute column: 1, 5, 15 and so on. Must divide 60.
  final int minuteInterval;

  /// Earliest valid time, inclusive.
  final TimeOfDay? minTime;

  /// Latest valid time, inclusive.
  final TimeOfDay? maxTime;

  /// Report an error when the field is left empty after typing.
  final bool required;

  /// Called with the validation message, or null when it clears.
  final ValueChanged<String?>? onError;
  final String requiredError;
  final String invalidTimeError;
  final String disabledTimeError;
  final String? label;

  /// Defaults to `hh:mm`.
  final String? placeholder;

  /// Defaults to the validation message, or `hh:mm` with the clock format.
  final String? helperText;

  /// Defaults to negative while there is a validation message.
  final CdsInputVariant? variant;
  final CdsTextInputSize? size;
  final bool compact;
  final bool disabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final String openPickerSemanticLabel;

  /// Label of the button that closes the popover.
  final String doneLabel;
  final String? semanticLabel;

  @override
  State<CdsTimePicker> createState() => _CdsTimePickerState();
}

class _CdsTimePickerState extends State<CdsTimePicker> {
  final _mask = _TimeMaskFormatter();
  final FocusNode _triggerNode = FocusNode(debugLabel: 'CdsTimePicker clock button');
  late final TextEditingController _controller = TextEditingController();
  bool _pm = false;
  bool _open = false;
  bool _hadComplete = false;
  bool _hasTyped = false;
  String? _error;
  bool? _lastUse24;

  bool get _use24 => widget.use24HourFormat ?? MediaQuery.maybeAlwaysUse24HourFormatOf(context) ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lastUse24 != _use24) {
      _lastUse24 = _use24;
      _syncText(widget.value);
    }
  }

  @override
  void didUpdateWidget(CdsTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != null) _syncText(widget.value);
    if (oldWidget.use24HourFormat != widget.use24HourFormat) {
      _lastUse24 = _use24;
      _syncText(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _triggerNode.dispose();
    super.dispose();
  }

  String _format(TimeOfDay t) {
    final hour = _use24 ? t.hour : (t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod);
    return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _syncText(TimeOfDay? value) {
    if (value == null) return;
    _pm = value.period == DayPeriod.pm;
    _hadComplete = true;
    final text = _format(value);
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  TimeOfDay? _parse(String text) {
    if (text.length != 5) return null;
    final h = int.tryParse(text.substring(0, 2));
    final m = int.tryParse(text.substring(3));
    if (h == null || m == null || m > 59) return null;
    if (_use24) return h > 23 ? null : TimeOfDay(hour: h, minute: m);
    if (h < 1 || h > 12) return null;
    return TimeOfDay(hour: h % 12 + (_pm ? 12 : 0), minute: m);
  }

  bool _inRange(TimeOfDay t) {
    final v = _minutes(t);
    if (widget.minTime != null && v < _minutes(widget.minTime!)) return false;
    if (widget.maxTime != null && v > _minutes(widget.maxTime!)) return false;
    return true;
  }

  void _setError(String? error) {
    if (error == _error) return;
    setState(() => _error = error);
    widget.onError?.call(error);
  }

  void _evaluate(String text) {
    final complete = text.length == 5;
    if (complete) {
      final time = _parse(text);
      if (time == null) {
        widget.onChange(null);
        _setError(widget.invalidTimeError);
      } else if (!_inRange(time)) {
        widget.onChange(null);
        _setError(widget.disabledTimeError);
      } else {
        widget.onChange(time);
        _setError(null);
      }
    } else {
      if (_hadComplete) widget.onChange(null);
      _setError(null);
    }
    _hadComplete = complete;
  }

  void _handleChange(String text) {
    _hasTyped = true;
    _evaluate(text);
  }

  void _handleBlur() {
    final text = _controller.text;
    if (text.isNotEmpty && text.length != 5) {
      _setError(widget.invalidTimeError);
    } else if (text.isEmpty && widget.required && _hasTyped) {
      _setError(widget.requiredError);
    }
  }

  void _togglePeriod() {
    setState(() => _pm = !_pm);
    if (_controller.text.length == 5) _evaluate(_controller.text);
  }

  void _pick(TimeOfDay time) {
    _pm = time.period == DayPeriod.pm;
    _hadComplete = true;
    final text = _format(time);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _setError(_inRange(time) ? null : widget.disabledTimeError);
    widget.onChange(_inRange(time) ? time : null);
    setState(() {});
  }

  void _togglePicker() {
    if (_open) {
      _closePicker();
      return;
    }
    widget.onOpen?.call();
    setState(() => _open = true);
  }

  void _closePicker() {
    if (!_open) return;
    setState(() => _open = false);
    _triggerNode.requestFocus();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final blocked = widget.disabled || widget.readOnly;
    final current = widget.value ?? _parse(_controller.text);
    final pattern = _use24 ? 'hh:mm (24-hour)' : 'hh:mm';

    final end = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_use24)
          CdsPressable(
            onPress: blocked ? null : _togglePeriod,
            disabled: blocked,
            background: CdsColor.bgSecondary,
            borderRadius: 1000,
            debounce: Duration.zero,
            feedback: CdsHapticFeedback.selection,
            minTapTargetSize: 44,
            semanticLabel: _pm ? 'PM' : 'AM',
            semanticHint: _pm ? 'Switch to AM' : 'Switch to PM',
            excludeChildSemantics: true,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.space(1), vertical: theme.space(0.5)),
              child: CdsText(_pm ? 'PM' : 'AM', font: CdsFont.label1),
            ),
          ),
        Padding(
          padding: EdgeInsetsDirectional.only(end: theme.space(0.5)),
          child: CdsInputIconButton(
            CdsIconName.clock,
            semanticLabel: widget.openPickerSemanticLabel,
            onPress: blocked ? null : _togglePicker,
            disabled: blocked,
            variant: CdsButtonVariant.secondary,
            disableInheritFocusStyle: true,
            focusNode: _triggerNode,
          ),
        ),
      ],
    );

    return CdsDatesPopover(
      open: _open,
      onDismiss: _closePicker,
      estimatedHeight: _itemHeight * _visibleItems + 140,
      popoverBuilder: (context) => CdsDatesPopoverSurface(
        child: _TimeColumns(
          value: current,
          use24: _use24,
          pm: _pm,
          minuteInterval: widget.minuteInterval,
          inRange: _inRange,
          onPick: _pick,
          doneLabel: widget.doneLabel,
          onDone: _closePicker,
        ),
      ),
      child: CdsTextInput(
        controller: _controller,
        onChange: _handleChange,
        focusNode: widget.focusNode,
        label: widget.label,
        placeholder: widget.placeholder ?? 'hh:mm',
        helperText: widget.helperText ?? _error ?? pattern,
        variant: widget.variant ?? (_error != null ? CdsInputVariant.negative : CdsInputVariant.foregroundMuted),
        size: widget.size,
        compact: widget.compact,
        disabled: widget.disabled,
        readOnly: widget.readOnly,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [_mask],
        maxLength: 5,
        onBlur: _handleBlur,
        semanticLabel: widget.semanticLabel,
        end: end,
      ),
    );
  }
}

class _TimeColumns extends StatelessWidget {
  const _TimeColumns({
    required this.value,
    required this.use24,
    required this.pm,
    required this.minuteInterval,
    required this.inRange,
    required this.onPick,
    required this.doneLabel,
    required this.onDone,
  });

  final TimeOfDay? value;
  final bool use24;
  final bool pm;
  final int minuteInterval;
  final bool Function(TimeOfDay) inRange;
  final ValueChanged<TimeOfDay> onPick;
  final String doneLabel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final minute = value?.minute ?? 0;
    final hour24 = value?.hour ?? (pm ? 12 : 0);
    final hours = use24 ? List.generate(24, (i) => i) : List.generate(12, (i) => i == 0 ? 12 : i);
    final minutes = [for (var m = 0; m < 60; m += minuteInterval) m];

    int toHour24(int shown) => use24 ? shown : shown % 12 + (hour24 >= 12 ? 12 : 0);
    bool hourAvailable(int h24) => minutes.any((m) => inRange(TimeOfDay(hour: h24, minute: m)));
    final selectedHourShown = use24 ? hour24 : (hour24 % 12 == 0 ? 12 : hour24 % 12);

    // Items are fixed 40px rows; cap text growth so they stay legible.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: theme.space(2),
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: theme.space(1),
            children: [
              _Column(
                semanticLabel: 'Hour',
                autofocus: true,
                items: [
                  for (final h in hours)
                    _ColumnItem(
                      label: h.toString().padLeft(2, '0'),
                      semanticLabel: 'Hour $h',
                      selected: value != null && h == selectedHourShown,
                      enabled: hourAvailable(toHour24(h)),
                      onPress: () => onPick(TimeOfDay(hour: toHour24(h), minute: minute)),
                    ),
                ],
              ),
              _Column(
                semanticLabel: 'Minute',
                items: [
                  for (final m in minutes)
                    _ColumnItem(
                      label: m.toString().padLeft(2, '0'),
                      semanticLabel: 'Minute $m',
                      selected: value != null && m == minute,
                      enabled: inRange(TimeOfDay(hour: hour24, minute: m)),
                      onPress: () => onPick(TimeOfDay(hour: hour24, minute: m)),
                    ),
                ],
              ),
              if (!use24)
                _Column(
                  semanticLabel: 'AM or PM',
                  items: [
                    for (final isPm in [false, true])
                      _ColumnItem(
                        label: isPm ? 'PM' : 'AM',
                        semanticLabel: isPm ? 'PM' : 'AM',
                        selected: value != null && (hour24 >= 12) == isPm,
                        enabled: inRange(TimeOfDay(hour: hour24 % 12 + (isPm ? 12 : 0), minute: minute)),
                        onPress: () => onPick(TimeOfDay(hour: hour24 % 12 + (isPm ? 12 : 0), minute: minute)),
                      ),
                  ],
                ),
            ],
          ),
          CdsButton(label: doneLabel, size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: onDone),
        ],
      ),
    );
  }
}

class _ColumnItem {
  const _ColumnItem({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.enabled,
    required this.onPress,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback onPress;
}

class _Column extends StatefulWidget {
  const _Column({required this.semanticLabel, required this.items, this.autofocus = false});

  final String semanticLabel;

  /// Focus the selected item (or the first) when the popover opens.
  final bool autofocus;
  final List<_ColumnItem> items;

  @override
  State<_Column> createState() => _ColumnState();
}

class _ColumnState extends State<_Column> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    final index = widget.items.indexWhere((i) => i.selected);
    final offset = index < 0 ? 0.0 : (index - _visibleItems ~/ 2) * _itemHeight;
    final max = (widget.items.length - _visibleItems) * _itemHeight;
    _scroll = ScrollController(initialScrollOffset: offset.clamp(0, max < 0 ? 0 : max));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = _itemHeight * (widget.items.length < _visibleItems ? widget.items.length : _visibleItems);
    final autofocusIndex = widget.items.indexWhere((i) => i.selected);
    return Semantics(
      label: widget.semanticLabel,
      container: true,
      explicitChildNodes: true,
      child: SizedBox(
        width: 64,
        height: height,
        child: ListView.builder(
          controller: _scroll,
          itemExtent: _itemHeight,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return Center(
              child: CdsPressable(
                onPress: item.enabled ? item.onPress : null,
                disabled: !item.enabled,
                autofocus: widget.autofocus && index == (autofocusIndex < 0 ? 0 : autofocusIndex),
                background: item.selected ? CdsColor.bgPrimary : CdsColor.transparent,
                borderRadius: 200,
                debounce: Duration.zero,
                feedback: CdsHapticFeedback.selection,
                semanticLabel: item.semanticLabel,
                selected: item.selected,
                excludeChildSemantics: true,
                child: SizedBox(
                  width: 56,
                  height: 40,
                  child: Center(
                    child: CdsText(
                      item.label,
                      tabularNumbers: true,
                      maxLines: 1,
                      color: item.selected ? CdsColor.fgInverse : CdsColor.fg,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
