import 'package:flutter/widgets.dart';

import '../media/cds_cell_media.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import 'cds_cell.dart';
import 'cds_list_cell.dart';

/// Width multipliers CDS cycles through for placeholder bars
/// (`WIDTH_MODIFIERS` in `useFallbackShape`).
const List<double> _widthModifiers = [0.5, 0, 0.6, 0.8, 0.1, 0.9, 0.4, 0.2, 0.7, 0.3];

/// Width of a placeholder bar for [baseWidth], varied by [variant] the way
/// CDS does: within a quarter of the base width either side.
double cdsFallbackWidth(double baseWidth, int? variant) {
  if (variant == null) return baseWidth;
  final modifier = _widthModifiers[variant % _widthModifiers.length];
  final quarter = (baseWidth / 4).roundToDouble();
  final min = (baseWidth - quarter).clamp(1.0, double.infinity);
  final max = baseWidth + quarter;
  return (modifier * (max - min + 1)).floorToDouble() + min;
}

/// A static loading placeholder block. Internal to cds_flutter.
///
/// CDS sweeps a shimmer across fallbacks; this package keeps them still so
/// nothing animates without a user action, per the motion contract.
class CdsFallbackBlock extends StatelessWidget {
  const CdsFallbackBlock({super.key, required this.width, required this.height, this.radius = 0, this.circle = false});

  final double width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // CDS fallback highlight: the muted foreground at 10% opacity.
          color: theme.color.fgMuted.withValues(alpha: 0.1),
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// A placeholder bar one line of [font] tall, scaled with the text size.
class CdsTextFallback extends StatelessWidget {
  const CdsTextFallback({super.key, required this.font, required this.width, this.rectWidthVariant});

  final CdsFont font;
  final double width;
  final int? rectWidthVariant;

  @override
  Widget build(BuildContext context) {
    final lineHeight = MediaQuery.textScalerOf(context).scale(context.cds.typography[font].lineHeight);
    final barHeight = lineHeight * 0.75;
    return SizedBox(
      height: lineHeight,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: 1,
        child: CdsFallbackBlock(width: cdsFallbackWidth(width, rectWidthVariant), height: barHeight, radius: 2),
      ),
    );
  }
}

/// Placeholder for cell media while it loads: a 48px squircle for images
/// and a 32px circle for everything else.
///
/// ```dart
/// const CdsMediaFallback(CdsCellMediaType.asset)
/// ```
class CdsMediaFallback extends StatelessWidget {
  const CdsMediaFallback(this.type, {super.key});

  final CdsCellMediaType type;

  @override
  Widget build(BuildContext context) {
    if (type == CdsCellMediaType.image) {
      return CdsFallbackBlock(
        width: CdsCellMediaSizes.image,
        height: CdsCellMediaSizes.image,
        radius: context.cds.radius(200),
      );
    }
    return const CdsFallbackBlock(width: CdsCellMediaSizes.media, height: CdsCellMediaSizes.media, circle: true);
  }
}

/// A loading placeholder shaped like a [CdsListCell]. Turn on the pieces
/// the loaded cell will have so the layout does not jump.
///
/// ```dart
/// for (var i = 0; i < 4; i++)
///   CdsListCellFallback(title: true, description: true, detail: true, media: CdsCellMediaType.asset, rectWidthVariant: i)
/// ```
///
/// Screen readers hear [semanticLabel] ("Loading" by default) once per
/// placeholder; the bars themselves are hidden.
class CdsListCellFallback extends StatelessWidget {
  const CdsListCellFallback({
    super.key,
    this.title = false,
    this.subtitle = false,
    this.description = false,
    this.detail = false,
    this.subdetail = false,
    this.helperText = false,
    this.media,
    this.accessory,
    this.accessoryNode,
    this.spacingVariant = CdsCellSpacingVariant.normal,
    this.rectWidthVariant,
    this.innerSpacing,
    this.outerSpacing,
    this.semanticLabel = 'Loading',
  });

  final bool title;
  final bool subtitle;
  final bool description;
  final bool detail;
  final bool subdetail;
  final bool helperText;

  /// Shape of the media placeholder; null for none.
  final CdsCellMediaType? media;
  final CdsCellAccessoryType? accessory;
  final Widget? accessoryNode;
  final CdsCellSpacingVariant spacingVariant;

  /// Varies bar widths deterministically. Pass the row index so a list of
  /// placeholders does not look uniform.
  final int? rectWidthVariant;
  final CdsCellSpacing? innerSpacing;
  final CdsCellSpacing? outerSpacing;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final condensed = spacingVariant == CdsCellSpacingVariant.condensed;
    int? v(int increment) => rectWidthVariant == null ? null : rectWidthVariant! + increment;

    final textStack = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title) CdsTextFallback(font: CdsFont.headline, width: 90, rectWidthVariant: v(3)),
        if (subtitle) CdsTextFallback(font: CdsFont.label1, width: 80, rectWidthVariant: v(2)),
        if (description)
          CdsTextFallback(font: condensed ? CdsFont.label2 : CdsFont.body, width: 110, rectWidthVariant: v(0)),
      ],
    );
    final detailStack = (detail || subdetail)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (detail) CdsTextFallback(font: CdsFont.body, width: 60, rectWidthVariant: v(1)),
              if (subdetail)
                CdsTextFallback(font: condensed ? CdsFont.label2 : CdsFont.body, width: 60, rectWidthVariant: v(1)),
            ],
          )
        : null;

    final cell = CdsCell(
      media: media == null ? null : CdsMediaFallback(media!),
      end: detailStack,
      accessory: accessoryNode ?? (accessory == null ? null : CdsCellAccessory(accessory!)),
      bottomContent: helperText ? CdsTextFallback(font: CdsFont.body, width: 220, rectWidthVariant: v(4)) : null,
      borderRadius: condensed ? 0 : 200,
      minHeight: switch (spacingVariant) {
        CdsCellSpacingVariant.normal => CdsListCellHeights.normal,
        CdsCellSpacingVariant.compact => CdsListCellHeights.compact,
        CdsCellSpacingVariant.condensed => null,
      },
      innerSpacing: innerSpacing ?? (condensed ? CdsCellSpacing.condensedInner : null),
      outerSpacing: outerSpacing ?? (condensed ? CdsCellSpacing.condensedOuter : null),
      child: textStack,
    );

    return Semantics(
      label: semanticLabel,
      container: true,
      child: ExcludeSemantics(child: cell),
    );
  }
}
