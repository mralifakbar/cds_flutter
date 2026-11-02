import 'dart:math' as math;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../utils/cds_color_utils.dart';

/// Start and end values of a [CdsRangeSlider].
typedef CdsRangeValues = ({double start, double end});

/// Formats a slider value for screen readers.
typedef CdsSliderValueFormatter = String Function(double value);

const double _thumbSize = 24;
const double _hitHeight = 44;

/// Picks a single value from a continuous or stepped range. Not part of CDS;
/// built from CDS tokens to match the selection controls.
///
/// ```dart
/// CdsSlider(
///   value: volume,
///   onChange: (v) => setState(() => volume = v),
///   semanticLabel: 'Volume',
/// )
/// ```
///
/// Controlled: the thumb shows [value]. While dragging it follows the finger
/// from where it was grabbed and reports snapped values through [onChange];
/// on release it springs to the value it was given. A tap on the track moves
/// the thumb there with a spring that starts from where it was.
///
/// Keyboard: arrow keys step by one division (1% without [divisions]),
/// Shift+arrow and Page Up/Down step by 10% of the range, Home/End jump to
/// [min]/[max].
class CdsSlider extends StatelessWidget {
  const CdsSlider({
    super.key,
    required this.value,
    required this.onChange,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.disabled = false,
    this.semanticLabel,
    this.formatValue,
    this.focusNode,
    this.autofocus = false,
  }) : assert(max > min),
       assert(divisions == null || divisions > 0);

  final double value;

  /// Called with the new value while dragging, on tap and on key presses.
  /// Null disables the slider.
  final ValueChanged<double>? onChange;

  /// Called once when a drag, tap or key press starts changing the value.
  final ValueChanged<double>? onChangeStart;

  /// Called once with the final value when the change ends.
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;

  /// Number of discrete steps. Null for a continuous slider.
  final int? divisions;
  final bool disabled;

  /// Accessibility label, e.g. "Volume".
  final String? semanticLabel;

  /// Formats the value for screen readers. Defaults to a percentage of the range.
  final CdsSliderValueFormatter? formatValue;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return _CdsSliderCore(
      values: [value],
      onChange: onChange == null ? null : (v) => onChange!(v[0]),
      onChangeStart: onChangeStart == null ? null : (v) => onChangeStart!(v[0]),
      onChangeEnd: onChangeEnd == null ? null : (v) => onChangeEnd!(v[0]),
      min: min,
      max: max,
      divisions: divisions,
      disabled: disabled,
      semanticLabels: [semanticLabel],
      formatValue: formatValue,
      focusNodes: [focusNode],
      autofocus: autofocus,
    );
  }
}

/// Picks a start and end value from a range with two thumbs. Not part of
/// CDS; shares the look and gestures of [CdsSlider].
///
/// ```dart
/// CdsRangeSlider(
///   values: (start: 20, end: 80),
///   min: 0,
///   max: 100,
///   onChange: (v) => setState(() => range = v),
///   startSemanticLabel: 'Minimum price',
///   endSemanticLabel: 'Maximum price',
/// )
/// ```
///
/// The thumbs cannot cross. A drag or tap moves the nearest thumb. Each thumb
/// is focusable on its own and exposes its own slider semantics.
class CdsRangeSlider extends StatelessWidget {
  const CdsRangeSlider({
    super.key,
    required this.values,
    required this.onChange,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.disabled = false,
    this.startSemanticLabel,
    this.endSemanticLabel,
    this.formatValue,
    this.startFocusNode,
    this.endFocusNode,
  }) : assert(max > min),
       assert(divisions == null || divisions > 0);

  final CdsRangeValues values;

  /// Null disables the slider.
  final ValueChanged<CdsRangeValues>? onChange;
  final ValueChanged<CdsRangeValues>? onChangeStart;
  final ValueChanged<CdsRangeValues>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final bool disabled;

  /// Accessibility label of the start thumb, e.g. "Minimum price".
  final String? startSemanticLabel;

  /// Accessibility label of the end thumb, e.g. "Maximum price".
  final String? endSemanticLabel;
  final CdsSliderValueFormatter? formatValue;
  final FocusNode? startFocusNode;
  final FocusNode? endFocusNode;

  static CdsRangeValues _toRange(List<double> v) => (start: v[0], end: v[1]);

  @override
  Widget build(BuildContext context) {
    return _CdsSliderCore(
      values: [values.start, values.end],
      onChange: onChange == null ? null : (v) => onChange!(_toRange(v)),
      onChangeStart: onChangeStart == null ? null : (v) => onChangeStart!(_toRange(v)),
      onChangeEnd: onChangeEnd == null ? null : (v) => onChangeEnd!(_toRange(v)),
      min: min,
      max: max,
      divisions: divisions,
      disabled: disabled,
      semanticLabels: [startSemanticLabel, endSemanticLabel],
      formatValue: formatValue,
      focusNodes: [startFocusNode, endFocusNode],
      autofocus: false,
    );
  }
}

class _StepIntent extends Intent {
  const _StepIntent(this.direction, {this.big = false, this.horizontal = false});

  /// +1 increases, -1 decreases. For horizontal keys this is in visual
  /// (left-to-right) terms and flipped under RTL.
  final int direction;
  final bool big;
  final bool horizontal;
}

class _ExtremeIntent extends Intent {
  const _ExtremeIntent({required this.toMax});

  final bool toMax;
}

const Map<ShortcutActivator, Intent> _shortcuts = {
  SingleActivator(LogicalKeyboardKey.arrowRight): _StepIntent(1, horizontal: true),
  SingleActivator(LogicalKeyboardKey.arrowLeft): _StepIntent(-1, horizontal: true),
  SingleActivator(LogicalKeyboardKey.arrowUp): _StepIntent(1),
  SingleActivator(LogicalKeyboardKey.arrowDown): _StepIntent(-1),
  SingleActivator(LogicalKeyboardKey.arrowRight, shift: true): _StepIntent(1, big: true, horizontal: true),
  SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true): _StepIntent(-1, big: true, horizontal: true),
  SingleActivator(LogicalKeyboardKey.arrowUp, shift: true): _StepIntent(1, big: true),
  SingleActivator(LogicalKeyboardKey.arrowDown, shift: true): _StepIntent(-1, big: true),
  SingleActivator(LogicalKeyboardKey.pageUp): _StepIntent(1, big: true),
  SingleActivator(LogicalKeyboardKey.pageDown): _StepIntent(-1, big: true),
  SingleActivator(LogicalKeyboardKey.home): _ExtremeIntent(toMax: false),
  SingleActivator(LogicalKeyboardKey.end): _ExtremeIntent(toMax: true),
};

class _CdsSliderCore extends StatefulWidget {
  const _CdsSliderCore({
    required this.values,
    required this.onChange,
    required this.onChangeStart,
    required this.onChangeEnd,
    required this.min,
    required this.max,
    required this.divisions,
    required this.disabled,
    required this.semanticLabels,
    required this.formatValue,
    required this.focusNodes,
    required this.autofocus,
  });

  final List<double> values;
  final ValueChanged<List<double>>? onChange;
  final ValueChanged<List<double>>? onChangeStart;
  final ValueChanged<List<double>>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final bool disabled;
  final List<String?> semanticLabels;
  final CdsSliderValueFormatter? formatValue;
  final List<FocusNode?> focusNodes;
  final bool autofocus;

  @override
  State<_CdsSliderCore> createState() => _CdsSliderCoreState();
}

class _CdsSliderCoreState extends State<_CdsSliderCore> with TickerProviderStateMixin {
  /// Displayed thumb positions as fractions of the track (0 to 1).
  /// Displayed thumb positions as fractions of the track (0 to 1).
  late final List<AnimationController> _positions;

  /// Where each thumb is settling to, so rebuilds with the same value do not restart a spring.
  late final List<double> _targets;
  late final List<bool> _focusHighlight;

  @override
  void initState() {
    super.initState();
    _positions = [
      for (final v in widget.values) AnimationController.unbounded(vsync: this, value: _fraction(v)),
    ];
    _targets = [for (final v in widget.values) _fraction(v)];
    _focusHighlight = List.filled(widget.values.length, false);
  }

  double _trackStart = 0;
  double _trackWidth = 1;
  int? _dragIndex;
  int? _pressedIndex;
  double _grabOffset = 0;
  List<double> _dragValues = const [];

  bool get _enabled => !widget.disabled && widget.onChange != null;
  bool get _isRange => widget.values.length == 2;

  double _fraction(double v) => ((v - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  double _valueAt(double fraction) {
    var f = fraction.clamp(0.0, 1.0);
    final d = widget.divisions;
    if (d != null) f = (f * d).round() / d;
    return widget.min + f * (widget.max - widget.min);
  }

  @override
  void didUpdateWidget(_CdsSliderCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var i = 0; i < _positions.length; i++) {
      if (i == _dragIndex) continue;
      final target = _fraction(widget.values[i]);
      if ((target - _targets[i]).abs() < 1e-9) continue;
      _targets[i] = target;
      _settle(i);
    }
  }

  @override
  void dispose() {
    for (final c in _positions) {
      c.dispose();
    }
    super.dispose();
  }

  void _settle(int i) {
    if (CdsMotion.reduceMotion(context)) {
      _positions[i].value = _targets[i];
      return;
    }
    CdsMotion.springTo(_positions[i], _targets[i], velocity: _positions[i].velocity);
  }

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  /// Fraction under a local x position, measured from the start edge.
  double _fractionAtDx(double dx) {
    final f = (dx - _trackStart) / _trackWidth;
    return (_rtl ? 1 - f : f).clamp(0.0, 1.0);
  }

  double _thumbCenterDx(int i) {
    final f = _positions[i].value.clamp(0.0, 1.0);
    return _trackStart + (_rtl ? 1 - f : f) * _trackWidth;
  }

  int _nearestThumb(double dx) {
    if (!_isRange) return 0;
    final d0 = (dx - _thumbCenterDx(0)).abs();
    final d1 = (dx - _thumbCenterDx(1)).abs();
    if ((d0 - d1).abs() < 0.5) {
      // Stacked thumbs: pick the one that can move toward the pointer.
      final towardEnd = _fractionAtDx(dx) > _positions[0].value;
      return towardEnd ? 1 : 0;
    }
    return d0 < d1 ? 0 : 1;
  }

  double _clampForThumb(int i, double fraction, List<double> fractions) {
    if (!_isRange) return fraction;
    return i == 0 ? math.min(fraction, fractions[1]) : math.max(fraction, fractions[0]);
  }

  void _commitValues(List<double> next, {bool discrete = false}) {
    if (discrete) widget.onChangeStart?.call(List.of(widget.values));
    widget.onChange?.call(next);
    if (discrete) widget.onChangeEnd?.call(next);
  }

  void _onTapUp(TapUpDetails details) {
    if (!_enabled) return;
    final i = _nearestThumb(details.localPosition.dx);
    final fractions = [for (final v in widget.values) _fraction(v)];
    final f = _clampForThumb(i, _fractionAtDx(details.localPosition.dx), fractions);
    final next = List.of(widget.values)..[i] = _valueAt(f);
    _commitValues(next, discrete: true);
  }

  void _onDragStart(DragStartDetails details) {
    if (!_enabled) return;
    final dx = details.localPosition.dx;
    final i = _nearestThumb(dx);
    final center = _thumbCenterDx(i);
    _grabOffset = (dx - center).abs() <= _thumbSize ? dx - center : 0;
    _dragIndex = i;
    _positions[i].stop();
    _dragValues = List.of(widget.values);
    widget.onChangeStart?.call(List.of(_dragValues));
    _followFinger(dx);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dragIndex == null) return;
    _followFinger(details.localPosition.dx);
  }

  void _followFinger(double dx) {
    final i = _dragIndex!;
    final fractions = [for (final c in _positions) c.value.clamp(0.0, 1.0)];
    final f = _clampForThumb(i, _fractionAtDx(dx - _grabOffset), fractions);
    _positions[i].value = f;
    final value = _valueAt(f);
    if (value != _dragValues[i]) {
      if (widget.divisions != null) cdsHaptic(CdsHapticFeedback.selection);
      _dragValues = List.of(_dragValues)..[i] = value;
      widget.onChange?.call(List.of(_dragValues));
    }
  }

  void _onDragEnd([DragEndDetails? _]) {
    final i = _dragIndex;
    if (i == null) return;
    _dragIndex = null;
    _pressedIndex = null;
    widget.onChangeEnd?.call(List.of(_dragValues));
    _targets[i] = _fraction(widget.values[i]);
    _settle(i);
    setState(() {});
  }

  double _step(bool big) {
    final range = widget.max - widget.min;
    final d = widget.divisions;
    if (d == null) return range * (big ? 0.1 : 0.01);
    return range / d * (big ? math.max(1, (d / 10).round()) : 1);
  }

  void _stepThumb(int i, int direction, {bool big = false}) {
    if (!_enabled) return;
    _setValue(i, widget.values[i] + direction * _step(big));
  }

  void _setValue(int i, double raw) {
    var v = raw.clamp(widget.min, widget.max);
    if (widget.divisions != null) v = _valueAt(_fraction(v));
    if (_isRange) v = i == 0 ? math.min(v, widget.values[1]) : math.max(v, widget.values[0]);
    if (v == widget.values[i]) return;
    _commitValues(List.of(widget.values)..[i] = v, discrete: true);
  }

  String _format(double v) {
    if (widget.formatValue != null) return widget.formatValue!(v);
    return '${(_fraction(v) * 100).round()}%';
  }

  Widget _thumb(BuildContext context, int i) {
    final theme = context.cds;
    final enabled = _enabled;
    var fill = theme.isDark ? theme.color.fg : theme.color.fgInverse;
    if (_pressedIndex == i || _dragIndex == i) {
      fill = CdsColorUtils.blendedColor(
        overlay: fill,
        blendOpacity: CdsInteractionOpacity.pressed,
        brightness: theme.brightness,
      );
    }
    final v = widget.values[i];
    final up = math.min(widget.max, v + _step(false));
    final down = math.max(widget.min, v - _step(false));
    final lower = _isRange && i == 1 ? widget.values[0] : widget.min;
    final upper = _isRange && i == 0 ? widget.values[1] : widget.max;

    Widget thumb = Container(
      width: _thumbSize,
      height: _thumbSize,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)),
        boxShadow: theme.shadow(CdsElevation.level1),
      ),
    );
    if (_focusHighlight[i]) {
      thumb = CustomPaint(
        foregroundPainter: CdsFocusRingPainter(
          borderRadius: BorderRadius.circular(_thumbSize),
          color: theme.color.bgLinePrimary,
          width: theme.borderWidth(200),
          gap: theme.borderWidth(200),
        ),
        child: thumb,
      );
    }
    thumb = FocusableActionDetector(
      enabled: enabled,
      focusNode: widget.focusNodes[i],
      autofocus: widget.autofocus && i == 0,
      shortcuts: _shortcuts,
      actions: {
        _StepIntent: CallbackAction<_StepIntent>(
          onInvoke: (intent) {
            final dir = intent.horizontal && _rtl ? -intent.direction : intent.direction;
            _stepThumb(i, dir, big: intent.big);
            return null;
          },
        ),
        _ExtremeIntent: CallbackAction<_ExtremeIntent>(
          onInvoke: (intent) {
            _setValue(i, intent.toMax ? upper : lower);
            return null;
          },
        ),
      },
      onShowFocusHighlight: (show) {
        if (_focusHighlight[i] != show) setState(() => _focusHighlight[i] = show);
      },
      child: thumb,
    );
    return MergeSemantics(
      child: Semantics(
        slider: true,
        enabled: enabled,
        focusable: enabled,
        label: widget.semanticLabels[i],
        value: _format(v),
        increasedValue: v < upper ? _format(math.min(up, upper)) : null,
        decreasedValue: v > lower ? _format(math.max(down, lower)) : null,
        onIncrease: enabled && v < upper ? () => _stepThumb(i, 1) : null,
        onDecrease: enabled && v > lower ? () => _stepThumb(i, -1) : null,
        child: thumb,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final enabled = _enabled;
    final trackHeight = theme.space(0.5);
    final activeColor = theme.color.bgPrimary;
    final inactiveColor = theme.color.bgLine;

    Widget slider = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0;
        _trackStart = _thumbSize / 2;
        _trackWidth = math.max(1, width - _thumbSize);
        return SizedBox(
          width: width,
          height: _hitHeight,
          child: AnimatedBuilder(
            animation: Listenable.merge(_positions),
            builder: (context, _) {
              final fractions = [for (final c in _positions) c.value.clamp(0.0, 1.0)];
              final activeStart = _isRange ? fractions[0] : 0.0;
              final activeEnd = _isRange ? fractions[1] : fractions[0];
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _TrackPainter(
                        start: _trackStart,
                        width: _trackWidth,
                        height: trackHeight,
                        activeStart: activeStart,
                        activeEnd: activeEnd,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        rtl: _rtl,
                      ),
                    ),
                  ),
                  for (var i = 0; i < fractions.length; i++)
                    PositionedDirectional(
                      start: fractions[i] * _trackWidth,
                      top: (_hitHeight - _thumbSize) / 2,
                      child: _thumb(context, i),
                    ),
                ],
              );
            },
          ),
        );
      },
    );

    slider = Listener(
      onPointerDown: enabled
          ? (e) => setState(() => _pressedIndex = _nearestThumb(e.localPosition.dx))
          : null,
      onPointerUp: (_) {
        if (_pressedIndex != null) setState(() => _pressedIndex = null);
      },
      onPointerCancel: (_) {
        if (_pressedIndex != null) setState(() => _pressedIndex = null);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onTapUp: enabled ? _onTapUp : null,
        onHorizontalDragStart: enabled ? _onDragStart : null,
        onHorizontalDragUpdate: enabled ? _onDragUpdate : null,
        onHorizontalDragEnd: enabled ? _onDragEnd : null,
        onHorizontalDragCancel: enabled ? _onDragEnd : null,
        child: slider,
      ),
    );

    return Opacity(opacity: widget.disabled ? CdsInteractionOpacity.disabled : 1, child: slider);
  }
}

class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.start,
    required this.width,
    required this.height,
    required this.activeStart,
    required this.activeEnd,
    required this.activeColor,
    required this.inactiveColor,
    required this.rtl,
  });

  final double start;
  final double width;
  final double height;
  final double activeStart;
  final double activeEnd;
  final Color activeColor;
  final Color inactiveColor;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final top = (size.height - height) / 2;
    final radius = Radius.circular(height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(start, top, width, height), radius),
      Paint()..color = inactiveColor,
    );
    double x(double f) => start + (rtl ? 1 - f : f) * width;
    final a = x(activeStart);
    final b = x(activeEnd);
    final left = math.min(a, b);
    final right = math.max(a, b);
    if (right - left <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(left, top, right, top + height), radius),
      Paint()..color = activeColor,
    );
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.start != start ||
      old.width != width ||
      old.height != height ||
      old.activeStart != activeStart ||
      old.activeEnd != activeEnd ||
      old.activeColor != activeColor ||
      old.inactiveColor != inactiveColor ||
      old.rtl != rtl;
}
