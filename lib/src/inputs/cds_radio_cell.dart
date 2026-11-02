import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import 'cds_control_internal.dart';

/// A full-width bordered row with a radio button, a title and an optional
/// description. Stack several and keep one `checked` for a rich single choice.
///
/// ```dart
/// CdsRadioCell(
///   title: 'Instant',
///   description: 'Arrives in minutes. 1.5% fee',
///   checked: speed == 'instant',
///   onChange: (_) => setState(() => speed = 'instant'),
/// )
/// ```
///
/// While pressed, a 2px `bgPrimary` border fades in over the resting 1px
/// `bgLine` border.
class CdsRadioCell extends StatelessWidget {
  const CdsRadioCell({
    super.key,
    required this.title,
    this.titleNode,
    this.description,
    this.descriptionNode,
    this.checked = false,
    this.onChange,
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
    this.controlColor = CdsColor.bgPrimary,
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
  final bool disabled;
  final bool readOnly;

  /// Space token around the content.
  final double padding;

  /// Space token between the radio and the text.
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

  /// Dot color.
  final CdsColor controlColor;

  /// Defaults to "title, description".
  final String? semanticLabel;

  /// Defaults to "Tap to select this option" / "Tap to unselect this option".
  final String? semanticHint;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ControlSelectionCell(
      active: checked,
      control: (context, progress) => ControlRadioCircle(progress: progress, controlColor: controlColor),
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
      semanticHint: semanticHint ?? (checked ? 'Tap to unselect this option' : 'Tap to select this option'),
      focusNode: focusNode,
      autofocus: autofocus,
      checked: checked,
      inMutuallyExclusiveGroup: true,
    );
  }
}
