import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_card_surface.dart';

/// Which half of a [CdsMediaCard] holds the media.
enum CdsMediaCardMediaPlacement { start, end }

/// A card split into a text half with a thumbnail and a media half.
///
/// ```dart
/// CdsMediaCard(
///   thumbnail: CdsAvatar(name: 'Ethereum', size: CdsAvatarSize.l),
///   subtitle: 'ETH',
///   title: 'Ethereum',
///   description: 'Sample data',
///   media: CdsRemoteImage(source: art, width: double.infinity, height: double.infinity, shape: CdsShape.rectangle),
///   onPress: () => openAsset('ETH'),
/// )
/// ```
///
/// Without [media], the text half fills the card. This is the CDS
/// replacement for [CdsContainedAssetCard] and [CdsFloatingAssetCard].
class CdsMediaCard extends StatelessWidget {
  const CdsMediaCard({
    super.key,
    required this.thumbnail,
    this.title,
    this.titleNode,
    this.subtitle,
    this.subtitleNode,
    this.description,
    this.descriptionNode,
    this.media,
    this.mediaPlacement = CdsMediaCardMediaPlacement.end,
    this.background = CdsColor.bgAlternate,
    this.onPress,
    this.feedback = CdsHapticFeedback.none,
    this.semanticLabel,
  });

  /// Image, avatar or icon at the top of the text half.
  final Widget thumbnail;

  /// Up to two lines in `headline`.
  final String? title;
  final Widget? titleNode;

  /// One muted `legal` line above the title.
  final String? subtitle;
  final Widget? subtitleNode;

  /// Up to two muted `label2` lines.
  final String? description;
  final Widget? descriptionNode;

  /// Fills its half of the card at full height.
  final Widget? media;
  final CdsMediaCardMediaPlacement mediaPlacement;
  final CdsColor background;
  final VoidCallback? onPress;
  final CdsHapticFeedback feedback;

  /// Defaults to the subtitle, title and description.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final pressable = onPress != null;

    final text = cdsCardText(
      pressable,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          subtitleNode ??
              (subtitle != null ? CdsText(subtitle!, font: CdsFont.legal, color: CdsColor.fgMuted, maxLines: 1) : null),
          titleNode ?? (title != null ? CdsText(title!, font: CdsFont.headline, maxLines: 2) : null),
          descriptionNode ??
              (description != null
                  ? CdsText(description!, font: CdsFont.label2, color: CdsColor.fgMuted, maxLines: 2)
                  : null),
        ].nonNulls.toList(),
      ),
    );

    final content = Padding(
      padding: EdgeInsets.all(theme.space(2)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.space(4),
        children: [thumbnail, text],
      ),
    );

    final Widget body = media == null
        ? content
        : cdsMediaSplit(content: content, media: media!, mediaFirst: mediaPlacement == CdsMediaCardMediaPlacement.start);

    return CdsCardSurface(
      onPress: onPress,
      background: background,
      feedback: feedback,
      semanticLabel: semanticLabel ?? (pressable ? cdsCardLabel([subtitle, title, description]) : null),
      child: body,
    );
  }
}
