import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_card_surface.dart';

/// Orientation of a [CdsDataCard].
enum CdsDataCardLayout {
  /// Header and visualization side by side.
  horizontal,

  /// Header above the visualization.
  vertical,
}

/// A card pairing a title with a data visualization such as a progress bar
/// or progress circle.
///
/// ```dart
/// CdsDataCard(
///   title: 'Savings goal',
///   subtitle: r'$450 of $1,000',
///   thumbnail: CdsCellMedia.icon(CdsIconName.wallet),
///   child: CdsProgressCircle(progress: 0.45, size: 48),
/// )
/// ```
///
/// This follows the current CDS `DataCard` (`@coinbase/cds-mobile/alpha/data-card`).
/// The visualization is a widget slot, so any progress or chart widget fits.
class CdsDataCard extends StatelessWidget {
  const CdsDataCard({
    super.key,
    this.title,
    this.titleNode,
    this.subtitle,
    this.subtitleNode,
    this.titleAccessory,
    this.thumbnail,
    this.layout = CdsDataCardLayout.vertical,
    this.child,
    this.background = CdsColor.bgAlternate,
    this.onPress,
    this.feedback = CdsHapticFeedback.none,
    this.semanticLabel,
  }) : assert(title != null || titleNode != null, 'CdsDataCard needs a title or titleNode.');

  /// Up to two lines in `headline`.
  final String? title;
  final Widget? titleNode;

  /// One muted `label2` line above the title.
  final String? subtitle;
  final Widget? subtitleNode;

  /// Shown right after the title, e.g. a [CdsTag] or trend icon.
  final Widget? titleAccessory;

  /// Image or icon in the header.
  final Widget? thumbnail;
  final CdsDataCardLayout layout;

  /// The visualization.
  final Widget? child;
  final CdsColor background;
  final VoidCallback? onPress;
  final CdsHapticFeedback feedback;

  /// Defaults to the subtitle and title.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final horizontal = layout == CdsDataCardLayout.horizontal;
    final pressable = onPress != null;

    final text = cdsCardText(
      pressable,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          subtitleNode ??
              (subtitle != null ? CdsText(subtitle!, font: CdsFont.label2, color: CdsColor.fgMuted, maxLines: 1) : null),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: theme.space(0.5),
            children: [
              titleNode ?? CdsText(title!, font: CdsFont.headline, maxLines: 2),
              ?titleAccessory,
            ],
          ),
        ].nonNulls.toList(),
      ),
    );

    final header = horizontal
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.space(2),
            children: [?thumbnail, text],
          )
        : Row(
            spacing: theme.space(1.5),
            children: [?thumbnail, Expanded(child: text)],
          );

    final body = horizontal
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: theme.space(2),
            children: [Expanded(child: header), ?child],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.space(1),
            children: [header, ?child],
          );

    return CdsCardSurface(
      onPress: onPress,
      background: background,
      feedback: feedback,
      semanticLabel: semanticLabel ?? (pressable ? cdsCardLabel([subtitle, title]) : null),
      child: Padding(padding: EdgeInsets.all(theme.space(2)), child: body),
    );
  }
}
