import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../buttons/cds_button_variant.dart';
import '../buttons/cds_icon_button.dart';
import '../display/cds_tag.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_card_surface.dart';

/// Kind of [CdsMessagingCard]; sets the background and text colors.
enum CdsMessagingCardType {
  /// Promotes a product or feature on `bgPrimary` with inverse text.
  upsell,

  /// Suggests a next step on `bgAlternate`.
  nudge,
}

/// Which side of the text the media sits on.
enum CdsMessagingCardMediaPlacement { start, end }

/// A promotional or nudge card with a title, description, optional tag,
/// call to action, media and dismiss button.
///
/// ```dart
/// CdsMessagingCard(
///   type: CdsMessagingCardType.nudge,
///   title: 'Turn on price alerts',
///   description: 'Get notified when Bitcoin moves 5% in a day.',
///   action: 'Set up alerts',
///   onActionButtonPress: openAlerts,
///   onDismissButtonPress: dismiss,
///   media: CdsIcon(CdsIconName.bell, size: CdsIconSize.l),
/// )
/// ```
///
/// This is the CDS replacement for [CdsNudgeCard] and [CdsUpsellCard].
class CdsMessagingCard extends StatelessWidget {
  const CdsMessagingCard({
    super.key,
    required this.type,
    this.title,
    this.titleNode,
    this.description,
    this.descriptionNode,
    this.tag,
    this.tagNode,
    this.action,
    this.actionNode,
    this.onActionButtonPress,
    this.actionButtonSemanticLabel,
    this.onDismissButtonPress,
    this.dismissButton,
    this.dismissButtonSemanticLabel,
    this.media,
    this.mediaPlacement = CdsMessagingCardMediaPlacement.end,
    this.onPress,
    this.semanticLabel,
  });

  final CdsMessagingCardType type;

  /// Up to two lines in `headline`.
  final String? title;
  final Widget? titleNode;

  /// Up to three lines in `label2`.
  final String? description;
  final Widget? descriptionNode;

  /// Text shown in a [CdsTag] above the title.
  final String? tag;
  final Widget? tagNode;

  /// Label of the default call to action: a small secondary button on upsell
  /// cards, a primary-colored text button on nudge cards.
  final String? action;

  /// Custom call to action; takes precedence over [action].
  final Widget? actionNode;
  final VoidCallback? onActionButtonPress;

  /// Defaults to [action].
  final String? actionButtonSemanticLabel;

  /// Shows a close button in the top end corner.
  final VoidCallback? onDismissButtonPress;

  /// Custom dismiss control; replaces the default close button.
  final Widget? dismissButton;

  /// Defaults to "Dismiss [title]", or "Dismiss card" without a title.
  final String? dismissButtonSemanticLabel;
  final Widget? media;
  final CdsMessagingCardMediaPlacement mediaPlacement;

  /// Makes the whole card a button. The action and dismiss buttons stay
  /// separately reachable.
  final VoidCallback? onPress;

  /// Defaults to the tag, title and description.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final upsell = type == CdsMessagingCardType.upsell;
    final pressable = onPress != null;
    final textColor = upsell ? CdsColor.fgInverse : CdsColor.fg;
    final hasDismiss = dismissButton != null || onDismissButtonPress != null;
    final atStart = mediaPlacement == CdsMessagingCardMediaPlacement.start;

    final textBlock = cdsCardText(
      pressable,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.space(0.5),
        children: [
          tagNode ?? (tag != null ? CdsTag(tag!) : null),
          titleNode ?? (title != null ? CdsText(title!, font: CdsFont.headline, color: textColor, maxLines: 2) : null),
          descriptionNode ??
              (description != null ? CdsText(description!, font: CdsFont.label2, color: textColor, maxLines: 3) : null),
        ].nonNulls.toList(),
      ),
    );

    Widget? actionWidget = actionNode;
    if (actionWidget == null && action != null) {
      actionWidget = upsell
          ? CdsButton(
              label: action!,
              size: CdsButtonSize.s,
              variant: CdsButtonVariant.secondary,
              semanticLabel: actionButtonSemanticLabel,
              onPress: onActionButtonPress,
            )
          : cdsTextAction(theme, action!, onActionButtonPress, actionButtonSemanticLabel);
    }

    final content = Padding(
      padding: atStart && hasDismiss
          ? EdgeInsetsDirectional.fromSTEB(theme.space(2), theme.space(2), theme.space(6), theme.space(2))
          : EdgeInsets.all(theme.space(2)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.space(2),
        children: [textBlock, ?actionWidget],
      ),
    );

    Widget? mediaBox;
    if (media != null) {
      final EdgeInsetsDirectional pad = upsell
          ? EdgeInsetsDirectional.zero
          : atStart
              ? EdgeInsetsDirectional.only(start: theme.space(3), end: theme.space(1))
              : EdgeInsetsDirectional.only(start: theme.space(1), end: theme.space(hasDismiss ? 6 : 3));
      mediaBox = Padding(padding: pad, child: Center(widthFactor: 1, child: media));
    }

    final row = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (atStart) ?mediaBox,
          Expanded(child: content),
          if (!atStart) ?mediaBox,
        ],
      ),
    );

    final dismissLabel = dismissButtonSemanticLabel ?? (title != null ? 'Dismiss $title' : 'Dismiss card');
    final dismiss = dismissButton ??
        (onDismissButtonPress != null
            ? CdsIconButton(
                CdsIconName.close,
                semanticLabel: dismissLabel,
                variant: CdsButtonVariant.secondary,
                onPress: onDismissButtonPress,
              )
            : null);

    return CdsCardSurface(
      onPress: onPress,
      background: upsell ? CdsColor.bgPrimary : CdsColor.bgAlternate,
      semanticLabel: semanticLabel ?? (pressable ? cdsCardLabel([tag, title, description]) : null),
      child: Stack(
        children: [
          row,
          if (dismiss != null)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: theme.space(1), end: theme.space(1)),
                child: dismiss,
              ),
            ),
        ],
      ),
    );
  }
}

/// The primary-colored text call to action CDS uses on nudge cards.
Widget cdsTextAction(CdsThemeData theme, String label, VoidCallback? onPress, String? semanticLabel) {
  return CdsPressable(
    onPress: onPress,
    disabled: onPress == null,
    minTapTargetSize: 44,
    semanticLabel: semanticLabel,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: theme.space(1)),
      child: CdsText(label, font: CdsFont.headline, color: CdsColor.fgPrimary, maxLines: 1),
    ),
  );
}
