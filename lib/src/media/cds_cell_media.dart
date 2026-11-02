import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_tokens.dart';
import 'cds_remote_image.dart';
import 'cds_shape.dart';

/// Kind of media shown at the start of a cell.
enum CdsCellMediaType { asset, avatar, image, icon, pictogram }

/// Size tokens from `@coinbase/cds-common/tokens/cell`.
abstract final class CdsCellMediaSizes {
  /// Box for icons, assets and avatars.
  static const double media = 32;

  /// Box for images and pictograms.
  static const double image = 48;
}

/// Media sized and shaped for the start slot of a list cell.
///
/// ```dart
/// CdsListCell(title: 'Bitcoin', media: CdsCellMedia.asset(source: btcLogo))
/// CdsListCell(title: 'Security', media: CdsCellMedia.icon(CdsIconName.shield))
/// CdsListCell(title: 'Gift card', media: CdsCellMedia.image(source: cardArt))
/// ```
///
/// Icons, assets and avatars sit in a 32px box; images and pictograms in a
/// 48px box. Assets and avatars are circles with dark mode enhancements;
/// images are squircles that fit inside their box.
class CdsCellMedia extends StatelessWidget {
  /// A 16px icon centered in a 32px box.
  const CdsCellMedia.icon(
    CdsIconName this.name, {
    super.key,
    this.active = false,
    this.color = CdsColor.fg,
    this.semanticLabel,
  })  : type = CdsCellMediaType.icon,
        source = null,
        illustration = null;

  /// A circular crypto or brand asset image.
  const CdsCellMedia.asset({super.key, required ImageProvider this.source, this.semanticLabel})
      : type = CdsCellMediaType.asset,
        name = null,
        active = false,
        color = CdsColor.fg,
        illustration = null;

  /// A circular person or entity image.
  const CdsCellMedia.avatar({super.key, required ImageProvider this.source, this.semanticLabel})
      : type = CdsCellMediaType.avatar,
        name = null,
        active = false,
        color = CdsColor.fg,
        illustration = null;

  /// A 48px squircle image, scaled to fit.
  const CdsCellMedia.image({super.key, required ImageProvider this.source, this.semanticLabel})
      : type = CdsCellMediaType.image,
        name = null,
        active = false,
        color = CdsColor.fg,
        illustration = null;

  /// A pictogram or other illustration in a 48px box. Pictograms are not
  /// bundled with this package; pass your own artwork.
  const CdsCellMedia.pictogram(Widget this.illustration, {super.key, this.semanticLabel})
      : type = CdsCellMediaType.pictogram,
        name = null,
        active = false,
        color = CdsColor.fg,
        source = null;

  final CdsCellMediaType type;
  final CdsIconName? name;

  /// Filled icon glyph.
  final bool active;
  final CdsColor color;
  final ImageProvider? source;
  final Widget? illustration;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    var box = CdsCellMediaSizes.media;
    final Widget content;
    switch (type) {
      case CdsCellMediaType.icon:
        content = CdsIcon(name!, size: CdsIconSize.s, active: active, color: color, semanticLabel: semanticLabel);
      case CdsCellMediaType.asset:
      case CdsCellMediaType.avatar:
        content = CdsRemoteImage(
          source: source,
          width: box,
          height: box,
          shape: CdsShape.circle,
          darkModeEnhancementsApplied: true,
          semanticLabel: semanticLabel,
        );
      case CdsCellMediaType.image:
        box = CdsCellMediaSizes.image;
        content = CdsRemoteImage(
          source: source,
          width: box,
          height: box,
          shape: CdsShape.squircle,
          fit: BoxFit.contain,
          semanticLabel: semanticLabel,
        );
      case CdsCellMediaType.pictogram:
        box = CdsCellMediaSizes.image;
        content = semanticLabel == null
            ? ExcludeSemantics(child: illustration)
            : Semantics(image: true, label: semanticLabel, child: ExcludeSemantics(child: illustration));
    }
    return SizedBox.square(dimension: box, child: Center(child: content));
  }
}
