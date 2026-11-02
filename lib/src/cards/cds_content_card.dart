import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_card_surface.dart';

/// Size limits from `@coinbase/cds-common/tokens/card`.
abstract final class CdsContentCardSizes {
  static const double minWidth = 280;
  static const double maxWidth = 800;
}

/// A composable card for feed content: stack a [CdsContentCardHeader],
/// [CdsContentCardBody] and [CdsContentCardFooter] inside it.
///
/// ```dart
/// CdsContentCard(
///   background: CdsColor.bgAlternate,
///   children: [
///     CdsContentCardHeader(title: 'Market update', subtitle: 'Sample data', thumbnail: CdsAvatar(name: 'Market')),
///     CdsContentCardBody(title: 'Bitcoin trading volume rose 12% this week', description: 'Sample data for the gallery.'),
///     CdsContentCardFooter(children: [CdsButton(label: 'Share', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: share)]),
///   ],
/// )
/// ```
///
/// Like CDS, the card has no background by default; set [background] or
/// [bordered] to separate it from the page.
class CdsContentCard extends StatelessWidget {
  const CdsContentCard({
    super.key,
    required this.children,
    this.padding = 2,
    this.gap = 2,
    this.borderRadius = 500,
    this.background,
    this.bordered = false,
    this.elevation = CdsElevation.none,
    this.minWidth = CdsContentCardSizes.minWidth,
    this.maxWidth = CdsContentCardSizes.maxWidth,
    this.onPress,
    this.feedback = CdsHapticFeedback.none,
    this.semanticLabel,
  }) : assert(onPress == null || semanticLabel != null,
            'A pressable CdsContentCard needs a semanticLabel describing what pressing opens.');

  final List<Widget> children;

  /// Space token around the content.
  final double padding;

  /// Space token between children.
  final double gap;

  /// Radius token.
  final int borderRadius;
  final CdsColor? background;
  final bool bordered;
  final CdsElevation elevation;
  final double minWidth;
  final double maxWidth;

  /// Makes the whole card a button. Buttons inside the card stay separately
  /// reachable.
  final VoidCallback? onPress;
  final CdsHapticFeedback feedback;

  /// Required with [onPress]: what the card opens, e.g. "Read Bitcoin article".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
      child: CdsCardSurface(
        onPress: onPress,
        background: background,
        bordered: bordered,
        elevation: elevation,
        borderRadius: borderRadius,
        feedback: feedback,
        semanticLabel: semanticLabel,
        child: Padding(
          padding: EdgeInsets.all(theme.space(padding)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.space(gap),
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Top row of a [CdsContentCard]: a thumbnail, a title and subtitle, and an
/// actions slot.
///
/// ```dart
/// CdsContentCardHeader(
///   thumbnail: CdsAvatar(name: 'Newsroom'),
///   title: 'Newsroom',
///   subtitle: 'News',
///   actions: CdsIconButton(CdsIconName.more, semanticLabel: 'More options', transparent: true, onPress: openMenu),
/// )
/// ```
class CdsContentCardHeader extends StatelessWidget {
  const CdsContentCardHeader({
    super.key,
    this.title,
    this.titleNode,
    this.subtitle,
    this.subtitleNode,
    this.thumbnail,
    this.actions,
  }) : assert(title != null || titleNode != null, 'CdsContentCardHeader needs a title or titleNode.');

  /// One line in `label1`.
  final String? title;
  final Widget? titleNode;

  /// One line in muted `legal`.
  final String? subtitle;
  final Widget? subtitleNode;

  /// An image, avatar or asset at the start.
  final Widget? thumbnail;

  /// Buttons at the end.
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return Row(
      spacing: theme.space(1.5),
      children: [
        Expanded(
          child: Row(
            spacing: theme.space(1.5),
            children: [
              ?thumbnail,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleNode ?? CdsText(title!, font: CdsFont.label1, maxLines: 1),
                    subtitleNode ??
                        (subtitle != null
                            ? CdsText(subtitle!, font: CdsFont.legal, color: CdsColor.fgMuted, maxLines: 1)
                            : null),
                  ].nonNulls.toList(),
                ),
              ),
            ],
          ),
        ),
        ?actions,
      ],
    );
  }
}

/// Where media sits relative to the text in a [CdsContentCardBody].
enum CdsContentCardMediaPlacement { top, bottom, start, end }

/// Main content of a [CdsContentCard]: a title, description and optional
/// media, with custom content below.
///
/// ```dart
/// CdsContentCardBody(
///   title: 'Staking rewards are now paid weekly',
///   description: 'Sample data for the gallery.',
///   media: CdsRemoteImage(source: art, width: double.infinity, aspectRatio: 16 / 9),
/// )
/// ```
///
/// Media at the start or end sits in a 96px square; at the top or bottom it
/// takes the full width. Both get 24px corners.
class CdsContentCardBody extends StatelessWidget {
  const CdsContentCardBody({
    super.key,
    this.title,
    this.titleNode,
    this.description,
    this.descriptionNode,
    this.media,
    this.mediaPlacement = CdsContentCardMediaPlacement.top,
    this.gap = 1,
    this.child,
  });

  /// Up to two lines in `headline`.
  final String? title;
  final Widget? titleNode;

  /// Up to three lines in muted `label2`.
  final String? description;

  /// Custom description; also the place for supplemental data such as a
  /// price and its change.
  final Widget? descriptionNode;
  final Widget? media;
  final CdsContentCardMediaPlacement mediaPlacement;

  /// Space token between the content and [child].
  final double gap;

  /// Custom content below the title, description and media.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final horizontal =
        mediaPlacement == CdsContentCardMediaPlacement.start || mediaPlacement == CdsContentCardMediaPlacement.end;
    final mediaFirst =
        mediaPlacement == CdsContentCardMediaPlacement.top || mediaPlacement == CdsContentCardMediaPlacement.start;
    final radius = BorderRadius.circular(theme.radius(500));

    final titleWidget = titleNode ?? (title != null ? CdsText(title!, font: CdsFont.headline, maxLines: 2) : null);
    final descriptionWidget = descriptionNode ??
        (description != null ? CdsText(description!, font: CdsFont.label2, color: CdsColor.fgMuted, maxLines: 3) : null);
    final hasText = titleWidget != null || descriptionWidget != null;
    final text = hasText
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: horizontal ? theme.space(1) : 0,
            children: [?titleWidget, ?descriptionWidget],
          )
        : null;

    Widget? mediaBox;
    if (media != null) {
      mediaBox = horizontal
          ? ClipRRect(borderRadius: radius, child: SizedBox.square(dimension: 96, child: media))
          : ClipRRect(borderRadius: radius, child: media);
    }

    Widget? content;
    if (mediaBox != null || text != null) {
      if (horizontal) {
        content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: theme.space(2),
          children: [
            if (mediaFirst) ?mediaBox,
            if (text != null) Expanded(child: text),
            if (!mediaFirst) ?mediaBox,
          ],
        );
      } else {
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.space(1),
          children: [
            if (mediaFirst) ?mediaBox,
            ?text,
            if (!mediaFirst) ?mediaBox,
          ],
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.space(gap),
      children: [?content, ?child],
    );
  }
}

/// Bottom row of a [CdsContentCard], spreading its children apart.
///
/// ```dart
/// CdsContentCardFooter(children: [likeCount, CdsButton(label: 'Share', size: CdsButtonSize.s, onPress: share)])
/// ```
class CdsContentCardFooter extends StatelessWidget {
  const CdsContentCardFooter({
    super.key,
    required this.children,
    this.justifyContent = MainAxisAlignment.spaceBetween,
    this.gap,
  });

  final List<Widget> children;
  final MainAxisAlignment justifyContent;

  /// Space token between children.
  final double? gap;

  @override
  Widget build(BuildContext context) {
    final spacing = gap == null ? 0.0 : context.cds.space(gap!);
    // Wraps onto a second line instead of overflowing at large text sizes.
    return Wrap(
      alignment: switch (justifyContent) {
        MainAxisAlignment.start => WrapAlignment.start,
        MainAxisAlignment.end => WrapAlignment.end,
        MainAxisAlignment.center => WrapAlignment.center,
        MainAxisAlignment.spaceBetween => WrapAlignment.spaceBetween,
        MainAxisAlignment.spaceAround => WrapAlignment.spaceAround,
        MainAxisAlignment.spaceEvenly => WrapAlignment.spaceEvenly,
      },
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing,
      runSpacing: context.cds.space(1),
      children: children,
    );
  }
}
