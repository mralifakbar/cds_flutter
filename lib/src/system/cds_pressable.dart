import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../utils/cds_color_utils.dart';

/// Haptic feedback fired when a pressable commits.
enum CdsHapticFeedback { none, light, normal, heavy, selection }

/// Blend opacities CDS uses for interaction states.
abstract final class CdsInteractionOpacity {
  static const double hovered = 0.88;
  static const double pressed = 0.82;
  static const double disabled = 0.5;
}

/// Fires [feedback] through the platform haptics engine.
void cdsHaptic(CdsHapticFeedback feedback) {
  switch (feedback) {
    case CdsHapticFeedback.none:
      return;
    case CdsHapticFeedback.light:
      HapticFeedback.lightImpact();
    case CdsHapticFeedback.normal:
      HapticFeedback.mediumImpact();
    case CdsHapticFeedback.heavy:
      HapticFeedback.heavyImpact();
    case CdsHapticFeedback.selection:
      HapticFeedback.selectionClick();
  }
}

/// The interaction primitive every tappable CDS component is built on.
///
/// * Feedback starts on pointer-down: the surface tints and scales to 0.98
///   with a spring that starts from wherever it is, so rapid taps never jump.
/// * Hover tint on pointer devices, a visible focus ring for keyboard users,
///   Enter and Space activate.
/// * Leading-edge debounce (500ms by default) stops accidental double
///   navigation, like CDS React Native.
/// * Reduced motion turns the scale off and keeps the tint.
///
/// ```dart
/// CdsPressable(
///   onPress: openAsset,
///   background: CdsColor.bgSecondary,
///   borderRadius: 400,
///   semanticLabel: 'Bitcoin',
///   child: const Padding(padding: EdgeInsets.all(16), child: CdsText('Bitcoin')),
/// )
/// ```
class CdsPressable extends StatefulWidget {
  const CdsPressable({
    super.key,
    required this.child,
    this.onPress,
    this.onLongPress,
    this.onPressIn,
    this.onPressOut,
    this.disabled = false,
    this.loading = false,
    this.background = CdsColor.transparent,
    this.dangerouslySetBackground,
    this.borderColor,
    this.borderWidth = 0,
    this.borderRadius,
    this.elevation = CdsElevation.none,
    this.transparentWhileInactive = false,
    this.noScaleOnPress = false,
    this.feedback = CdsHapticFeedback.none,
    this.debounce = const Duration(milliseconds: 500),
    this.minTapTargetSize = 0,
    this.block = false,
    this.semanticLabel,
    this.semanticHint,
    this.selected,
    this.toggled,
    this.checked,
    this.mixed,
    this.expanded,
    this.inMutuallyExclusiveGroup,
    this.isButton = true,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
    this.excludeChildSemantics = false,
    this.mergeChildSemantics = true,
  });

  final Widget child;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;
  final VoidCallback? onPressIn;
  final VoidCallback? onPressOut;
  final bool disabled;

  /// Blocks presses while true without dimming the surface.
  final bool loading;
  final CdsColor background;
  final Color? dangerouslySetBackground;

  /// Defaults to [background].
  final CdsColor? borderColor;

  /// Border width token (100 = 1px).
  final int borderWidth;

  /// Radius token (200 = 8px, 1000 = pill).
  final int? borderRadius;
  final CdsElevation elevation;

  /// Background stays clear until pressed or hovered (transparent buttons).
  final bool transparentWhileInactive;
  final bool noScaleOnPress;
  final CdsHapticFeedback feedback;

  /// Presses within this window after a press are ignored. [Duration.zero] disables it.
  final Duration debounce;

  /// Pads the hit area (and layout) up to this size so small controls stay
  /// reachable by thumb. 44 matches the iOS guideline.
  final double minTapTargetSize;

  /// Expand to the parent's full width.
  final bool block;
  final String? semanticLabel;
  final String? semanticHint;
  final bool? selected;
  final bool? toggled;

  /// Checkbox-style state for controls built on this primitive.
  final bool? checked;

  /// Indeterminate checkbox state.
  final bool? mixed;

  /// Disclosure state for accordions and menus.
  final bool? expanded;

  /// Radio-style exclusivity.
  final bool? inMutuallyExclusiveGroup;
  final bool isButton;
  final FocusNode? focusNode;
  final bool autofocus;
  final MouseCursor? mouseCursor;

  /// Use [semanticLabel] alone instead of merging the child's text into it.
  final bool excludeChildSemantics;

  /// Merge the child's semantics into this node (the default). Set false when
  /// the surface contains its own buttons, such as a card with a dismiss
  /// action, so each stays separately reachable.
  final bool mergeChildSemantics;

  @override
  State<CdsPressable> createState() => _CdsPressableState();
}

class _CdsPressableState extends State<CdsPressable> with SingleTickerProviderStateMixin {
  late final AnimationController _scale = AnimationController.unbounded(vsync: this, value: 1);
  bool _pressed = false;
  bool _hovered = false;
  bool _focusHighlight = false;
  DateTime? _lastPress;

  bool get _interactive => !widget.disabled && !widget.loading && (widget.onPress != null || widget.onLongPress != null);

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _commit()),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => _commit()),
  };

  @override
  void didUpdateWidget(CdsPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_interactive && _pressed) _setPressed(false);
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (!mounted || _pressed == value) return;
    setState(() => _pressed = value);
    if (value) {
      widget.onPressIn?.call();
    } else {
      widget.onPressOut?.call();
    }
    if (widget.noScaleOnPress || CdsMotion.reduceMotion(context)) {
      _scale.value = 1;
      return;
    }
    CdsMotion.springTo(
      _scale,
      value ? CdsMotion.pressScale : 1,
      spring: value ? CdsSprings.press : CdsSprings.standard,
      velocity: _scale.velocity,
    );
  }

  void _commit() {
    if (!_interactive || widget.onPress == null) return;
    // `clock` follows the fake clock in widget tests; DateTime.now() does not.
    final now = clock.now();
    if (widget.debounce > Duration.zero && _lastPress != null && now.difference(_lastPress!) < widget.debounce) {
      return;
    }
    _lastPress = now;
    cdsHaptic(widget.feedback);
    widget.onPress!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final brightness = theme.brightness;
    final base = widget.dangerouslySetBackground ?? theme.colorOf(widget.background);
    final borderBase = widget.borderColor == null ? base : theme.colorOf(widget.borderColor!);

    Color stateColor(Color c) {
      if (widget.disabled) {
        return CdsColorUtils.blendedColor(
            overlay: c, blendOpacity: CdsInteractionOpacity.disabled, brightness: brightness, skipContrastOptimization: true);
      }
      if (_pressed) {
        return CdsColorUtils.blendedColor(overlay: c, blendOpacity: CdsInteractionOpacity.pressed, brightness: brightness);
      }
      if (_hovered) {
        return CdsColorUtils.blendedColor(overlay: c, blendOpacity: CdsInteractionOpacity.hovered, brightness: brightness);
      }
      return c;
    }

    final inactiveClear = widget.transparentWhileInactive && !_pressed && !_hovered;
    final bg = inactiveClear ? const Color(0x00000000) : stateColor(base);
    final borderColor = inactiveClear ? const Color(0x00000000) : stateColor(borderBase);
    final radius = widget.borderRadius == null ? BorderRadius.zero : BorderRadius.circular(theme.radius(widget.borderRadius!));
    final borderWidth = theme.borderWidth(widget.borderWidth);
    final contentOpacity = widget.disabled
        ? CdsInteractionOpacity.disabled
        : (_pressed ? CdsInteractionOpacity.pressed : 1.0);

    Widget surface = AnimatedContainer(
      // Press is instant; release eases back so the tint does not flicker.
      duration: _pressed ? Duration.zero : CdsMotion.duration(context, CdsDurations.fast3),
      curve: CdsCurves.global,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: borderWidth > 0 ? Border.all(color: borderColor, width: borderWidth) : null,
        boxShadow: theme.shadow(widget.elevation),
      ),
      child: AnimatedOpacity(
        opacity: contentOpacity,
        duration: _pressed ? Duration.zero : CdsMotion.duration(context, CdsDurations.fast3),
        child: widget.child,
      ),
    );

    if (_focusHighlight) {
      surface = CustomPaint(
        foregroundPainter: CdsFocusRingPainter(
          borderRadius: radius,
          color: theme.color.bgLinePrimary,
          width: theme.borderWidth(200),
          gap: theme.borderWidth(200),
        ),
        child: surface,
      );
    }

    surface = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
      child: surface,
    );

    if (widget.minTapTargetSize > 0) {
      surface = ConstrainedBox(
        constraints: BoxConstraints(minWidth: widget.minTapTargetSize, minHeight: widget.minTapTargetSize),
        child: Center(widthFactor: 1, heightFactor: 1, child: surface),
      );
    }

    if (widget.block) surface = SizedBox(width: double.infinity, child: surface);

    final interactive = _interactive;
    Widget result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: interactive ? (_) => _setPressed(true) : null,
      onTapUp: interactive ? (_) => _setPressed(false) : null,
      onTapCancel: interactive ? () => _setPressed(false) : null,
      onTap: interactive && widget.onPress != null ? _commit : null,
      onLongPress: interactive && widget.onLongPress != null
          ? () {
              _setPressed(false);
              cdsHaptic(CdsHapticFeedback.normal);
              widget.onLongPress!();
            }
          : null,
      child: surface,
    );

    // Semantics sits inside the focus detector so excluding child semantics
    // never drops the focusable flag and focus action.
    result = Semantics(
      button: widget.isButton,
      enabled: !widget.disabled && !widget.loading,
      selected: widget.selected,
      toggled: widget.toggled,
      checked: widget.checked,
      mixed: widget.mixed,
      expanded: widget.expanded,
      inMutuallyExclusiveGroup: widget.inMutuallyExclusiveGroup,
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      onTap: interactive && widget.onPress != null ? _commit : null,
      excludeSemantics: widget.excludeChildSemantics,
      child: result,
    );

    result = FocusableActionDetector(
      enabled: interactive,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      actions: _actions,
      mouseCursor: interactive ? (widget.mouseCursor ?? SystemMouseCursors.click) : SystemMouseCursors.basic,
      onShowHoverHighlight: (v) {
        if (_hovered != v) setState(() => _hovered = v);
      },
      onShowFocusHighlight: (v) {
        if (_focusHighlight != v) setState(() => _focusHighlight = v);
      },
      child: result,
    );
    return widget.mergeChildSemantics ? MergeSemantics(child: result) : result;
  }
}

/// Draws the keyboard focus ring just outside a control's bounds, so it
/// never shifts layout. Shared by every focusable CDS component.
class CdsFocusRingPainter extends CustomPainter {
  const CdsFocusRingPainter({
    required this.borderRadius,
    required this.color,
    required this.width,
    required this.gap,
  });

  final BorderRadius borderRadius;
  final Color color;
  final double width;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final inflate = gap + width / 2;
    final rect = (Offset.zero & size).inflate(inflate);
    final rrect = borderRadius.resolve(TextDirection.ltr).toRRect(rect);
    final grown = RRect.fromRectAndCorners(
      rect,
      topLeft: rrect.tlRadius + Radius.circular(inflate),
      topRight: rrect.trRadius + Radius.circular(inflate),
      bottomLeft: rrect.blRadius + Radius.circular(inflate),
      bottomRight: rrect.brRadius + Radius.circular(inflate),
    );
    canvas.drawRRect(
      borderRadius == BorderRadius.zero ? RRect.fromRectXY(rect, 0, 0) : grown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(CdsFocusRingPainter old) =>
      old.borderRadius != borderRadius || old.color != color || old.width != width || old.gap != gap;
}
