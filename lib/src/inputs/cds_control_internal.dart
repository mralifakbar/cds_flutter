import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

// Not exported. Shared by the checkbox, radio, switch and selection-cell widgets.

/// Drives the CDS control transition (`moderate1`, enter-functional in,
/// global out). `animateTo` starts from the current value, so toggling
/// mid-flight reverses without a jump.
class ControlProgress extends StatefulWidget {
  const ControlProgress({super.key, required this.active, required this.builder});

  final bool active;
  final Widget Function(BuildContext context, Animation<double> progress) builder;

  @override
  State<ControlProgress> createState() => _ControlProgressState();
}

class _ControlProgressState extends State<ControlProgress> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.active ? 1 : 0,
    duration: CdsDurations.moderate1,
  );

  @override
  void didUpdateWidget(ControlProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active == widget.active) return;
    final target = widget.active ? 1.0 : 0.0;
    final duration = CdsMotion.duration(context, CdsDurations.moderate1);
    if (duration == Duration.zero) {
      _controller.value = target;
      return;
    }
    _controller.animateTo(
      target,
      duration: duration,
      curve: widget.active ? CdsCurves.enterFunctional : CdsCurves.global,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}

/// The checkbox square. Fill and border cross-fade with [progress]; the glyph
/// scales 0.9 to 1 and fades in, per the CDS checkbox motion tokens.
class ControlCheckboxBox extends StatelessWidget {
  const ControlCheckboxBox({
    super.key,
    required this.progress,
    required this.checked,
    required this.indeterminate,
    this.controlColor = CdsColor.fgInverse,
    this.background,
    this.borderColor,
    this.borderRadius = 100,
    this.borderWidth = 100,
    this.elevation = CdsElevation.none,
    this.size,
  });

  final Animation<double> progress;
  final bool checked;
  final bool indeterminate;
  final CdsColor controlColor;
  final CdsColor? background;
  final CdsColor? borderColor;
  final int borderRadius;
  final int borderWidth;
  final CdsElevation elevation;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final px = size ?? theme.controlSize.checkboxSize;
    final iconPx = px - px / 5;
    final glyph = checked || !indeterminate ? CdsIconName.checkmark : CdsIconName.minus;
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value.clamp(0.0, 1.0);
        final bg = background != null
            ? theme.colorOf(background!)
            : Color.lerp(theme.color.bg, theme.color.bgPrimary, t)!;
        final border = borderColor != null
            ? theme.colorOf(borderColor!)
            : Color.lerp(theme.color.bgLineHeavy, theme.color.bgPrimary, t)!;
        return Container(
          width: px,
          height: px,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.radius(borderRadius)),
            border: Border.all(color: border, width: theme.borderWidth(borderWidth)),
            boxShadow: theme.shadow(elevation),
          ),
          child: Opacity(
            opacity: t,
            child: Transform.scale(
              scale: 0.9 + 0.1 * t,
              child: CdsIcon(glyph, pixelSize: iconPx, color: controlColor),
            ),
          ),
        );
      },
    );
  }
}

/// The radio circle with its inner dot (two thirds of the control by default).
class ControlRadioCircle extends StatelessWidget {
  const ControlRadioCircle({
    super.key,
    required this.progress,
    this.controlColor = CdsColor.bgPrimary,
    this.background = CdsColor.bg,
    this.borderColor,
    this.borderWidth = 100,
    this.elevation = CdsElevation.none,
    this.size,
    this.dotSize,
  });

  final Animation<double> progress;
  final CdsColor controlColor;
  final CdsColor background;
  final CdsColor? borderColor;
  final int borderWidth;
  final CdsElevation elevation;
  final double? size;
  final double? dotSize;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final px = size ?? theme.controlSize.radioSize;
    final dot = dotSize ?? px * 2 / 3;
    final on = theme.colorOf(controlColor);
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value.clamp(0.0, 1.0);
        final border =
            borderColor != null ? theme.colorOf(borderColor!) : Color.lerp(theme.color.bgLineHeavy, on, t)!;
        return Container(
          width: px,
          height: px,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorOf(background),
            shape: BoxShape.circle,
            border: Border.all(color: border, width: theme.borderWidth(borderWidth)),
            boxShadow: theme.shadow(elevation),
          ),
          child: Opacity(
            opacity: t,
            child: Transform.scale(
              scale: 0.9 + 0.1 * t,
              child: SizedBox.square(
                dimension: dot,
                child: DecoratedBox(decoration: BoxDecoration(color: on, shape: BoxShape.circle)),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Line height of [font] after text scaling, used to align a control with
/// the first line of its label.
double controlLineHeight(BuildContext context, CdsFont font) {
  final style = context.cds.typography[font];
  return MediaQuery.textScalerOf(context).scale(style.fontSize) * style.lineHeight / style.fontSize;
}

/// The pressable row shared by checkbox, radio and switch: control, then an
/// optional label whose color moves from `fgMuted` to `fg` as the control
/// turns on.
class ControlFrame extends StatelessWidget {
  const ControlFrame({
    super.key,
    required this.active,
    required this.control,
    required this.onPress,
    required this.disabled,
    required this.readOnly,
    required this.label,
    required this.labelNode,
    required this.labelColor,
    required this.font,
    required this.semanticLabel,
    required this.semanticHint,
    required this.focusNode,
    required this.autofocus,
    this.checked,
    this.mixed,
    this.toggled,
    this.inMutuallyExclusiveGroup,
    this.alignToFirstLine = true,
  });

  final bool active;
  final Widget Function(BuildContext context, Animation<double> progress) control;
  final VoidCallback? onPress;
  final bool disabled;
  final bool readOnly;
  final String? label;
  final Widget? labelNode;
  final CdsColor? labelColor;
  final CdsFont font;
  final String? semanticLabel;
  final String? semanticHint;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? checked;
  final bool? mixed;
  final bool? toggled;
  final bool? inMutuallyExclusiveGroup;

  /// Center the control on the label's first line (checkbox, radio) rather
  /// than on the whole row (switch, which is taller than a line).
  final bool alignToFirstLine;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return ControlProgress(
      active: active,
      builder: (context, progress) {
        final controlWidget = control(context, progress);
        Widget content;
        if (label == null && labelNode == null) {
          content = controlWidget;
        } else {
          Widget labelWidget = labelNode ??
              AnimatedBuilder(
                animation: progress,
                builder: (context, _) => CdsText(
                  label!,
                  font: font,
                  dangerouslySetColor: labelColor != null
                      ? theme.colorOf(labelColor!)
                      : Color.lerp(theme.color.fgMuted, theme.color.fg, progress.value.clamp(0.0, 1.0)),
                ),
              );
          if (semanticLabel != null) labelWidget = ExcludeSemantics(child: labelWidget);
          content = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: alignToFirstLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            spacing: theme.space(1),
            children: [
              if (alignToFirstLine)
                SizedBox(height: controlLineHeight(context, font), child: Center(child: controlWidget))
              else
                controlWidget,
              Flexible(child: labelWidget),
            ],
          );
        }
        if (readOnly && !disabled) {
          content = Opacity(opacity: CdsInteractionOpacity.disabled, child: content);
        }
        content = Semantics(
          checked: checked,
          mixed: mixed,
          toggled: toggled,
          inMutuallyExclusiveGroup: inMutuallyExclusiveGroup,
          readOnly: readOnly ? true : null,
          child: content,
        );
        return Align(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: 1,
          heightFactor: 1,
          child: CdsPressable(
            onPress: disabled || readOnly ? null : onPress,
            disabled: disabled,
            isButton: false,
            noScaleOnPress: true,
            debounce: Duration.zero,
            feedback: CdsHapticFeedback.light,
            minTapTargetSize: 44,
            borderRadius: 100,
            semanticLabel: semanticLabel,
            semanticHint: semanticHint,
            focusNode: focusNode,
            autofocus: autofocus,
            child: content,
          ),
        );
      },
    );
  }
}

/// A bordered, full-width selection row (CheckboxCell, RadioCell). While
/// pressed, a thicker `pressedBorderColor` border fades in over the resting
/// one, like CDS.
class ControlSelectionCell extends StatefulWidget {
  const ControlSelectionCell({
    super.key,
    required this.active,
    required this.control,
    required this.title,
    required this.titleNode,
    required this.description,
    required this.descriptionNode,
    required this.onPress,
    required this.disabled,
    required this.readOnly,
    required this.padding,
    required this.columnGap,
    required this.rowGap,
    required this.borderWidth,
    required this.borderRadius,
    required this.background,
    required this.borderColor,
    required this.pressedBorderColor,
    required this.pressedBorderWidth,
    required this.semanticLabel,
    required this.semanticHint,
    required this.focusNode,
    required this.autofocus,
    this.checked,
    this.mixed,
    this.inMutuallyExclusiveGroup,
  });

  final bool active;
  final Widget Function(BuildContext context, Animation<double> progress) control;
  final String title;
  final Widget? titleNode;
  final String? description;
  final Widget? descriptionNode;
  final VoidCallback? onPress;
  final bool disabled;
  final bool readOnly;
  final double padding;
  final double columnGap;
  final double rowGap;
  final int borderWidth;
  final int borderRadius;
  final CdsColor background;
  final CdsColor borderColor;
  final CdsColor pressedBorderColor;
  final int pressedBorderWidth;
  final String semanticLabel;
  final String semanticHint;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? checked;
  final bool? mixed;
  final bool? inMutuallyExclusiveGroup;

  @override
  State<ControlSelectionCell> createState() => _ControlSelectionCellState();
}

class _ControlSelectionCellState extends State<ControlSelectionCell> with SingleTickerProviderStateMixin {
  late final AnimationController _pressed = AnimationController(vsync: this, duration: CdsDurations.moderate1);
  bool _isPressed = false;

  @override
  void dispose() {
    _pressed.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (!mounted || _isPressed == value) return;
    setState(() => _isPressed = value);
    final duration = CdsMotion.duration(context, CdsDurations.moderate1);
    if (duration == Duration.zero) {
      _pressed.value = value ? 1 : 0;
    } else {
      _pressed.animateTo(value ? 1 : 0,
          duration: duration, curve: value ? CdsCurves.enterFunctional : CdsCurves.exitFunctional);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final w = widget;
    final radius = theme.radius(w.borderRadius);
    final delta = theme.borderWidth(w.pressedBorderWidth) - theme.borderWidth(w.borderWidth);
    final interactive = !w.disabled && !w.readOnly && w.onPress != null;

    final texts = ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.space(w.rowGap),
        children: [
          w.titleNode ?? CdsText(w.title, font: CdsFont.headline),
          if (w.descriptionNode != null)
            w.descriptionNode!
          else if (w.description != null)
            CdsText(w.description!, font: CdsFont.body, color: CdsColor.fgMuted),
        ],
      ),
    );

    Widget content = ControlProgress(
      active: w.active,
      builder: (context, progress) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.space(w.columnGap),
        children: [
          SizedBox(
            height: controlLineHeight(context, CdsFont.headline),
            child: Center(child: w.control(context, progress)),
          ),
          Expanded(child: texts),
        ],
      ),
    );
    if (w.readOnly && !w.disabled) {
      content = Opacity(opacity: CdsInteractionOpacity.disabled, child: content);
    }
    content = Semantics(
      checked: w.checked,
      mixed: w.mixed,
      inMutuallyExclusiveGroup: w.inMutuallyExclusiveGroup,
      readOnly: w.readOnly ? true : null,
      child: Padding(padding: EdgeInsets.all(theme.space(w.padding)), child: content),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CdsPressable(
          onPress: interactive ? w.onPress : null,
          onPressIn: () => _setPressed(true),
          onPressOut: () => _setPressed(false),
          disabled: w.disabled,
          isButton: false,
          noScaleOnPress: true,
          debounce: Duration.zero,
          feedback: CdsHapticFeedback.light,
          block: true,
          background: w.background,
          borderColor: _isPressed ? CdsColor.transparent : w.borderColor,
          borderWidth: w.borderWidth,
          borderRadius: w.borderRadius,
          semanticLabel: w.semanticLabel,
          semanticHint: w.semanticHint,
          focusNode: w.focusNode,
          autofocus: w.autofocus,
          child: content,
        ),
        Positioned(
          left: -delta,
          top: -delta,
          right: -delta,
          bottom: -delta,
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _pressed,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius + delta),
                  border: Border.all(
                    color: theme.colorOf(w.pressedBorderColor),
                    width: theme.borderWidth(w.pressedBorderWidth),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
