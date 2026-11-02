import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../layout/cds_box.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// A content block with a pictogram, large title, description, a free-form
/// primary area and an action, for feature promos and summaries.
///
/// ```dart
/// CdsMultiContentModule(
///   title: 'Earn on your crypto',
///   description: 'Stake eligible assets and receive rewards.',
///   action: 'Start staking',
///   onActionPress: openStaking,
///   child: rewardsSummary,
/// )
/// ```
class CdsMultiContentModule extends StatelessWidget {
  const CdsMultiContentModule({
    super.key,
    required this.title,
    this.pictogram,
    this.description,
    this.child,
    this.action,
    this.onActionPress,
    this.actionAccessibilityLabel,
    this.end,
    this.bordered = false,
  });

  /// Illustration slot above the title (CDS uses a 48x48 pictogram).
  final Widget? pictogram;

  /// Shown in `title1` and announced as a heading.
  final String title;

  /// Up to three lines in `body`, muted.
  final String? description;

  /// Primary content between the description and the action.
  final Widget? child;

  /// Label of a primary [CdsButton] below the content.
  final String? action;
  final VoidCallback? onActionPress;
  final String? actionAccessibilityLabel;

  /// Content below the action, such as legal text.
  final Widget? end;

  /// Adds a 1px `bgLine` border.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return CdsBox(
      borderRadius: 400,
      bordered: bordered,
      paddingY: 4,
      paddingX: bordered ? 3 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: theme.space(2),
        children: [
          ?pictogram,
          Semantics(header: true, child: CdsText(title, font: CdsFont.title1)),
          if (description != null)
            CdsText(description!, color: CdsColor.fgMuted, maxLines: 3),
          ?child,
          if (action != null)
            CdsButton(
              label: action!,
              onPress: onActionPress,
              semanticLabel: actionAccessibilityLabel,
            ),
          ?end,
        ],
      ),
    );
  }
}
