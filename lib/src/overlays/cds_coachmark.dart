import 'package:flutter/widgets.dart';

import '../buttons/cds_icon_button.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_tooltip.dart';

/// A small card that introduces a feature, usually pointed at the feature by
/// a [CdsTour]. Rendered on the inverted color scheme so it stands out from
/// the page.
///
/// ```dart
/// CdsCoachmark(
///   title: 'Recurring buys',
///   content: 'Buy a fixed amount every week to smooth out price swings.',
///   action: CdsButton(label: 'Next', size: CdsButtonSize.s, onPress: next),
///   onClose: stopTour,
/// )
/// ```
class CdsCoachmark extends StatelessWidget {
  const CdsCoachmark({
    super.key,
    required this.title,
    required this.content,
    this.titleWidget,
    this.contentWidget,
    this.action,
    this.checkbox,
    this.media,
    this.onClose,
    this.width,
    this.closeButtonAccessibilityLabel = 'Close',
  });

  final String title;
  final String content;

  /// Custom title; overrides [title] visually.
  final Widget? titleWidget;

  /// Custom body; overrides [content] visually.
  final Widget? contentWidget;

  /// Usually a small [CdsButton] such as "Next".
  final Widget? action;

  /// Optional control at the start of the action row, for example a
  /// "Don't show again" checkbox.
  final Widget? checkbox;

  /// Image or illustration above the text, edge to edge.
  final Widget? media;

  /// Shows a close button in the top corner when set.
  final VoidCallback? onClose;

  /// Fixed width. Never wider than the screen minus 16px on each side.
  final double? width;
  final String closeButtonAccessibilityLabel;

  @override
  Widget build(BuildContext context) => CdsInvertedTheme(child: Builder(builder: _buildCard));

  Widget _buildCard(BuildContext context) {
    final theme = context.cds;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final paddingX = theme.space(2);

    Widget card = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?media,
        ColoredBox(
          color: theme.color.bg,
          child: Padding(
            padding: EdgeInsets.all(theme.space(2)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: theme.space(2),
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: theme.space(0.5),
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: onClose != null ? theme.space(4) : 0),
                      child: titleWidget ?? Semantics(container: true, header: true, child: CdsText(title, font: CdsFont.headline)),
                    ),
                    contentWidget ?? CdsText(content, font: CdsFont.body),
                  ],
                ),
                if (action != null || checkbox != null)
                  Row(
                    mainAxisAlignment: checkbox != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                    children: [?checkbox, ?action],
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    if (onClose != null) {
      card = Stack(
        children: [
          card,
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Padding(
              padding: EdgeInsets.all(theme.space(1)),
              child: CdsIconButton(
                CdsIconName.close,
                semanticLabel: closeButtonAccessibilityLabel,
                transparent: true,
                onPress: onClose,
              ),
            ),
          ),
        ],
      );
    }

    card = ClipRRect(borderRadius: BorderRadius.circular(theme.radius(400)), child: card);
    card = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenWidth - paddingX * 2),
      child: SizedBox(width: width, child: card),
    );
    return Semantics(container: true, child: card);
  }
}
