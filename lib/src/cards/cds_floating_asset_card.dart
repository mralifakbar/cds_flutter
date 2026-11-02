import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';
import 'cds_card_surface.dart';
import 'cds_contained_asset_card.dart';

/// An asset card whose media floats in its own bordered tile, with the text
/// underneath on the page background.
///
/// ```dart
/// CdsFloatingAssetCard(
///   media: CdsRemoteImage(source: art, width: double.infinity, height: double.infinity, shape: CdsShape.rectangle),
///   subtitle: 'Collection',
///   title: 'Genesis drop',
///   description: 'Sample data',
///   onPress: openCollection,
/// )
/// ```
///
/// The media tile is 156px tall; the card is up to 156px wide, or 359px in
/// the large size. CDS deprecates this card in favour of [CdsMediaCard].
class CdsFloatingAssetCard extends StatelessWidget {
  const CdsFloatingAssetCard({
    super.key,
    required this.media,
    this.title,
    this.titleNode,
    this.subtitle,
    this.subtitleNode,
    this.description,
    this.descriptionNode,
    this.size = CdsAssetCardSize.s,
    this.onPress,
    this.semanticLabel,
  }) : assert(title != null || titleNode != null, 'CdsFloatingAssetCard needs a title or titleNode.');

  /// Fills the 156px tall media tile.
  final Widget media;

  /// Up to three lines in `headline`.
  final String? title;
  final Widget? titleNode;

  /// One muted `legal` line above the title.
  final String? subtitle;
  final Widget? subtitleNode;

  /// Up to two muted `label2` lines.
  final String? description;
  final Widget? descriptionNode;
  final CdsAssetCardSize size;
  final VoidCallback? onPress;

  /// Defaults to the subtitle, title and description.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final pressable = onPress != null;
    final width = size == CdsAssetCardSize.l ? CdsAssetCardSizes.floatingLargeWidth : CdsAssetCardSizes.floatingSmall;
    final radius = BorderRadius.circular(theme.radius(500));

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.space(1),
      children: [
        Container(
          height: CdsAssetCardSizes.floatingSmall,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)),
          ),
          child: ClipRRect(borderRadius: radius, child: media),
        ),
        cdsCardText(
          pressable,
          cdsAssetCardText(
            subtitle: subtitle,
            subtitleNode: subtitleNode,
            title: title,
            titleNode: titleNode,
            description: description,
            descriptionNode: descriptionNode,
            titleLines: 3,
            descriptionLines: 2,
            gap: theme.space(0.5),
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: CdsAssetCardSizes.floatingSmall, maxWidth: width),
      child: CdsCardSurface(
        onPress: onPress,
        semanticLabel: semanticLabel ?? (pressable ? cdsCardLabel([subtitle, title, description]) : null),
        child: body,
      ),
    );
  }
}
