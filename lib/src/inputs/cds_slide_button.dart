import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../feedback/cds_progress_circle.dart';
import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import '../utils/cds_color_utils.dart';

/// Sizes of [CdsSlideButton].
enum CdsSlideButtonSize { s, m, l }

/// Handle color of [CdsSlideButton].
enum CdsSlideButtonVariant { primary, positive, negative }

class _SlideMetrics {
  const _SlideMetrics(this.height, this.radius, this.iconSize, this.handlePadding, this.backgroundPadding);

  final double height;
  final int radius;
  final CdsIconSize iconSize;
  final double handlePadding;
  final double backgroundPadding;

  static _SlideMetrics of(CdsSlideButtonSize size) => switch (size) {
        CdsSlideButtonSize.s => const _SlideMetrics(40, 700, CdsIconSize.s, 1.5, 7),
        CdsSlideButtonSize.m => const _SlideMetrics(48, 900, CdsIconSize.m, 2, 9),
        CdsSlideButtonSize.l => const _SlideMetrics(56, 900, CdsIconSize.m, 2, 9),
      };
}

/// Slide-to-confirm: the user drags the handle across the track to commit an
/// action that should not happen on a stray tap, such as sending funds.
///
/// ```dart
/// CdsSlideButton(
///   checked: sent,
///   onChange: (v) => setState(() => sent = v),
///   uncheckedLabel: 'Slide to send',
///   checkedLabel: 'Sending',
/// )
/// ```
///
/// The handle follows the finger 1:1 from where it was grabbed and stretches
/// with resistance past the end. On release it commits when it is past
/// [checkThreshold], or when the flick velocity would carry it there;
/// otherwise it springs back carrying the release velocity. Commit fires a
/// haptic, then [onChange] with `true`, then [onSlideComplete], then
/// [onSlideEnd].
///
/// The control is controlled: when [checked] changes, the handle springs to
/// full width (true) or back to its resting size (false). Set [checked] back to
/// false to reset it, for example after the action fails.
class CdsSlideButton extends StatefulWidget {
  const CdsSlideButton({
    super.key,
    required this.checked,
    this.onChange,
    this.uncheckedLabel,
    this.checkedLabel,
    this.uncheckedLabelNode,
    this.checkedLabelNode,
    this.startUncheckedNode,
    this.endCheckedNode,
    this.onSlideStart,
    this.onSlideCancel,
    this.onSlideEnd,
    this.onSlideComplete,
    this.disabled = false,
    this.size,
    this.compact = false,
    this.height,
    this.variant = CdsSlideButtonVariant.primary,
    this.borderRadius,
    this.checkThreshold = 0.7,
    this.autoCompleteSlideOnThresholdMet = false,
    this.feedback = CdsHapticFeedback.normal,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : assert(checkThreshold > 0 && checkThreshold <= 1);

  /// Whether the action has been confirmed. The handle fills the track when true.
  final bool checked;

  /// Called with `true` when a slide completes. Never called with `false` by
  /// the widget itself; reset by passing `checked: false`.
  final ValueChanged<bool>? onChange;

  /// Text centered on the track while unchecked, e.g. "Slide to send".
  final String? uncheckedLabel;

  /// Text centered on the full-width handle while checked, e.g. "Sending".
  final String? checkedLabel;

  /// Custom track content; overrides [uncheckedLabel] visually.
  final Widget? uncheckedLabelNode;

  /// Custom checked handle content; overrides [checkedLabel] visually.
  final Widget? checkedLabelNode;

  /// Replaces the forward arrow on the resting handle.
  final Widget? startUncheckedNode;

  /// Replaces the spinner on the checked handle.
  final Widget? endCheckedNode;
  final VoidCallback? onSlideStart;

  /// Fired when a slide ends short of committing. Called before [onSlideEnd].
  final VoidCallback? onSlideCancel;

  /// Fired last in every slide sequence.
  final VoidCallback? onSlideEnd;

  /// Fired after [onChange] when a slide commits, before [onSlideEnd].
  final VoidCallback? onSlideComplete;
  final bool disabled;

  /// Defaults to `l`, or `s` when [compact] is set.
  final CdsSlideButtonSize? size;

  /// Equivalent to the deprecated CDS `compact` prop. Prefer `size: CdsSlideButtonSize.s`.
  final bool compact;

  /// Overrides the size's height (40, 48 or 56). The control grows taller
  /// when large text needs more room.
  final double? height;
  final CdsSlideButtonVariant variant;

  /// Radius token. Defaults to 700 for `s` and 900 for `m` and `l`.
  final int? borderRadius;

  /// Fraction of the track (0 to 1] the handle must cover to commit.
  final double checkThreshold;

  /// Commit as soon as the threshold is reached, without waiting for release.
  final bool autoCompleteSlideOnThresholdMet;

  /// Haptic fired on commit.
  final CdsHapticFeedback feedback;

  /// Overrides the accessibility label, which defaults to the current label text.
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<CdsSlideButton> createState() => _CdsSlideButtonState();
}

class _CdsSlideButtonState extends State<CdsSlideButton> with SingleTickerProviderStateMixin {
  /// 0 is the resting handle (one height wide), 1 fills the track.
  late final AnimationController _progress =
      AnimationController.unbounded(vsync: this, value: widget.checked ? 1 : 0);

  double _trackWidth = 0;
  double _handleMin = 0;
  bool _dragging = false;
  bool _gestureDone = false;
  double _rawTrailing = 0;
  double _displayTrailing = 0;
  bool _pressed = false;
  bool _focusHighlight = false;

  bool get _interactive => !widget.checked && !widget.disabled;

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate()),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => _activate()),
  };

  double get _range => math.max(1, _trackWidth - _handleMin);

  @override
  void didUpdateWidget(CdsSlideButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checked != widget.checked) {
      _dragging = false;
      _animateTo(widget.checked ? 1 : 0, velocity: _progress.velocity);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _animateTo(double target, {double velocity = 0}) {
    if (CdsMotion.reduceMotion(context)) {
      _progress.value = target;
      return;
    }
    CdsMotion.springTo(_progress, target, spring: CdsSprings.standard, velocity: velocity);
  }

  void _activate() {
    if (!_interactive) return;
    _complete(0);
  }

  void _complete(double velocity) {
    cdsHaptic(widget.feedback);
    _animateTo(1, velocity: velocity);
    widget.onChange?.call(true);
    widget.onSlideComplete?.call();
    widget.onSlideEnd?.call();
  }

  double _direction(BuildContext context) => Directionality.of(context) == TextDirection.rtl ? -1 : 1;

  void _onDragStart(DragStartDetails details) {
    if (!_interactive) return;
    _progress.stop();
    _dragging = true;
    _gestureDone = false;
    _rawTrailing = _handleMin + _progress.value.clamp(0.0, 1.0) * _range;
    _displayTrailing = _rawTrailing;
    widget.onSlideStart?.call();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_dragging || _gestureDone) return;
    _rawTrailing += details.delta.dx * _direction(context);
    final double display;
    if (_rawTrailing > _trackWidth) {
      display = _trackWidth + CdsMotion.rubberband(_rawTrailing - _trackWidth, _trackWidth);
    } else {
      display = math.max(_handleMin, _rawTrailing);
    }
    _displayTrailing = display;
    _progress.value = (display - _handleMin) / _range;
    if (widget.autoCompleteSlideOnThresholdMet && display / _trackWidth >= widget.checkThreshold) {
      _gestureDone = true;
      _dragging = false;
      _complete(0);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_dragging) {
      _gestureDone = false;
      return;
    }
    _dragging = false;
    final velocity = (details.primaryVelocity ?? 0) * _direction(context);
    final fraction = _displayTrailing / _trackWidth;
    final projected = (_displayTrailing + CdsMotion.project(velocity)) / _trackWidth;
    final commit = fraction >= widget.checkThreshold || (velocity > 0 && projected >= widget.checkThreshold);
    if (commit) {
      _complete(velocity / _range);
    } else {
      _animateTo(0, velocity: velocity / _range);
      widget.onSlideCancel?.call();
      widget.onSlideEnd?.call();
    }
  }

  void _onDragCancel() {
    if (!_dragging) return;
    _dragging = false;
    _animateTo(0);
    widget.onSlideCancel?.call();
    widget.onSlideEnd?.call();
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final size = widget.size ?? (widget.compact ? CdsSlideButtonSize.s : CdsSlideButtonSize.l);
    final m = _SlideMetrics.of(size);
    final textScaler = MediaQuery.textScalerOf(context);
    final headline = theme.typography[CdsFont.headline];
    final textHeight = textScaler.scale(headline.fontSize) * headline.lineHeight / headline.fontSize;
    final height = math.max(widget.height ?? m.height, textHeight + theme.space(1) * 2);
    final radius = BorderRadius.circular(theme.radius(widget.borderRadius ?? m.radius));
    final iconPx = theme.iconSize(m.iconSize);

    var handleColor = theme.colorOf(switch (widget.variant) {
      CdsSlideButtonVariant.primary => CdsColor.bgPrimary,
      CdsSlideButtonVariant.positive => CdsColor.bgPositive,
      CdsSlideButtonVariant.negative => CdsColor.bgNegative,
    });
    if (widget.disabled) {
      handleColor = CdsColorUtils.blendedColor(
        overlay: handleColor,
        blendOpacity: CdsInteractionOpacity.disabled,
        brightness: theme.brightness,
        skipContrastOptimization: true,
      );
    } else if (_pressed) {
      handleColor = CdsColorUtils.blendedColor(
        overlay: handleColor,
        blendOpacity: CdsInteractionOpacity.pressed,
        brightness: theme.brightness,
      );
    }
    final fade = CdsMotion.duration(context, CdsDurations.moderate1);

    final uncheckedLabel = widget.uncheckedLabelNode ??
        (widget.uncheckedLabel == null
            ? const SizedBox.shrink()
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: theme.space(m.backgroundPadding)),
                child: CdsText(widget.uncheckedLabel!, font: CdsFont.headline, maxLines: 1, align: TextAlign.center),
              ));

    final checkedContent = Stack(
      alignment: Alignment.center,
      children: [
        widget.checkedLabelNode ??
            (widget.checkedLabel == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: height),
                    child: CdsText(widget.checkedLabel!,
                        font: CdsFont.headline, color: CdsColor.fgInverse, maxLines: 1, align: TextAlign.center),
                  )),
        PositionedDirectional(
          end: 0,
          top: 0,
          bottom: 0,
          child: Padding(
            padding: EdgeInsets.all(theme.space(m.handlePadding)),
            child: Center(
              child: widget.endCheckedNode ??
                  (widget.checked
                      ? CdsProgressCircle.indeterminate(size: iconPx, color: CdsColor.fgInverse, semanticLabel: null)
                      : SizedBox.square(dimension: iconPx)),
            ),
          ),
        ),
      ],
    );

    final uncheckedContent = Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: EdgeInsets.all(theme.space(m.handlePadding)),
        child: widget.startUncheckedNode ??
            CdsIcon(CdsIconName.forwardArrow, size: m.iconSize, color: CdsColor.fgInverse),
      ),
    );

    final handle = DecoratedBox(
      decoration: BoxDecoration(color: handleColor, borderRadius: radius),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedOpacity(opacity: widget.checked ? 1 : 0, duration: fade, child: checkedContent),
            AnimatedOpacity(opacity: widget.checked ? 0 : 1, duration: fade, child: uncheckedContent),
          ],
        ),
      ),
    );

    final interactive = _interactive;
    Widget draggableHandle = Listener(
      onPointerDown: interactive ? (_) => _setPressed(true) : null,
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: interactive ? _onDragStart : null,
        onHorizontalDragUpdate: interactive ? _onDragUpdate : null,
        onHorizontalDragEnd: interactive ? _onDragEnd : null,
        onHorizontalDragCancel: interactive ? _onDragCancel : null,
        child: handle,
      ),
    );
    draggableHandle = MouseRegion(
      cursor: interactive ? SystemMouseCursors.grab : SystemMouseCursors.basic,
      child: draggableHandle,
    );

    Widget body = LayoutBuilder(
      builder: (context, constraints) {
        _trackWidth = constraints.maxWidth;
        _handleMin = math.min(height, _trackWidth);
        return SizedBox(
          height: height,
          width: _trackWidth,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              final raw = _progress.value;
              final p = _dragging ? raw : raw.clamp(0.0, 1.0);
              final backgroundOpacity = widget.disabled ? 0.5 : (1 - p).clamp(0.0, 1.0);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: theme.color.bgSecondary, borderRadius: radius),
                      child: Center(child: Opacity(opacity: backgroundOpacity, child: uncheckedLabel)),
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    width: math.max(_handleMin, _handleMin + p * _range),
                    child: draggableHandle,
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (_focusHighlight) {
      body = CustomPaint(
        foregroundPainter: CdsFocusRingPainter(
          borderRadius: radius,
          color: theme.color.bgLinePrimary,
          width: theme.borderWidth(200),
          gap: theme.borderWidth(200),
        ),
        child: body,
      );
    }

    body = FocusableActionDetector(
      enabled: interactive,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      actions: _actions,
      onShowFocusHighlight: (v) {
        if (_focusHighlight != v) setState(() => _focusHighlight = v);
      },
      child: body,
    );

    final label = widget.semanticLabel ?? (widget.checked ? widget.checkedLabel : widget.uncheckedLabel);
    return Semantics(
      container: true,
      button: true,
      enabled: !widget.disabled,
      label: label,
      onTap: interactive ? _activate : null,
      excludeSemantics: true,
      child: body,
    );
  }
}
