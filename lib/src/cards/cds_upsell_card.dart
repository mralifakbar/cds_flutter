import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../buttons/cds_button_variant.dart';
import '../buttons/cds_icon_button.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_card_surface.dart';

/// Size tokens from `@coinbase/cds-common/tokens/card`.
abstract final class CdsUpsellCardSizes {
  static const double minHeight = 158;
  static const double width = 327;
}

/// A promotional card with a title, description, a button and media
/// anchored to the end edge.
///
/// ```dart
/// CdsUpsellCard(
///   title: 'Earn rewards on USDC',
///   description: 'Sample data. Rates vary.',
///   action: 'Start earning',
///   onActionPress: openEarn,
///   onDismissPress: dismiss,
///   media: CdsRemoteImage(source: art, width: 120, height: 158, shape: CdsShape.rectangle),
/// )
/// ```
///
/// CDS deprecates UpsellCard in favour of [CdsMessagingCard] with
/// `type: upsell`; prefer that for new screens.
class CdsUpsellCard extends StatelessWidget {
  const CdsUpsellCard({
    super.key,
    this.title,
    this.titleNode,
    this.description,
    this.descriptionNode,
    this.action,
    this.actionNode,
    this.onActionPress,
    this.onDismissPress,
    this.onPress,
    this.media,
    this.background = CdsColor.bgPrimaryWash,
    this.dangerouslySetBackground,
    this.width = CdsUpsellCardSizes.width,
    this.semanticLabel,
  }) : assert(title != null || titleNode != null, 'CdsUpsellCard needs a title or titleNode.');

  /// `headline` text.
  final String? title;
  final Widget? titleNode;

  /// Up to three lines of `label2`.
  final String? description;
  final Widget? descriptionNode;

  /// Label of the default small secondary button.
  final String? action;

  /// Custom call to action; takes precedence over [action].
  final Widget? actionNode;
  final VoidCallback? onActionPress;

  /// Shows a close button in the top end corner.
  final VoidCallback? onDismissPress;
  final VoidCallback? onPress;

  /// Anchored to the end edge, vertically centered, behind the text column.
  final Widget? media;
  final CdsColor background;
  final Color? dangerouslySetBackground;

  /// Defaults to 327. Pass null to fill the parent.
  final double? width;

  /// Label for the dismiss button, defaults to "Dismiss the [title] card".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final pressable = onPress != null;

    final actionWidget = actionNode ??
        (action != null
            ? Padding(
                padding: EdgeInsetsDirectional.only(start: theme.space(2)),
                child: CdsButton(
                  label: action!,
                  size: CdsButtonSize.s,
                  variant: CdsButtonVariant.secondary,
                  flush: CdsFlush.start,
                  onPress: onActionPress,
                ),
              )
            : null);

    final textColumn = FractionallySizedBox(
      widthFactor: 0.7,
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: CdsUpsellCardSizes.minHeight),
        child: Padding(
          padding: EdgeInsets.all(theme.space(2)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.space(3),
            children: [
              cdsCardText(
                pressable,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: theme.space(1),
                  children: [
                    titleNode ?? CdsText(title!, font: CdsFont.headline),
                    descriptionNode ??
                        (description != null ? CdsText(description!, font: CdsFont.label2, maxLines: 3) : null),
                  ].nonNulls.toList(),
                ),
              ),
              ?actionWidget,
            ],
          ),
        ),
      ),
    );

    final card = CdsCardSurface(
      onPress: onPress,
      background: background,
      dangerouslySetBackground: dangerouslySetBackground,
      semanticLabel: pressable ? cdsCardLabel([title, description]) : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: CdsUpsellCardSizes.minHeight),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (media != null)
              PositionedDirectional(
                top: 0,
                bottom: 0,
                end: 0,
                child: Center(widthFactor: 1, child: media),
              ),
            textColumn,
            if (onDismissPress != null)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: Padding(
                  padding: EdgeInsets.all(theme.space(1)),
                  child: CdsIconButton(
                    CdsIconName.close,
                    semanticLabel: semanticLabel ?? 'Dismiss the ${title ?? ''} card'.replaceAll('  ', ' '),
                    variant: CdsButtonVariant.secondary,
                    onPress: onDismissPress,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return SizedBox(width: width ?? double.infinity, child: card);
  }
}
