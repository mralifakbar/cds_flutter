import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_card_surface.dart';

/// Size of an asset card.
enum CdsAssetCardSize { s, l }

/// Size tokens from `@coinbase/cds-common/tokens/card`.
abstract final class CdsAssetCardSizes {
  static const double containedLargeWidth = 359;
  static const double containedSmall = 156;
  static const double containedLarge = 327;
  static const double floatingLargeWidth = 359;
  static const double floatingSmall = 156;
}

/// Subtitle, title and description stack shared by the asset cards.
Widget cdsAssetCardText({
  required String? subtitle,
  required Widget? subtitleNode,
  required String? title,
  required Widget? titleNode,
  required String? description,
  required Widget? descriptionNode,
  required int titleLines,
  required int descriptionLines,
  required double gap,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: gap,
    children: [
      subtitleNode ??
          (subtitle != null ? CdsText(subtitle, font: CdsFont.legal, color: CdsColor.fgMuted, maxLines: 1) : null),
      titleNode ?? (title != null ? CdsText(title, font: CdsFont.headline, maxLines: titleLines) : null),
      descriptionNode ??
          (description != null
              ? CdsText(description, font: CdsFont.label2, color: CdsColor.fgMuted, maxLines: descriptionLines)
              : null),
    ].nonNulls.toList(),
  );
}

/// A compact asset tile: a header (usually the asset's logo) over a
/// subtitle, title and description, with extra content in the large size.
///
/// ```dart
/// CdsContainedAssetCard(
///   header: CdsRemoteImage(source: btcLogo, size: CdsAvatarSize.xl, shape: CdsShape.circle),
///   subtitle: 'BTC',
///   title: r'$64,201.10',
///   description: '+2.4% today',
///   onPress: () => openAsset('BTC'),
/// )
/// ```
///
/// The small size is a 156px square; the large size is 327 to 359px wide
/// with [child] filling the end half. CDS deprecates this card in favour of
/// [CdsMediaCard].
class CdsContainedAssetCard extends StatelessWidget {
  const CdsContainedAssetCard({
    super.key,
    required this.header,
    this.title,
    this.titleNode,
    this.subtitle,
    this.subtitleNode,
    this.description,
    this.descriptionNode,
    this.size = CdsAssetCardSize.s,
    this.child,
    this.minWidth,
    this.maxWidth,
    this.onPress,
    this.semanticLabel,
  }) : assert(title != null || titleNode != null, 'CdsContainedAssetCard needs a title or titleNode.');

  final Widget header;

  /// One line in `headline`.
  final String? title;
  final Widget? titleNode;

  /// One muted `legal` line above the title.
  final String? subtitle;
  final Widget? subtitleNode;

  /// One muted `label2` line.
  final String? description;
  final Widget? descriptionNode;
  final CdsAssetCardSize size;

  /// Content for the end half of the large size.
  final Widget? child;
  final double? minWidth;
  final double? maxWidth;
  final VoidCallback? onPress;

  /// Defaults to the subtitle, title and description.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final large = size == CdsAssetCardSize.l;
    final pressable = onPress != null;
    final max = maxWidth ?? (large ? CdsAssetCardSizes.containedLargeWidth : CdsAssetCardSizes.containedSmall);
    final min = minWidth ?? (large ? CdsAssetCardSizes.containedLarge : CdsAssetCardSizes.containedSmall);

    final info = Padding(
      padding: EdgeInsets.all(theme.space(2)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.space(1),
        children: [
          header,
          cdsCardText(
            pressable,
            cdsAssetCardText(
              subtitle: subtitle,
              subtitleNode: subtitleNode,
              title: title,
              titleNode: titleNode,
              description: description,
              descriptionNode: descriptionNode,
              titleLines: 1,
              descriptionLines: 1,
              gap: theme.space(0.5),
            ),
          ),
        ],
      ),
    );

    // A minimum rather than fixed height, so large text grows the card
    // instead of clipping it. IntrinsicHeight lets the header and text spread
    // apart inside that minimum.
    final sized = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: CdsAssetCardSizes.containedSmall),
      child: IntrinsicHeight(child: info),
    );
    final body = large ? cdsMediaSplit(content: sized, media: child ?? const SizedBox.shrink(), mediaFirst: false) : sized;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: min, maxWidth: max),
      child: CdsCardSurface(
        onPress: onPress,
        background: CdsColor.bgAlternate,
        semanticLabel: semanticLabel ?? (pressable ? cdsCardLabel([subtitle, title, description]) : null),
        child: body,
      ),
    );
  }
}
