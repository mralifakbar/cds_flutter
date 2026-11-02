import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import 'cds_control_internal.dart';

/// A checkbox with an optional label. Controlled: pass [checked] and update
/// it from [onChange].
///
/// ```dart
/// CdsCheckbox(
///   label: 'Remember this device',
///   checked: remember,
///   onChange: (v) => setState(() => remember = v),
/// )
/// ```
///
/// Set [indeterminate] when some, but not all, sub-items are selected; it
/// shows a minus glyph and is announced as "mixed". Tapping calls
/// [onChange] with `!checked`.
class CdsCheckbox extends StatelessWidget {
  const CdsCheckbox({
    super.key,
    this.checked = false,
    this.onChange,
    this.indeterminate = false,
    this.label,
    this.labelNode,
    this.disabled = false,
    this.readOnly = false,
    this.controlColor = CdsColor.fgInverse,
    this.background,
    this.borderColor,
    this.borderRadius = 100,
    this.borderWidth = 100,
    this.elevation = CdsElevation.none,
    this.controlSize,
    this.font = CdsFont.body,
    this.color,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
    this.autofocus = false,
  });

  final bool checked;

  /// Called with the next checked state. Null makes the checkbox inert.
  final ValueChanged<bool>? onChange;

  /// Partially selected. Shows a minus glyph unless [checked] is also true.
  final bool indeterminate;

  /// Label text next to the box. Also its accessibility label.
  final String? label;

  /// Custom label widget; takes precedence over [label].
  final Widget? labelNode;
  final bool disabled;

  /// Not changeable, dimmed like disabled, but announced as read-only.
  final bool readOnly;

  /// Glyph color.
  final CdsColor controlColor;

  /// Box fill in both states. Defaults to `bg` off and `bgPrimary` on.
  final CdsColor? background;

  /// Box border in both states. Defaults to `bgLineHeavy` off and `bgPrimary` on.
  final CdsColor? borderColor;

  /// Radius token.
  final int borderRadius;

  /// Border width token.
  final int borderWidth;
  final CdsElevation elevation;

  /// Box size in logical px. Defaults to `theme.controlSize.checkboxSize` (20).
  final double? controlSize;

  /// Label ramp entry.
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
    final filled = checked || indeterminate;
    return ControlFrame(
      active: filled,
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
      mixed: indeterminate && !checked,
      control: (context, progress) => ControlCheckboxBox(
        progress: progress,
        checked: checked,
        indeterminate: indeterminate,
        controlColor: controlColor,
        background: background,
        borderColor: borderColor,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
        elevation: elevation,
        size: controlSize,
      ),
    );
  }
}
