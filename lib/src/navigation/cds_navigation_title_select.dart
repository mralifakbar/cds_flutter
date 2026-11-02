import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../typography/cds_text.dart';
import '../theme/cds_typography.dart';

/// A navigation title with a caret that opens a picker, e.g. to switch
/// between accounts or portfolios.
///
/// This widget only renders the trigger and calls [onPress]; open your own
/// tray or menu there and pass [open] while it is showing so the caret flips
/// and screen readers hear the expanded state.
///
/// ```dart
/// CdsNavigationTitleSelect(
///   label: portfolio.name,
///   open: pickerOpen,
///   onPress: () async {
///     setState(() => pickerOpen = true);
///     await showPortfolioPicker(context);
///     setState(() => pickerOpen = false);
///   },
/// )
/// ```
class CdsNavigationTitleSelect extends StatelessWidget {
  const CdsNavigationTitleSelect({
    super.key,
    required this.label,
    required this.onPress,
    this.open = false,
    this.color = CdsColor.fg,
    this.font = CdsFont.headline,
    this.semanticHint,
  });

  /// The currently selected option's label.
  final String label;
  final VoidCallback? onPress;

  /// True while the caller's picker is showing.
  final bool open;
  final CdsColor color;
  final CdsFont font;

  /// Spoken after the label, e.g. 'Switch portfolio'.
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return CdsPressable(
      onPress: onPress,
      disabled: onPress == null,
      noScaleOnPress: true,
      minTapTargetSize: 44,
      semanticHint: semanticHint,
      child: Semantics(
        header: true,
        expanded: open,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.space(1),
          children: [
            Flexible(child: CdsText(label, font: font, color: color, maxLines: 1)),
            AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: CdsMotion.duration(context, CdsDurations.moderate1),
              curve: CdsCurves.global,
              child: CdsIcon(CdsIconName.caretDown, size: CdsIconSize.s, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
