import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_tokens.dart';
import 'cds_chip.dart';
import 'cds_media_chip.dart';

/// A removable chip for a value the user entered or picked, such as a
/// selected asset in a multi-select. Pressing it calls [onPress], which
/// should remove the value.
///
/// ```dart
/// CdsInputChip(label: 'BTC', onPress: () => setState(() => selected.remove('BTC')))
/// ```
///
/// Active (inverted) by default, with a close icon at the end. Screen readers
/// hear "Remove BTC" as a button.
class CdsInputChip extends StatelessWidget {
  const CdsInputChip({
    super.key,
    required this.label,
    this.onPress,
    this.start,
    this.size = CdsChipSize.s,
    this.active = true,
    this.activeBackground,
    this.activeColor,
    this.maxWidth = 200,
    this.disabled = false,
    this.feedback = CdsHapticFeedback.light,
    this.semanticLabel,
    this.focusNode,
  });

  final String label;

  /// Removes the value. Leave null to show a non-interactive chip.
  final VoidCallback? onPress;

  /// Leading media widget.
  final Widget? start;
  final CdsChipSize size;

  /// Inverted colors. CDS input chips are active by default.
  final bool active;
  final CdsColor? activeBackground;
  final CdsColor? activeColor;
  final double maxWidth;
  final bool disabled;
  final CdsHapticFeedback feedback;

  /// Defaults to `'Remove $label'`.
  final String? semanticLabel;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return CdsMediaChip(
      label: label,
      start: start,
      end: const CdsIcon(CdsIconName.close, size: CdsIconSize.xs, active: true, color: CdsColor.fg),
      onPress: onPress,
      size: size,
      active: active,
      activeBackground: activeBackground,
      activeColor: activeColor,
      maxWidth: maxWidth,
      disabled: disabled,
      feedback: feedback,
      semanticLabel: semanticLabel ?? 'Remove $label',
      excludeChildSemantics: true,
      focusNode: focusNode,
    );
  }
}
