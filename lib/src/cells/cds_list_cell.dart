import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_cell.dart';
import 'cds_cell_layout.dart';

/// Minimum heights CDS keeps for the deprecated spacing variants.
abstract final class CdsListCellHeights {
  static const double normal = 80;
  static const double compact = 40;
}

/// A row in a list: media, a title with optional subtitle and description,
/// end detail, and a trailing accessory.
///
/// ```dart
/// CdsListCell(
///   spacingVariant: CdsCellSpacingVariant.condensed,
///   media: CdsCellMedia.asset(source: btcLogo),
///   title: 'Bitcoin',
///   description: 'BTC',
///   detail: r'$64,201.10',
///   subdetail: '+2.4%',
///   variant: CdsCellDetailVariant.positive,
///   accessory: CdsCellAccessoryType.arrow,
///   onPress: () => openAsset('BTC'),
/// )
/// ```
///
/// The row is divided into five columns: [media], the title stack,
/// [intermediary], the end content ([end], or [detail] and [subdetail]),
/// and the accessory. When [selected], the accessory becomes a checkmark
/// unless [disableSelectionAccessory] is set.
///
/// Avoid interactive [end] content together with [onPress]: the whole row
/// is one button for screen readers.
class CdsListCell extends StatelessWidget {
  const CdsListCell({
    super.key,
    this.title,
    this.titleNode,
    this.subtitle,
    this.subtitleNode,
    this.description,
    this.descriptionNode,
    this.detail,
    this.detailNode,
    this.subdetail,
    this.subdetailNode,
    this.variant = CdsCellDetailVariant.foregroundMuted,
    this.media,
    this.intermediary,
    this.end,
    this.accessory,
    this.accessoryNode,
    this.helperText,
    this.spacingVariant = CdsCellSpacingVariant.normal,
    this.priority = const {},
    this.selected = false,
    this.disabled = false,
    this.disableSelectionAccessory = false,
    this.disableMultilineTitle = false,
    this.multiline = false,
    this.onPress,
    this.onLongPress,
    this.background = CdsColor.bgAlternate,
    this.borderRadius,
    this.minHeight,
    this.detailWidth,
    this.innerSpacing,
    this.outerSpacing,
    this.feedback = CdsHapticFeedback.none,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
  });

  /// Up to two lines, or one when a description is shown outside the
  /// `condensed` variant.
  final String? title;

  /// Custom title content; takes precedence over [title]. You own its style
  /// and truncation.
  final Widget? titleNode;

  /// One line between the title and description.
  final String? subtitle;
  final Widget? subtitleNode;

  /// One line with a title, two without, unless [multiline].
  final String? description;
  final Widget? descriptionNode;

  /// End-aligned value, e.g. a balance.
  final String? detail;
  final Widget? detailNode;

  /// Line under [detail], colored by [variant].
  final String? subdetail;
  final Widget? subdetailNode;
  final CdsCellDetailVariant variant;

  /// Leading icon, avatar or image. See [CdsCellMedia].
  final Widget? media;

  /// Content between the title stack and the end content.
  final Widget? intermediary;

  /// End content such as a button or switch; replaces [detail] and [subdetail].
  final Widget? end;
  final CdsCellAccessoryType? accessory;

  /// Custom accessory; takes precedence over [accessory].
  final Widget? accessoryNode;

  /// Assistive message under the row, usually a [CdsCellHelperText].
  final Widget? helperText;

  /// Defaults to `normal` to match CDS. Prefer `condensed` for new designs.
  final CdsCellSpacingVariant spacingVariant;
  final Set<CdsCellPriority> priority;
  final bool selected;
  final bool disabled;

  /// Keep [accessory] (or nothing) instead of the checkmark when [selected].
  final bool disableSelectionAccessory;

  /// Always truncate the title to one line.
  final bool disableMultilineTitle;

  /// Let the description wrap without a line limit.
  final bool multiline;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;

  /// Fill when [selected].
  final CdsColor background;

  /// Radius token. Defaults to 200, or 0 for `condensed`.
  final int? borderRadius;

  /// Overrides the variant's minimum height (80 for normal, 40 for compact).
  final double? minHeight;

  /// Fixed width for the end content.
  final double? detailWidth;
  final CdsCellSpacing? innerSpacing;
  final CdsCellSpacing? outerSpacing;
  final CdsHapticFeedback feedback;
  final String? semanticLabel;
  final String? semanticHint;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final condensed = spacingVariant == CdsCellSpacingVariant.condensed;
    final accessoryType =
        selected && !disableSelectionAccessory ? CdsCellAccessoryType.selected : accessory;
    final hasDetails = detail != null || subdetail != null || detailNode != null || subdetailNode != null;
    final endContent = end ??
        (hasDetails
            ? CdsCellDetail(
                detail: detail,
                detailNode: detailNode,
                subdetail: subdetail,
                subdetailNode: subdetailNode,
                variant: variant,
                subdetailFont: condensed ? CdsFont.label2 : CdsFont.body,
              )
            : null);

    final hasDescription = description != null || descriptionNode != null;
    final titleLines = disableMultilineTitle ? 1 : (condensed ? 2 : (hasDescription ? 1 : 2));
    final titleStack = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleNode ?? (title != null ? CdsText(title!, font: CdsFont.headline, maxLines: titleLines) : null),
        subtitleNode ??
            (subtitle != null ? CdsText(subtitle!, font: CdsFont.label1, color: CdsColor.fgMuted, maxLines: 1) : null),
        descriptionNode ??
            (description != null
                ? CdsText(
                    description!,
                    font: condensed ? CdsFont.label2 : CdsFont.body,
                    color: CdsColor.fgMuted,
                    maxLines: multiline ? null : (title != null || titleNode != null ? 1 : 2),
                  )
                : null),
      ].nonNulls.toList(),
    );

    return CdsCell(
      media: media,
      intermediary: intermediary,
      end: endContent,
      accessory: accessoryNode ?? (accessoryType != null ? CdsCellAccessory(accessoryType) : null),
      bottomContent: helperText,
      onPress: onPress,
      onLongPress: onLongPress,
      disabled: disabled,
      selected: selected,
      priority: priority,
      background: background,
      borderRadius: borderRadius ?? (condensed ? 0 : 200),
      minHeight: minHeight ??
          switch (spacingVariant) {
            CdsCellSpacingVariant.normal => CdsListCellHeights.normal,
            CdsCellSpacingVariant.compact => CdsListCellHeights.compact,
            CdsCellSpacingVariant.condensed => null,
          },
      endWidth: detailWidth,
      innerSpacing: innerSpacing ?? (condensed ? CdsCellSpacing.condensedInner : null),
      outerSpacing: outerSpacing ?? (condensed ? CdsCellSpacing.condensedOuter : null),
      feedback: feedback,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      focusNode: focusNode,
      child: titleStack,
    );
  }
}
