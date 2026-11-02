import 'package:flutter/widgets.dart';

import '../cells/cds_cell_layout.dart';
import '../cells/cds_list_cell_fallback.dart';
import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../media/cds_cell_media.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';

/// Which part of a table a cell is rendered in.
enum CdsTableSectionType { header, body, footer }

/// Sort state of a sortable header cell.
enum CdsTableSortDirection {
  /// Sortable, but not the active sort column.
  none,
  ascending,
  descending,
}

/// Content flow inside a [CdsTableCell].
enum CdsTableCellDirection { vertical, horizontal }

/// What a [CdsTableCell] needs from its table and row. Provided by
/// [CdsTable]; internal to cds_flutter.
class CdsTableCellScope extends InheritedWidget {
  const CdsTableCellScope({
    super.key,
    required this.section,
    required this.compact,
    required this.paddingX,
    required this.paddingY,
    this.rowColor,
    required super.child,
  });

  final CdsTableSectionType section;
  final bool compact;

  /// Default cell padding as space tokens.
  final double paddingX;
  final double paddingY;

  /// Text color set on the enclosing row.
  final CdsColor? rowColor;

  static CdsTableCellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CdsTableCellScope>();

  @override
  bool updateShouldNotify(CdsTableCellScope old) =>
      section != old.section ||
      compact != old.compact ||
      paddingX != old.paddingX ||
      paddingY != old.paddingY ||
      rowColor != old.rowColor;
}

/// One cell of a [CdsTableRow]: a title with optional subtitle, or any
/// child, with optional start and end widgets.
///
/// ```dart
/// CdsTableCell(title: 'Bitcoin', subtitle: 'BTC', start: CdsCellMedia.asset(source: btcLogo))
/// const CdsTableCell(title: r'$64,201.10', alignItems: CrossAxisAlignment.end)
/// CdsTableCell(title: 'Price', sortDirection: CdsTableSortDirection.descending, onPress: toggleSort)
/// ```
///
/// Text style follows the section: `headline` in muted color in the
/// header, `body` in the body, `body` muted in the footer.
class CdsTableCell extends StatelessWidget {
  const CdsTableCell({
    super.key,
    this.title,
    this.subtitle,
    this.child,
    this.start,
    this.end,
    this.color,
    this.titleColor,
    this.subtitleColor = CdsColor.fgMuted,
    this.direction = CdsTableCellDirection.vertical,
    this.justifyContent,
    this.alignItems,
    this.overflow,
    this.width,
    this.paddingX,
    this.paddingY,
    this.onPress,
    this.sortDirection,
    this.semanticLabel,
  }) : assert(child == null || (title == null && subtitle == null),
            'CdsTableCell: use either title/subtitle or child, not both.');

  final String? title;

  /// `label2` line under the title.
  final String? subtitle;

  /// Custom content; replaces [title] and [subtitle]. Plain [Text] inside
  /// picks up the section's font and color.
  final Widget? child;

  /// Icon, asset or image before the content.
  final Widget? start;

  /// Widget after the content, e.g. a [CdsTableCellSortIcon].
  final Widget? end;

  /// Color for all text in the cell. Defaults to the row color, then the
  /// section default.
  final CdsColor? color;

  /// Title color; wins over [color].
  final CdsColor? titleColor;
  final CdsColor subtitleColor;
  final CdsTableCellDirection direction;

  /// Main-axis alignment of the content. Defaults to start for vertical
  /// cells and space-between for horizontal ones.
  final MainAxisAlignment? justifyContent;

  /// Cross-axis alignment. Use [CrossAxisAlignment.end] to right-align a
  /// numeric column. Defaults to start for vertical cells and center for
  /// horizontal ones.
  final CrossAxisAlignment? alignItems;

  /// Truncate the title and subtitle to one line. Pair with [width] or a
  /// fixed table layout so the column has a width to truncate at.
  final TextOverflow? overflow;

  /// Fixed column width in logical pixels. The first cell in a column that
  /// sets it decides the column's width.
  final double? width;

  /// Overrides the table's horizontal padding (space token).
  final double? paddingX;

  /// Overrides the table's vertical padding (space token).
  final double? paddingY;

  /// Makes the cell pressable, e.g. to sort by this column.
  final VoidCallback? onPress;

  /// Marks a header cell sortable: shows a [CdsTableCellSortIcon], colors the
  /// active column `fgPrimary`, and tells screen readers the sort state.
  final CdsTableSortDirection? sortDirection;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final scope = CdsTableCellScope.maybeOf(context);
    final section = scope?.section ?? CdsTableSectionType.body;
    final compact = scope?.compact ?? false;
    final vertical = direction == CdsTableCellDirection.vertical;
    final sorted = sortDirection != null && sortDirection != CdsTableSortDirection.none;

    final sectionColor = section == CdsTableSectionType.body ? CdsColor.fg : CdsColor.fgMuted;
    final baseColor = color ?? (sorted ? CdsColor.fgPrimary : null) ?? scope?.rowColor ?? sectionColor;
    final font = section == CdsTableSectionType.header ? CdsFont.headline : CdsFont.body;
    final truncate = overflow != null;
    final align = alignItems ?? (vertical ? CrossAxisAlignment.start : CrossAxisAlignment.center);
    final justify = justifyContent ?? (vertical ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween);
    final textAlign = switch (align) {
      CrossAxisAlignment.end => TextAlign.end,
      CrossAxisAlignment.center => TextAlign.center,
      _ => TextAlign.start,
    };

    Widget content;
    if (child != null) {
      content = DefaultTextStyle(
        style: theme.textStyle(font, color: baseColor),
        child: Flex(
          direction: vertical ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: justify,
          crossAxisAlignment: align,
          spacing: theme.space(0.5),
          children: [child!],
        ),
      );
    } else {
      final children = <Widget>[
        if (title != null)
          Text(
            title!,
            style: theme.textStyle(font, color: titleColor ?? baseColor),
            textAlign: textAlign,
            maxLines: truncate ? 1 : null,
            softWrap: !truncate,
            overflow: overflow,
          ),
        if (subtitle != null)
          Padding(
            padding: EdgeInsets.only(top: !compact && title != null ? theme.space(0.5) : 0),
            child: Text(
              subtitle!,
              style: theme.textStyle(CdsFont.label2, color: subtitleColor),
              textAlign: textAlign,
              maxLines: truncate ? 1 : null,
              overflow: overflow,
            ),
          ),
      ];
      content = Flex(
        direction: vertical ? Axis.vertical : Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: justify,
        crossAxisAlignment: align,
        children: children,
      );
    }
    if (align == CrossAxisAlignment.end || align == CrossAxisAlignment.center) {
      content = Align(
        alignment: align == CrossAxisAlignment.end ? AlignmentDirectional.centerEnd : AlignmentDirectional.center,
        widthFactor: 1,
        child: content,
      );
    }

    final trailing = end ?? (sortDirection != null ? CdsTableCellSortIcon(direction: sortDirection!) : null);
    Widget cell = CdsCellLayout(
      media: start,
      main: content,
      accessory: trailing,
      gap: theme.space(compact ? 0.5 : 1),
    );
    cell = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.space(paddingX ?? scope?.paddingX ?? 2),
        vertical: theme.space(paddingY ?? scope?.paddingY ?? 2),
      ),
      child: cell,
    );

    final sortValue = switch (sortDirection) {
      null => null,
      CdsTableSortDirection.none => 'Not sorted',
      CdsTableSortDirection.ascending => 'Sorted ascending',
      CdsTableSortDirection.descending => 'Sorted descending',
    };

    if (onPress != null) {
      return CdsPressable(
        onPress: onPress,
        block: true,
        noScaleOnPress: true,
        transparentWhileInactive: true,
        background: CdsColor.bg,
        semanticLabel: semanticLabel,
        child: Semantics(
          header: section == CdsTableSectionType.header,
          value: sortValue,
          child: cell,
        ),
      );
    }
    return Semantics(
      header: section == CdsTableSectionType.header,
      value: sortValue,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: cell,
    );
  }
}

/// The up and down carets of a sortable column header, with the active
/// direction in `fgPrimary`.
///
/// ```dart
/// const CdsTableCellSortIcon(direction: CdsTableSortDirection.ascending)
/// ```
class CdsTableCellSortIcon extends StatelessWidget {
  const CdsTableCellSortIcon({super.key, this.direction = CdsTableSortDirection.none});

  final CdsTableSortDirection direction;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CdsIcon(
            CdsIconName.sortUpCenter,
            size: CdsIconSize.xs,
            active: true,
            color: direction == CdsTableSortDirection.ascending ? CdsColor.fgPrimary : CdsColor.fgMuted,
          ),
          CdsIcon(
            CdsIconName.sortDownCenter,
            size: CdsIconSize.xs,
            active: true,
            color: direction == CdsTableSortDirection.descending ? CdsColor.fgPrimary : CdsColor.fgMuted,
          ),
        ],
      ),
    );
  }
}

/// A loading placeholder for one table cell. Use a row of these while data
/// loads.
///
/// ```dart
/// CdsTableRow(children: [
///   const CdsTableCellFallback(title: true, subtitle: true, start: CdsCellMediaType.asset),
///   const CdsTableCellFallback(title: true),
/// ])
/// ```
class CdsTableCellFallback extends StatelessWidget {
  const CdsTableCellFallback({
    super.key,
    this.title = false,
    this.subtitle = false,
    this.start,
    this.end,
    this.titleWidth = 96,
    this.subtitleWidth = 64,
    this.rectWidthVariant,
    this.width,
    this.semanticLabel = 'Loading cell',
  });

  final bool title;
  final bool subtitle;

  /// Shape of a leading media placeholder.
  final CdsCellMediaType? start;

  /// Shape of a trailing media placeholder.
  final CdsCellMediaType? end;

  /// Base width of the title bar in logical pixels.
  final double titleWidth;

  /// Base width of the subtitle bar in logical pixels.
  final double subtitleWidth;

  /// Varies bar widths deterministically; pass the row index.
  final int? rectWidthVariant;

  /// Fixed column width, as on [CdsTableCell].
  final double? width;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final scope = CdsTableCellScope.maybeOf(context);
    final compact = scope?.compact ?? false;
    final v = rectWidthVariant;

    final bars = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: theme.space(!compact && title ? 1 : 0.5),
      children: [
        if (title) CdsFallbackBlock(width: cdsFallbackWidth(titleWidth, v), height: 24, radius: 2),
        if (subtitle) CdsFallbackBlock(width: cdsFallbackWidth(subtitleWidth, v == null ? null : v + 1), height: 16, radius: 2),
      ],
    );

    final cell = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.space(scope?.paddingX ?? 2),
        vertical: theme.space(scope?.paddingY ?? 2),
      ),
      child: CdsCellLayout(
        media: start == null ? null : CdsMediaFallback(start!),
        main: bars,
        accessory: end == null ? null : CdsMediaFallback(end!),
        gap: theme.space(compact ? 0.5 : 1),
      ),
    );
    return Semantics(label: semanticLabel, container: true, child: ExcludeSemantics(child: cell));
  }
}
