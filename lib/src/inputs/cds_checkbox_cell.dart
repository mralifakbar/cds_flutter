import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import 'cds_control_internal.dart';

/// A full-width bordered row with a checkbox, a title and an optional
/// description. The whole row toggles.
///
/// ```dart
/// CdsCheckboxCell(
///   title: 'Recurring buy',
///   description: 'Repeat this purchase every week',
///   checked: recurring,
///   onChange: (v) => setState(() => recurring = v),
/// )
/// ```
///
/// While pressed, a 2px `bgPrimary` border fades in over the resting 1px
/// `bgLine` border.
class CdsCheckboxCell extends StatelessWidget {
  const CdsCheckboxCell({
    super.key,
    required this.title,
    this.titleNode,
    this.description,
    this.descriptionNode,
    this.checked = false,
    this.onChange,
    this.indeterminate = false,
    this.disabled = false,
    this.readOnly = false,
    this.padding = 2,
    this.columnGap = 2,
    this.rowGap = 0,
    this.borderWidth = 100,
    this.borderRadius = 200,
    this.background = CdsColor.bg,
    this.borderColor = CdsColor.bgLine,
    this.pressedBorderColor = CdsColor.bgPrimary,
    this.pressedBorderWidth = 200,
    this.controlColor = CdsColor.fgInverse,
    this.controlSize,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
    this.autofocus = false,
  });

  /// Title in `headline`. Also part of the accessibility label.
  final String title;

  /// Custom title widget; takes precedence over [title] visually.
  final Widget? titleNode;

  /// Muted `body` text under the title.
  final String? description;
  final Widget? descriptionNode;
  final bool checked;

  /// Called with `!checked` when the row is pressed.
  final ValueChanged<bool>? onChange;
  final bool indeterminate;
  final bool disabled;
  final bool readOnly;

  /// Space token around the content.
  final double padding;

  /// Space token between the checkbox and the text.
  final double columnGap;

  /// Space token between title and description.
  final double rowGap;

  /// Border width token.
  final int borderWidth;

  /// Radius token.
  final int borderRadius;
  final CdsColor background;
  final CdsColor borderColor;
  final CdsColor pressedBorderColor;

  /// Border width token while pressed.
  final int pressedBorderWidth;

  /// Checkbox glyph color.
  final CdsColor controlColor;

  /// Checkbox size in logical px. Defaults to `theme.controlSize.checkboxSize`.
  final double? controlSize;

  /// Defaults to "title, description".
  final String? semanticLabel;

  /// Defaults to "Tap to check this option" / "Tap to uncheck this option".
  final String? semanticHint;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ControlSelectionCell(
      active: checked || indeterminate,
      control: (context, progress) => ControlCheckboxBox(
        progress: progress,
        checked: checked,
        indeterminate: indeterminate,
        controlColor: controlColor,
        size: controlSize,
      ),
      title: title,
      titleNode: titleNode,
      description: description,
      descriptionNode: descriptionNode,
      onPress: onChange == null ? null : () => onChange!(!checked),
      disabled: disabled || (onChange == null && !readOnly),
      readOnly: readOnly,
      padding: padding,
      columnGap: columnGap,
      rowGap: rowGap,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      background: background,
      borderColor: borderColor,
      pressedBorderColor: pressedBorderColor,
      pressedBorderWidth: pressedBorderWidth,
      semanticLabel: semanticLabel ?? [title, ?description].join(', '),
      semanticHint: semanticHint ?? (checked ? 'Tap to uncheck this option' : 'Tap to check this option'),
      focusNode: focusNode,
      autofocus: autofocus,
      checked: checked,
      mixed: indeterminate && !checked,
    );
  }
}
