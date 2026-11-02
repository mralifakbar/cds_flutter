import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import 'cds_control_internal.dart';

/// A single radio button with an optional label. Use [CdsRadioGroup] (or
/// [CdsControlGroup.radio]) for a set of options: it handles selection and
/// arrow-key navigation.
///
/// ```dart
/// CdsRadio(
///   label: 'Bank account',
///   checked: method == 'bank',
///   onChange: (_) => setState(() => method = 'bank'),
/// )
/// ```
///
/// Like CDS, tapping calls [onChange] with `!checked`.
class CdsRadio extends StatelessWidget {
  const CdsRadio({
    super.key,
    this.checked = false,
    this.onChange,
    this.label,
    this.labelNode,
    this.disabled = false,
    this.readOnly = false,
    this.controlColor = CdsColor.bgPrimary,
    this.background = CdsColor.bg,
    this.borderColor,
    this.borderWidth = 100,
    this.elevation = CdsElevation.none,
    this.controlSize,
    this.dotSize,
    this.font = CdsFont.body,
    this.color,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
    this.autofocus = false,
  });

  final bool checked;

  /// Called with `!checked` on tap. Null makes the radio inert.
  final ValueChanged<bool>? onChange;

  /// Label text next to the circle. Also its accessibility label.
  final String? label;

  /// Custom label widget; takes precedence over [label].
  final Widget? labelNode;
  final bool disabled;

  /// Not changeable, dimmed like disabled, but announced as read-only.
  final bool readOnly;

  /// Dot color, and border color when checked.
  final CdsColor controlColor;
  final CdsColor background;

  /// Border in both states. Defaults to `bgLineHeavy` off and [controlColor] on.
  final CdsColor? borderColor;

  /// Border width token.
  final int borderWidth;
  final CdsElevation elevation;

  /// Circle size in logical px. Defaults to `theme.controlSize.radioSize` (20).
  final double? controlSize;

  /// Inner dot diameter. Defaults to two thirds of the control size.
  final double? dotSize;
  final CdsFont font;

  /// Fixed label color. By default the label goes from `fgMuted` to `fg` when checked.
  final CdsColor? color;

  /// Overrides the label for screen readers. Required when there is no [label].
  final String? semanticLabel;
  final String? semanticHint;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ControlFrame(
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
      checked: checked,
      inMutuallyExclusiveGroup: true,
      control: (context, progress) => ControlRadioCircle(
        progress: progress,
        controlColor: controlColor,
        background: background,
        borderColor: borderColor,
        borderWidth: borderWidth,
        elevation: elevation,
        size: controlSize,
        dotSize: dotSize,
      ),
    );
  }
}
