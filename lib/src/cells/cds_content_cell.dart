import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_cell.dart';
import 'cds_cell_layout.dart';
import 'cds_list_cell.dart';

/// A cell for longer content: a title with meta information beside it, a
/// subtitle, and a description that wraps freely.
///
/// ```dart
/// CdsContentCell(
///   media: CdsCellMedia.icon(CdsIconName.bell),
///   title: 'Price alert',
///   meta: '2m ago',
///   description: 'Bitcoin rose above your alert price.',
///   onPress: openAlert,
/// )
/// ```
///
/// CDS marks ContentCell as deprecated in favour of ListCell. It remains
/// useful when the description must wrap without a line limit.
class CdsContentCell extends StatelessWidget {
  const CdsContentCell({
    super.key,
    this.title,
    this.titleNode,
    this.subtitle,
    this.subtitleNode,
    this.description,
    this.descriptionNode,
    this.meta,
    this.metaNode,
    this.media,
    this.accessory,
    this.accessoryNode,
    this.spacingVariant = CdsCellSpacingVariant.normal,
    this.priority = const {},
    this.selected = false,
    this.disabled = false,
    this.onPress,
    this.onLongPress,
    this.alignItems = CrossAxisAlignment.start,
    this.background = CdsColor.bgAlternate,
    this.borderRadius,
    this.innerSpacing,
    this.outerSpacing,
    this.feedback = CdsHapticFeedback.none,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
  });

  final String? title;
  final Widget? titleNode;

  /// `label2`, or `label1` in the condensed variant.
  final String? subtitle;
  final Widget? subtitleNode;

  /// Wraps without a line limit.
  final String? description;
  final Widget? descriptionNode;

  /// Short text at the end of the title line, e.g. a timestamp. Needs a
  /// title or subtitle.
  final String? meta;
  final Widget? metaNode;
  final Widget? media;
  final CdsCellAccessoryType? accessory;
  final Widget? accessoryNode;
  final CdsCellSpacingVariant spacingVariant;
  final Set<CdsCellPriority> priority;
  final bool selected;
  final bool disabled;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;
  final CrossAxisAlignment alignItems;
  final CdsColor background;
  final int? borderRadius;
  final CdsCellSpacing? innerSpacing;
  final CdsCellSpacing? outerSpacing;
  final CdsHapticFeedback feedback;

  /// Defaults to the content text. Pass a shorter label for long cells.
  final String? semanticLabel;
  final String? semanticHint;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final condensed = spacingVariant == CdsCellSpacingVariant.condensed;
    final hasTitle = title != null || titleNode != null;
    final hasSubtitle = subtitle != null || subtitleNode != null;
    final hasDescription = description != null || descriptionNode != null;
    final hasMeta = meta != null || metaNode != null;
    assert(!hasMeta || hasTitle || hasSubtitle, 'CdsContentCell: `meta` needs a `title` or `subtitle`.');
    final accessoryType = selected ? CdsCellAccessoryType.selected : accessory;

    final metaWidget = hasMeta
        ? Padding(
            padding: EdgeInsetsDirectional.only(start: theme.space(1), top: theme.space(0.5)),
            child: metaNode ?? CdsText(meta!, font: CdsFont.label2, color: CdsColor.fgMuted),
          )
        : null;
    final accessoryWidget = accessoryType == null
        ? null
        : Padding(padding: EdgeInsets.only(top: theme.space(0.5)), child: CdsCellAccessory(accessoryType));

    Widget? trailing = accessoryNode ?? accessoryWidget;
    if (condensed && metaWidget != null) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.space(2),
        children: [metaWidget, ?accessoryWidget],
      );
    }

    final titles = (hasTitle || hasSubtitle)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleNode ??
                        (title != null
                            ? CdsText(title!,
                                font: CdsFont.headline, maxLines: condensed ? 2 : (hasDescription ? 1 : 2))
                            : null),
                    subtitleNode ??
                        (subtitle != null
                            ? Padding(
                                padding: EdgeInsets.only(
                                  top: hasTitle ? theme.space(0.5) : 0,
                                  bottom: hasDescription ? theme.space(0.5) : 0,
                                ),
                                child: CdsText(subtitle!, font: condensed ? CdsFont.label1 : CdsFont.label2),
                              )
                            : null),
                  ].nonNulls.toList(),
                ),
              ),
              if (!condensed && metaWidget != null) metaWidget,
            ],
          )
        : null;

    return CdsCell(
      media: media,
      accessory: trailing,
      onPress: onPress,
      onLongPress: onLongPress,
      disabled: disabled,
      selected: selected,
      priority: priority,
      alignItems: alignItems,
      background: background,
      borderRadius: borderRadius ?? (condensed ? 0 : 200),
      minHeight: switch (spacingVariant) {
        CdsCellSpacingVariant.normal => CdsListCellHeights.normal,
        CdsCellSpacingVariant.compact => CdsListCellHeights.compact,
        CdsCellSpacingVariant.condensed => null,
      },
      innerSpacing: innerSpacing ?? (condensed ? CdsCellSpacing.condensedInner : null),
      outerSpacing: outerSpacing ?? (condensed ? CdsCellSpacing.condensedOuter : null),
      feedback: feedback,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      focusNode: focusNode,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?titles,
          descriptionNode ??
              (description != null ? CdsText(description!, font: CdsFont.body, color: CdsColor.fgMuted) : null),
        ].nonNulls.toList(),
      ),
    );
  }
}
