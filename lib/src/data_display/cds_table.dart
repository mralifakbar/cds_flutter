import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_spectrum.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../utils/cds_color_utils.dart';
import 'cds_table_cell.dart';

/// Line style of a [CdsTable].
enum CdsTableVariant {
  /// No lines between rows. CDS calls this `default`, a reserved word in Dart.
  standard,

  /// Lines between rows and between columns.
  graph,

  /// Lines between rows.
  ruled,
}

/// How a [CdsTable] sizes its columns.
enum CdsTableLayout {
  /// Columns size to their content and the table scrolls horizontally when
  /// it is wider than the screen. Extra width is shared between columns.
  auto,

  /// Columns share the available width equally (or per [CdsTable.columnWidths])
  /// and never scroll. Use with truncating cells.
  fixed,
}

/// A data table built from a caption, header, body and footer.
///
/// ```dart
/// CdsTable(
///   variant: CdsTableVariant.ruled,
///   children: [
///     const CdsTableCaption('Holdings'),
///     CdsTableHeader(children: [
///       CdsTableRow(children: const [CdsTableCell(title: 'Asset'), CdsTableCell(title: 'Balance', alignItems: CrossAxisAlignment.end)]),
///     ]),
///     CdsTableBody(children: [
///       for (final h in holdings)
///         CdsTableRow(onPress: () => open(h), children: [
///           CdsTableCell(title: h.name, subtitle: h.symbol),
///           CdsTableCell(title: h.balance, alignItems: CrossAxisAlignment.end),
///         ]),
///     ]),
///   ],
/// )
/// ```
///
/// Sections render in table order (caption, header, body, footer) no matter
/// the order of [children]. Rows can have different cell counts; short rows
/// are padded with empty cells.
class CdsTable extends StatefulWidget {
  const CdsTable({
    super.key,
    required this.children,
    this.variant = CdsTableVariant.standard,
    this.bordered = false,
    this.tableLayout = CdsTableLayout.auto,
    this.compact = false,
    this.cellPaddingX,
    this.cellPaddingY,
    this.columnWidths,
    this.height,
    this.maxHeight,
    this.semanticLabel,
  });

  /// [CdsTableCaption], [CdsTableHeader], [CdsTableBody] and [CdsTableFooter].
  final List<Widget> children;
  final CdsTableVariant variant;

  /// Draws a 1px `bgLine` border with 8px corners around the table.
  final bool bordered;
  final CdsTableLayout tableLayout;

  /// Tighter cell padding: 8px instead of 16px on each side.
  final bool compact;

  /// Horizontal cell padding as a space token; overrides [compact].
  final double? cellPaddingX;

  /// Vertical cell padding as a space token; overrides [compact].
  final double? cellPaddingY;

  /// Width of specific columns by index, e.g. `{0: FixedColumnWidth(160)}`.
  /// Wins over [CdsTableCell.width].
  final Map<int, TableColumnWidth>? columnWidths;

  /// Fixed height; the rows scroll vertically inside it.
  final double? height;

  /// Maximum height; the rows scroll vertically past it.
  final double? maxHeight;

  /// Name of the table for screen readers.
  final String? semanticLabel;

  @override
  State<CdsTable> createState() => _CdsTableState();
}

class _RowFlags {
  bool hovered = false;
  bool pressed = false;
  bool focused = false;
}

class _CdsTableState extends State<CdsTable> {
  final Map<String, _RowFlags> _flags = {};
  final Map<String, DateTime> _lastPress = {};
  final ScrollController _horizontal = ScrollController();

  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  void _set(String id, void Function(_RowFlags flags) change) {
    final flags = _flags.putIfAbsent(id, _RowFlags.new);
    final before = (flags.hovered, flags.pressed, flags.focused);
    change(flags);
    if (before != (flags.hovered, flags.pressed, flags.focused)) setState(() {});
  }

  void _activate(String id, VoidCallback onPress) {
    final now = clock.now();
    final last = _lastPress[id];
    if (last != null && now.difference(last) < const Duration(milliseconds: 500)) return;
    _lastPress[id] = now;
    onPress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final captions = widget.children.whereType<CdsTableCaption>().toList();
    final sections = <(CdsTableSectionType, List<CdsTableRow>)>[
      for (final s in widget.children.whereType<CdsTableHeader>()) (CdsTableSectionType.header, s.children),
      for (final s in widget.children.whereType<CdsTableBody>()) (CdsTableSectionType.body, s.children),
      for (final s in widget.children.whereType<CdsTableFooter>()) (CdsTableSectionType.footer, s.children),
    ];
    assert(
      widget.children.every((c) => c is CdsTableCaption || c is CdsTableHeader || c is CdsTableBody || c is CdsTableFooter),
      'CdsTable children must be CdsTableCaption, CdsTableHeader, CdsTableBody or CdsTableFooter.',
    );

    final paddingX = widget.cellPaddingX ?? (widget.compact ? 1.0 : 2.0);
    final paddingY = widget.cellPaddingY ?? (widget.compact ? 1.0 : 2.0);
    final columns = sections.fold<int>(0, (m, s) => s.$2.fold(m, (m2, r) => r.children.length > m2 ? r.children.length : m2));
    final line = BorderSide(color: theme.color.bgLine, width: theme.borderWidth(100));

    final widths = <int, TableColumnWidth>{};
    for (final (_, rows) in sections) {
      for (final row in rows) {
        for (var i = 0; i < row.children.length; i++) {
          final cell = row.children[i];
          final w = cell is CdsTableCell ? cell.width : (cell is CdsTableCellFallback ? cell.width : null);
          if (w != null) widths.putIfAbsent(i, () => FixedColumnWidth(w));
        }
      }
    }
    widths.addAll(widget.columnWidths ?? const {});

    final hoverColor = theme.spectrum.of(CdsHue.gray, 5).withValues(alpha: 0.35);
    final tableRows = <TableRow>[];
    for (var s = 0; s < sections.length; s++) {
      final (type, rows) = sections[s];
      for (var r = 0; r < rows.length; r++) {
        final row = rows[r];
        final id = '$s:$r';
        final flags = _flags[id] ?? _RowFlags();
        final interactive = row.onPress != null;
        final base = row.backgroundColor == null ? theme.color.bg : theme.colorOf(row.backgroundColor!);

        Color? background = row.backgroundColor == null ? null : base;
        if (interactive && flags.pressed) {
          background = CdsColorUtils.blendedColor(
              overlay: base, blendOpacity: CdsInteractionOpacity.pressed, brightness: theme.brightness);
        } else if (flags.hovered && type == CdsTableSectionType.body && !row.disableHoverIndicator) {
          background = Color.alphaBlend(hoverColor, base);
        }

        final cells = <Widget>[];
        for (var c = 0; c < columns; c++) {
          Widget cell = c < row.children.length ? row.children[c] : const SizedBox.shrink();
          cell = CdsTableCellScope(
            section: type,
            compact: widget.compact,
            paddingX: paddingX,
            paddingY: paddingY,
            rowColor: row.color,
            child: cell,
          );
          if (interactive || (type == CdsTableSectionType.body && !row.disableHoverIndicator)) {
            cell = _RowRegion(
              first: c == 0,
              interactive: interactive,
              semanticLabel: row.semanticLabel,
              onHover: (v) => _set(id, (f) => f.hovered = v),
              onPressed: (v) => _set(id, (f) => f.pressed = v),
              onFocus: (v) => _set(id, (f) => f.focused = v),
              onPress: interactive ? () => _activate(id, row.onPress!) : null,
              child: cell,
            );
          }
          cells.add(cell);
        }

        tableRows.add(TableRow(
          decoration: background == null && !flags.focused
              ? null
              : BoxDecoration(
                  color: background,
                  border: flags.focused
                      ? Border.all(color: theme.color.bgLinePrimary, width: theme.borderWidth(200))
                      : null,
                ),
          children: cells,
        ));
      }
    }

    final fixed = widget.tableLayout == CdsTableLayout.fixed;
    Widget table = Table(
      columnWidths: widths,
      defaultColumnWidth: fixed ? const FlexColumnWidth() : const IntrinsicColumnWidth(flex: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: switch (widget.variant) {
        CdsTableVariant.standard => null,
        CdsTableVariant.ruled => TableBorder(horizontalInside: line),
        CdsTableVariant.graph => TableBorder(horizontalInside: line, verticalInside: line),
      },
      children: tableRows,
    );

    if (!fixed) {
      final grid = table;
      table = LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedWidth) return grid;
          return RawScrollbar(
            controller: _horizontal,
            thumbVisibility: true,
            thickness: 4,
            radius: Radius.circular(theme.radius(1000)),
            thumbColor: theme.color.fgMuted.withValues(alpha: 0.4),
            child: SingleChildScrollView(
              controller: _horizontal,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(constraints: BoxConstraints(minWidth: constraints.maxWidth), child: grid),
            ),
          );
        },
      );
    }

    if (widget.height != null || widget.maxHeight != null) {
      table = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.height ?? widget.maxHeight!),
        child: SizedBox(
          height: widget.height,
          child: SingleChildScrollView(child: table),
        ),
      );
    }

    Widget result = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final caption in captions)
          CdsTableCellScope(
            section: CdsTableSectionType.header,
            compact: widget.compact,
            paddingX: paddingX,
            paddingY: paddingY,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: widget.variant == CdsTableVariant.standard ? null : Border(bottom: line),
              ),
              child: caption,
            ),
          ),
        table,
      ],
    );
    result = ColoredBox(color: theme.color.bg, child: result);

    if (widget.bordered) {
      final radius = BorderRadius.circular(theme.radius(200));
      result = DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)), borderRadius: radius),
        child: ClipRRect(borderRadius: radius, child: result),
      );
    }
    return Semantics(container: true, label: widget.semanticLabel, explicitChildNodes: true, child: result);
  }
}

/// Hover, press, focus and keyboard handling for one cell of a row. The
/// table paints the row's state, so the highlight spans every cell.
class _RowRegion extends StatelessWidget {
  const _RowRegion({
    required this.first,
    required this.interactive,
    required this.onHover,
    required this.onPressed,
    required this.onFocus,
    required this.onPress,
    required this.child,
    this.semanticLabel,
  });

  final bool first;
  final bool interactive;
  final ValueChanged<bool> onHover;
  final ValueChanged<bool> onPressed;
  final ValueChanged<bool> onFocus;
  final VoidCallback? onPress;
  final String? semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget region = MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: child,
    );
    if (!interactive) return region;

    region = Listener(
      // Feedback starts on pointer-down, before the tap is recognized.
      onPointerDown: (_) => onPressed(true),
      onPointerUp: (_) => onPressed(false),
      onPointerCancel: (_) => onPressed(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPress,
        excludeFromSemantics: true,
        child: region,
      ),
    );

    if (!first) return region;
    // The first cell carries the row's focus stop and button semantics.
    return FocusableActionDetector(
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
          onPress?.call();
          return null;
        }),
      },
      onShowFocusHighlight: onFocus,
      child: Semantics(
        button: true,
        label: semanticLabel,
        onTap: onPress,
        child: region,
      ),
    );
  }
}

/// The table's title, shown above the header in `title3`.
///
/// ```dart
/// const CdsTableCaption('Recent transactions')
/// ```
class CdsTableCaption extends StatelessWidget {
  const CdsTableCaption(
    String this.text, {
    super.key,
    this.align = TextAlign.start,
    this.color,
    this.backgroundColor,
  }) : child = null;

  /// Custom caption content.
  const CdsTableCaption.custom({required Widget this.child, super.key, this.color, this.backgroundColor})
      : text = null,
        align = TextAlign.start;

  final String? text;
  final Widget? child;
  final TextAlign align;

  /// Defaults to `fg`.
  final CdsColor? color;
  final CdsColor? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final scope = CdsTableCellScope.maybeOf(context);
    final content = child ??
        Semantics(
          header: true,
          child: Text(text!, textAlign: align, style: theme.textStyle(CdsFont.title3, color: color ?? CdsColor.fg)),
        );
    return Container(
      color: backgroundColor == null ? null : theme.colorOf(backgroundColor!),
      padding: EdgeInsets.symmetric(
        horizontal: theme.space(scope?.paddingX ?? 2),
        vertical: theme.space(scope?.paddingY ?? 2),
      ),
      child: content,
    );
  }
}

Never _outsideTable(String name) => throw FlutterError.fromParts([
      ErrorSummary('$name must be a direct child of CdsTable.'),
      ErrorHint('CdsTable reads its sections and rows and lays them out as one grid.'),
    ]);

/// Header rows of a [CdsTable]. Cells render in muted `headline` and are
/// marked as headers for screen readers.
class CdsTableHeader extends StatelessWidget {
  const CdsTableHeader({super.key, required this.children});

  final List<CdsTableRow> children;

  @override
  Widget build(BuildContext context) => _outsideTable('CdsTableHeader');
}

/// Body rows of a [CdsTable].
class CdsTableBody extends StatelessWidget {
  const CdsTableBody({super.key, required this.children});

  final List<CdsTableRow> children;

  @override
  Widget build(BuildContext context) => _outsideTable('CdsTableBody');
}

/// Footer rows of a [CdsTable], such as totals. Cells render in muted `body`.
class CdsTableFooter extends StatelessWidget {
  const CdsTableFooter({super.key, required this.children});

  final List<CdsTableRow> children;

  @override
  Widget build(BuildContext context) => _outsideTable('CdsTableFooter');
}

/// One row of a [CdsTable] section.
///
/// ```dart
/// CdsTableRow(
///   onPress: () => openTransaction(tx),
///   semanticLabel: 'Open transaction',
///   children: [CdsTableCell(title: tx.label), CdsTableCell(title: tx.amount)],
/// )
/// ```
///
/// Body rows tint on hover. A pressable row tints on pointer-down, takes
/// keyboard focus on its first cell, and activates with Enter or Space.
class CdsTableRow extends StatelessWidget {
  const CdsTableRow({
    super.key,
    required this.children,
    this.backgroundColor,
    this.color,
    this.disableHoverIndicator = false,
    this.onPress,
    this.semanticLabel,
  });

  /// [CdsTableCell] or [CdsTableCellFallback] widgets, one per column.
  final List<Widget> children;
  final CdsColor? backgroundColor;

  /// Text color for every cell in the row.
  final CdsColor? color;

  /// Turns off the hover tint on body rows.
  final bool disableHoverIndicator;
  final VoidCallback? onPress;

  /// Label of the row's button for screen readers, e.g. "Open Bitcoin".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => _outsideTable('CdsTableRow');
}
