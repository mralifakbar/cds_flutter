import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import 'cds_number_format.dart';
import 'cds_rolling_number_parts.dart';

/// How a changed digit animates in [CdsRollingNumber].
enum CdsDigitTransitionVariant {
  /// Rolls through every intermediate digit (1, 2, 3 ... 9).
  every,

  /// Slides straight to the new digit. Direction follows the overall value
  /// change: up when the value grows, down when it shrinks.
  single,
}

/// Animation overrides for [CdsRollingNumber], mirroring CDS
/// `RollingNumberTransitionConfig` (`y`, `opacity`, `color`).
///
/// ```dart
/// CdsRollingNumberTransition(
///   yDuration: CdsDurations.moderate3,
///   colorDuration: CdsDurations.moderate3,
/// )
/// ```
@immutable
class CdsRollingNumberTransition {
  const CdsRollingNumberTransition({
    this.ySpring = defaultYSpring,
    this.yDuration,
    this.yCurve = CdsCurves.global,
    this.opacityDuration = CdsDurations.fast2,
    this.opacityCurve = CdsCurves.global,
    this.colorDuration = CdsDurations.slow4,
    this.colorCurve = CdsCurves.global,
  });

  /// CDS default for the digit roll: stiffness 280, damping 18, mass 0.3.
  static const SpringDescription defaultYSpring = SpringDescription(mass: 0.3, stiffness: 280, damping: 18);

  /// Spring for the vertical digit roll. Ignored when [yDuration] is set.
  final SpringDescription ySpring;

  /// Switches the digit roll from a spring to a timed animation with [yCurve].
  final Duration? yDuration;
  final Curve yCurve;

  /// Fade used by [CdsDigitTransitionVariant.single].
  final Duration opacityDuration;
  final Curve opacityCurve;

  /// How long the color pulse takes to return to the base color.
  final Duration colorDuration;
  final Curve colorCurve;

  @override
  bool operator ==(Object other) =>
      other is CdsRollingNumberTransition &&
      other.ySpring.mass == ySpring.mass &&
      other.ySpring.stiffness == ySpring.stiffness &&
      other.ySpring.damping == ySpring.damping &&
      other.yDuration == yDuration &&
      other.yCurve == yCurve &&
      other.opacityDuration == opacityDuration &&
      other.opacityCurve == opacityCurve &&
      other.colorDuration == colorDuration &&
      other.colorCurve == colorCurve;

  @override
  int get hashCode => Object.hash(ySpring.mass, ySpring.stiffness, ySpring.damping, yDuration, yCurve,
      opacityDuration, opacityCurve, colorDuration, colorCurve);
}

/// A number whose digits roll from their current value to the new one when
/// [value] changes, with an optional color pulse toward positive or negative.
///
/// ```dart
/// CdsRollingNumber(
///   value: balance,
///   font: CdsFont.display3,
///   format: const CdsNumberFormat.currency(),
///   colorPulseOnUpdate: true,
/// )
/// ```
///
/// Digits use tabular figures so the layout does not shift while they roll.
/// Screen readers hear the final formatted value, never intermediate digits.
class CdsRollingNumber extends StatefulWidget {
  const CdsRollingNumber({
    super.key,
    required this.value,
    this.format = const CdsNumberFormat(),
    this.formattedValue,
    this.prefix,
    this.suffix,
    this.start,
    this.end,
    this.font = CdsFont.body,
    this.color = CdsColor.fg,
    this.mono = false,
    this.tabularNumbers = true,
    this.colorPulseOnUpdate = false,
    this.positivePulseColor = CdsColor.fgPositive,
    this.negativePulseColor = CdsColor.fgNegative,
    this.enableSubscriptNotation = false,
    this.transition = const CdsRollingNumberTransition(),
    this.digitTransitionVariant = CdsDigitTransitionVariant.every,
    this.semanticLabel,
    this.semanticLabelPrefix,
    this.semanticLabelSuffix,
    this.liveRegion = true,
  });

  /// The number to display. Also drives the roll direction and color pulse
  /// when [formattedValue] is set.
  final num value;

  /// How [value] becomes text. Ignored when [formattedValue] is set.
  final CdsNumberFormat format;

  /// Preformatted text rendered instead of formatting [value].
  final String? formattedValue;

  /// Text before the number, e.g. `+`. Pulses with the number and is read by screen readers.
  final String? prefix;

  /// Text after the number, e.g. ` BTC`. Pulses with the number and is read by screen readers.
  final String? suffix;

  /// Widget before the [prefix], such as an icon. Not read by screen readers.
  final Widget? start;

  /// Widget after the [suffix]. Not read by screen readers.
  final Widget? end;
  final CdsFont font;

  /// Base text color. A color pulse starts from the pulse color and returns here.
  final CdsColor color;
  final bool mono;

  /// Equal-width digits. Keep this on: proportional digits change width while rolling.
  final bool tabularNumbers;

  /// Briefly tints the text [positivePulseColor] or [negativePulseColor] when
  /// the value changes and the displayed text changes with it.
  final bool colorPulseOnUpdate;
  final CdsColor positivePulseColor;
  final CdsColor negativePulseColor;

  /// Shows two or more leading fraction zeros as a subscript count:
  /// `0.00009` renders as `0.0₄9`.
  final bool enableSubscriptNotation;
  final CdsRollingNumberTransition transition;
  final CdsDigitTransitionVariant digitTransitionVariant;

  /// Replaces the announced value. Defaults to `prefix + formatted + suffix`.
  final String? semanticLabel;

  /// Announced before the value, e.g. `'up'`.
  final String? semanticLabelPrefix;

  /// Announced after the value.
  final String? semanticLabelSuffix;

  /// Announce value changes politely, like CDS `accessibilityLiveRegion="polite"`.
  final bool liveRegion;

  @override
  State<CdsRollingNumber> createState() => _CdsRollingNumberState();
}

class _CdsRollingNumberState extends State<CdsRollingNumber> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, value: 1);
  CdsColor? _pulseColor;
  bool _rendered = false;
  _RollDirection _direction = _RollDirection.up;

  String get _formatted => widget.formattedValue ?? widget.format.format(widget.value);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _rendered = true;
    });
  }

  @override
  void didUpdateWidget(CdsRollingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prev = oldWidget.value;
    final next = widget.value;
    if (prev.isNaN || next.isNaN || prev == next) return;
    _direction = next > prev ? _RollDirection.up : _RollDirection.down;

    final oldFormatted = oldWidget.formattedValue ?? oldWidget.format.format(prev);
    // 125,000 to 125,001 shown as "125K" did not visibly change, so it does not pulse.
    if (!widget.colorPulseOnUpdate || oldFormatted == _formatted) return;
    if (CdsMotion.reduceMotion(context)) {
      _pulse.value = 1;
      return;
    }
    _pulseColor = next > prev ? widget.positivePulseColor : widget.negativePulseColor;
    _pulse
      ..duration = widget.transition.colorDuration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final formatted = _formatted;
    final decimalSeparator =
        widget.formattedValue != null ? '.' : widget.format.decimalSeparator;
    final parts = splitRollingNumber(
      formatted,
      decimalSeparator: decimalSeparator,
      enableSubscriptNotation: widget.enableSubscriptNotation,
    );
    final reduceMotion = CdsMotion.reduceMotion(context);
    final fontStyle = theme.typography[widget.font];
    final baseColor = theme.colorOf(widget.color);

    final announced = widget.semanticLabel ?? '${widget.prefix ?? ''}$formatted${widget.suffix ?? ''}';
    final label = [widget.semanticLabelPrefix, announced, widget.semanticLabelSuffix]
        .map((s) => s?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .join(' ');

    final visible = AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final pulsing = _pulseColor != null && _pulse.isAnimating;
        final color = pulsing
            ? Color.lerp(theme.colorOf(_pulseColor!), baseColor,
                widget.transition.colorCurve.transform(_pulse.value))!
            : baseColor;
        final style = fontStyle.toTextStyle(
          color: color,
          mono: widget.mono,
          tabularNumbers: widget.tabularNumbers,
        );

        Widget symbol(String text, {Key? key}) => Text(text, key: key, style: style, maxLines: 1, softWrap: false);

        Widget part(RollingNumberPart p) {
          if (p.type == RollingNumberPartType.symbol) return symbol(p.text!, key: ValueKey(p.key));
          return _RollingDigit(
            key: ValueKey(p.key),
            digit: p.digit!,
            // Columns added after the first frame roll up from 0, like CDS.
            initialDigit: _rendered && !reduceMotion ? 0 : p.digit!,
            style: style,
            variant: widget.digitTransitionVariant,
            direction: _direction,
            transition: widget.transition,
            reduceMotion: reduceMotion,
          );
        }

        final row = Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            ?widget.start,
            if (widget.prefix != null && widget.prefix!.isNotEmpty) symbol(widget.prefix!),
            ...parts.all.map(part),
            if (widget.suffix != null && widget.suffix!.isNotEmpty) symbol(widget.suffix!),
            ?widget.end,
          ],
        );
        // A number cannot wrap, so when it is wider than its space (large
        // balances, large text settings) it scales down instead of clipping.
        return FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: row);
      },
    );

    return Semantics(
      container: true,
      label: label,
      liveRegion: widget.liveRegion,
      child: ExcludeSemantics(child: visible),
    );
  }
}

enum _RollDirection { up, down }

class _RollingDigit extends StatefulWidget {
  const _RollingDigit({
    super.key,
    required this.digit,
    required this.initialDigit,
    required this.style,
    required this.variant,
    required this.direction,
    required this.transition,
    required this.reduceMotion,
  });

  final int digit;
  final int initialDigit;
  final TextStyle style;
  final CdsDigitTransitionVariant variant;
  final _RollDirection direction;
  final CdsRollingNumberTransition transition;
  final bool reduceMotion;

  @override
  State<_RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<_RollingDigit> with TickerProviderStateMixin {
  /// Digit position for [CdsDigitTransitionVariant.every]; progress 0 to 1
  /// for [CdsDigitTransitionVariant.single].
  late final AnimationController _y = AnimationController.unbounded(vsync: this);
  late final AnimationController _opacity = AnimationController(vsync: this, value: 1);
  late int _current;
  int? _previous;
  late _RollDirection _singleDirection;

  @override
  void initState() {
    super.initState();
    _current = widget.initialDigit;
    _singleDirection = widget.direction;
    if (widget.variant == CdsDigitTransitionVariant.every) {
      _y.value = widget.initialDigit.toDouble();
    } else {
      _y.value = 1;
    }
    if (widget.initialDigit != widget.digit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animateTo(widget.digit);
      });
    }
  }

  @override
  void didUpdateWidget(_RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant != widget.variant) {
      _y.value = widget.variant == CdsDigitTransitionVariant.every ? _current.toDouble() : 1;
      _opacity.value = 1;
      _previous = null;
    }
    if (oldWidget.digit != widget.digit) _animateTo(widget.digit);
  }

  void _drive(AnimationController controller, double target) {
    if (widget.reduceMotion) {
      controller.value = target;
      return;
    }
    final duration = widget.transition.yDuration;
    if (duration != null) {
      controller.animateTo(target, duration: duration, curve: widget.transition.yCurve);
    } else {
      CdsMotion.springTo(controller, target, spring: widget.transition.ySpring, velocity: controller.velocity);
    }
  }

  void _animateTo(int digit) {
    if (digit == _current) return;
    if (widget.variant == CdsDigitTransitionVariant.every) {
      _current = digit;
      _drive(_y, digit.toDouble());
      return;
    }
    setState(() {
      _previous = _current;
      _current = digit;
      _singleDirection = widget.direction;
    });
    if (widget.reduceMotion) {
      _y.value = 1;
      _opacity.value = 1;
      return;
    }
    _y.value = 0;
    _drive(_y, 1);
    _opacity
      ..duration = widget.transition.opacityDuration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _y.dispose();
    _opacity.dispose();
    super.dispose();
  }

  Text _glyph(int digit) => Text('$digit', style: widget.style, maxLines: 1, softWrap: false, textAlign: TextAlign.center);

  @override
  Widget build(BuildContext context) {
    // The invisible target digit sizes the column to exactly one glyph cell.
    final sizer = Visibility(
      visible: false,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: _glyph(widget.digit),
    );

    if (widget.variant == CdsDigitTransitionVariant.every) {
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          sizer,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _y,
              builder: (context, child) => FractionalTranslation(
                // The column is ten cells tall, so one digit is a tenth of it.
                translation: Offset(0, -_y.value / 10),
                child: child,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [for (var d = 0; d < 10; d++) _glyph(d)],
              ),
            ),
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_y, _opacity]),
      builder: (context, _) {
        final animating = _y.isAnimating || _opacity.isAnimating;
        // A spring settles within tolerance of 1; snap so the old digit leaves the tree.
        final progress = animating ? _y.value : 1.0;
        final fade = animating ? widget.transition.opacityCurve.transform(_opacity.value.clamp(0.0, 1.0)) : 1.0;
        final sign = _singleDirection == _RollDirection.up ? 1.0 : -1.0;
        final showPrevious = _previous != null && animating;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            sizer,
            if (showPrevious)
              Positioned.fill(
                child: FractionalTranslation(
                  translation: Offset(0, -progress * sign),
                  child: Opacity(opacity: 1 - fade, child: _glyph(_previous!)),
                ),
              ),
            Positioned.fill(
              child: FractionalTranslation(
                translation: Offset(0, (1 - progress) * sign),
                child: Opacity(opacity: showPrevious ? fade : 1, child: _glyph(_current)),
              ),
            ),
          ],
        );
      },
    );
  }
}
