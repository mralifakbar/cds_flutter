import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import 'cds_control_internal.dart';

/// Track color a [CdsSwitch] shows when on.
enum CdsSwitchVariant {
  primary(CdsColor.bgPrimary),
  positive(CdsColor.bgPositive),
  negative(CdsColor.bgNegative);

  const CdsSwitchVariant(this.background);

  /// Track color when checked.
  final CdsColor background;
}

/// An on/off switch with an optional label. Controlled: pass [checked] and
/// update it from [onChange].
///
/// ```dart
/// CdsSwitch(
///   label: 'Price alerts',
///   checked: alerts,
///   onChange: (v) => setState(() => alerts = v),
/// )
/// ```
///
/// Tap anywhere on the row to toggle. The thumb can also be dragged: it
/// follows the finger, resists past either end, and on release springs to
/// the side the gesture was heading toward, carrying the release velocity.
class CdsSwitch extends StatelessWidget {
  const CdsSwitch({
    super.key,
    this.checked = false,
    this.onChange,
    this.label,
    this.labelNode,
    this.variant = CdsSwitchVariant.primary,
    this.disabled = false,
    this.readOnly = false,
    this.background,
    this.controlColor,
    this.elevation = CdsElevation.none,
    this.font = CdsFont.body,
    this.color,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
    this.autofocus = false,
  });

  final bool checked;

  /// Called with the next state after a tap or a drag that changes sides.
  final ValueChanged<bool>? onChange;

  /// Label text next to the switch. Also its accessibility label.
  final String? label;

  /// Custom label widget; takes precedence over [label].
  final Widget? labelNode;

  /// Track color when on.
  final CdsSwitchVariant variant;
  final bool disabled;

  /// Not changeable, dimmed like disabled, but announced as read-only.
  final bool readOnly;

  /// Track color when on; overrides [variant].
  final CdsColor? background;

  /// Thumb color. Defaults to `fgInverse` in light and `fg` in dark.
  final CdsColor? controlColor;

  /// Thumb shadow.
  final CdsElevation elevation;
  final CdsFont font;

  /// Fixed label color. By default the label goes from `fgMuted` to `fg` when on.
  final CdsColor? color;

  /// Overrides the label for screen readers. Required when there is no [label].
  final String? semanticLabel;
  final String? semanticHint;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final inert = disabled || readOnly || onChange == null;
    Widget frame = ControlFrame(
      active: checked,
      onPress: onChange == null ? null : () => onChange!(!checked),
      disabled: disabled || (onChange == null && !readOnly),
      readOnly: readOnly,
      label: label,
      labelNode: labelNode,
      labelColor: color,
      font: font,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      focusNode: focusNode,
      autofocus: autofocus,
      toggled: checked,
      alignToFirstLine: false,
      control: (context, progress) => _SwitchTrack(
        checked: checked,
        onChange: inert ? null : onChange,
        onBackground: background ?? variant.background,
        controlColor: controlColor,
        elevation: elevation,
      ),
    );
    if (label != null || labelNode != null) {
      frame = ConstrainedBox(
        constraints: BoxConstraints(minHeight: context.cds.controlSize.switchHeight),
        child: frame,
      );
    }
    return frame;
  }
}

class _SwitchTrack extends StatefulWidget {
  const _SwitchTrack({
    required this.checked,
    required this.onChange,
    required this.onBackground,
    required this.controlColor,
    required this.elevation,
  });

  final bool checked;
  final ValueChanged<bool>? onChange;
  final CdsColor onBackground;
  final CdsColor? controlColor;
  final CdsElevation elevation;

  @override
  State<_SwitchTrack> createState() => _SwitchTrackState();
}

class _SwitchTrackState extends State<_SwitchTrack> with SingleTickerProviderStateMixin {
  /// Thumb position: 0 is off, 1 is on. Goes past the ends while rubberbanding.
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
    value: widget.checked ? 1 : 0,
  );
  bool _dragging = false;
  double _dragStart = 0;
  double _dragDx = 0;

  @override
  void didUpdateWidget(_SwitchTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checked != widget.checked && !_dragging) _settle(widget.checked);
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _settle(bool on, {double velocity = 0}) {
    final target = on ? 1.0 : 0.0;
    if (CdsMotion.reduceMotion(context)) {
      _position.value = target;
      return;
    }
    CdsMotion.springTo(
      _position,
      target,
      spring: velocity.abs() > 1 ? CdsSprings.momentum : CdsSprings.standard,
      velocity: velocity == 0 ? _position.velocity : velocity,
    );
  }

  double get _travel {
    final size = context.cds.controlSize;
    final inset = (size.switchHeight - size.switchThumbSize) / 2;
    return size.switchWidth - size.switchThumbSize - inset * 2;
  }

  double get _direction => Directionality.of(context) == TextDirection.rtl ? -1 : 1;

  void _onDragStart(DragStartDetails details) {
    _position.stop();
    _dragging = true;
    _dragStart = _position.value.clamp(0.0, 1.0);
    _dragDx = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final travel = _travel;
    _dragDx += (details.primaryDelta ?? 0) * _direction;
    var px = _dragStart * travel + _dragDx;
    if (px < 0) {
      px = CdsMotion.rubberband(px, travel);
    } else if (px > travel) {
      px = travel + CdsMotion.rubberband(px - travel, travel);
    }
    _position.value = px / travel;
  }

  void _onDragEnd(DragEndDetails details) {
    _dragging = false;
    final travel = _travel;
    final velocity = (details.primaryVelocity ?? 0) * _direction;
    final projected = _position.value * travel + CdsMotion.project(velocity);
    final on = projected >= travel / 2;
    _settle(on, velocity: velocity / travel);
    if (on != widget.checked) {
      cdsHaptic(CdsHapticFeedback.light);
      widget.onChange?.call(on);
      // A controlled parent may refuse the change; return to its value.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_dragging && widget.checked != on) _settle(widget.checked);
      });
    }
  }

  void _onDragCancel() {
    if (!_dragging) return;
    _dragging = false;
    _settle(widget.checked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final size = theme.controlSize;
    final inset = (size.switchHeight - size.switchThumbSize) / 2;
    final travel = _travel;
    final rtl = _direction < 0;
    final off = theme.color.bgTertiary;
    final on = theme.colorOf(widget.onBackground);
    final thumbColor =
        theme.colorOf(widget.controlColor ?? (theme.isDark ? CdsColor.fg : CdsColor.fgInverse));
    final draggable = widget.onChange != null;

    final track = AnimatedBuilder(
      animation: _position,
      builder: (context, _) {
        final p = _position.value;
        final x = rtl ? travel * (1 - p) : travel * p;
        return SizedBox(
          width: size.switchWidth,
          height: size.switchHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(off, on, p.clamp(0.0, 1.0)),
              borderRadius: BorderRadius.circular(theme.radius(1000)),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: inset + x,
                  top: inset,
                  width: size.switchThumbSize,
                  height: size.switchThumbSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: thumbColor,
                      shape: BoxShape.circle,
                      // CDS keeps the thumb border a hairline regardless of theme.
                      border: Border.all(color: theme.color.bgLine, width: 0.5),
                      boxShadow: theme.shadow(widget.elevation),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!draggable) return track;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Count movement from the touch point so the thumb never lags the finger by the slop.
      dragStartBehavior: DragStartBehavior.down,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onHorizontalDragCancel: _onDragCancel,
      child: track,
    );
  }
}
