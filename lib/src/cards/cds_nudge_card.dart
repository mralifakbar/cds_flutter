import 'package:flutter/widgets.dart';

import '../buttons/cds_button_variant.dart';
import '../buttons/cds_icon_button.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_card_surface.dart';
import 'cds_messaging_card.dart';

/// Which side of the text the media sits on in a [CdsNudgeCard].
enum CdsNudgeCardMediaPosition { left, right }

/// A soft prompt toward a next step, with optional media, a text call to
/// action and a dismiss button.
///
/// ```dart
/// CdsNudgeCard(
///   title: 'Add a backup',
///   description: 'Save your recovery phrase so you never lose access.',
///   action: 'Back up now',
///   onActionPress: startBackup,
///   onDismissPress: dismiss,
///   media: CdsIcon(CdsIconName.shield, size: CdsIconSize.l),
/// )
/// ```
///
/// CDS deprecates NudgeCard in favour of [CdsMessagingCard] with
/// `type: nudge`; prefer that for new screens. Pictogram names are not
/// supported because pictograms are not bundled; pass artwork as [media].
class CdsNudgeCard extends StatelessWidget {
  const CdsNudgeCard({
    super.key,
    this.title,
    this.titleNode,
    this.description,
    this.descriptionNode,
    this.media,
    this.mediaPosition = CdsNudgeCardMediaPosition.right,
    this.action,
    this.actionNode,
    this.onActionPress,
    this.onDismissPress,
    this.onPress,
    this.maxLines = 3,
    this.width,
    this.minHeight,
    this.background = CdsColor.bgAlternate,
    this.semanticLabel,
  });

  /// `headline` text.
  final String? title;
  final Widget? titleNode;

  /// `label2` text.
  final String? description;
  final Widget? descriptionNode;
  final Widget? media;
  final CdsNudgeCardMediaPosition mediaPosition;

  /// Label of the default text call to action.
  final String? action;

  /// Custom call to action; takes precedence over [action].
  final Widget? actionNode;
  final VoidCallback? onActionPress;

  /// Shows a transparent close button in the top end corner.
  final VoidCallback? onDismissPress;
  final VoidCallback? onPress;

  /// Line limit for both the title and description (CDS `numberOfLines`).
  final int maxLines;

  /// Defaults to the parent's width.
  final double? width;
  final double? minHeight;
  final CdsColor background;

  /// Label for the dismiss button, defaults to "Dismiss the [title] card".
  /// When the card is pressable, its own label is the title and description.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final pressable = onPress != null;
    final hasMedia = media != null;
    final hasAction = action != null || actionNode != null;

    final text = cdsCardText(
      pressable,
      Padding(
        padding: EdgeInsets.only(top: hasMedia ? 0 : theme.space(2)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: theme.space(0.5),
          children: [
            titleNode ?? (title != null ? CdsText(title!, font: CdsFont.headline, maxLines: maxLines) : null),
            descriptionNode ??
                (description != null ? CdsText(description!, font: CdsFont.label2, maxLines: maxLines) : null),
          ].nonNulls.toList(),
        ),
      ),
    );

    final actionWidget = actionNode ?? (action != null ? cdsTextAction(theme, action!, onActionPress, null) : null);
    final body = Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.space(2),
        children: [text, ?actionWidget],
      ),
    );

    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          theme.space(2),
          theme.space(2),
          theme.space(2),
          theme.space(hasAction ? 1 : 2),
        ),
        child: Row(
          spacing: theme.space(2),
          children: [
            if (mediaPosition == CdsNudgeCardMediaPosition.left) ?media,
            body,
            if (mediaPosition == CdsNudgeCardMediaPosition.right) ?media,
          ],
        ),
      ),
    );

    final card = CdsCardSurface(
      onPress: onPress,
      background: background,
      semanticLabel: pressable ? cdsCardLabel([title, description]) : null,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: onDismissPress != null ? theme.space(3) : 0),
            child: row,
          ),
          if (onDismissPress != null)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Padding(
                padding: EdgeInsets.all(theme.space(0.5)),
                child: CdsIconButton(
                  CdsIconName.close,
                  semanticLabel: semanticLabel ?? 'Dismiss the ${title ?? ''} card'.replaceAll('  ', ' '),
                  variant: CdsButtonVariant.secondary,
                  transparent: true,
                  onPress: onDismissPress,
                ),
              ),
            ),
        ],
      ),
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }
}
