import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../buttons/cds_button_variant.dart';
import '../buttons/cds_icon_button.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// One entry in the row [CdsPagination] renders: a page number or an ellipsis.
@immutable
sealed class CdsPaginationItem {
  const CdsPaginationItem();
}

/// A page button in a pagination row.
final class CdsPaginationPageItem extends CdsPaginationItem {
  const CdsPaginationPageItem(this.page, {this.selected = false});

  /// 1-based page number.
  final int page;
  final bool selected;

  @override
  bool operator ==(Object other) =>
      other is CdsPaginationPageItem && other.page == page && other.selected == selected;

  @override
  int get hashCode => Object.hash(page, selected);

  @override
  String toString() => selected ? '[$page]' : '$page';
}

/// A gap of hidden pages, shown as `...`.
final class CdsPaginationEllipsisItem extends CdsPaginationItem {
  const CdsPaginationEllipsisItem();

  @override
  bool operator ==(Object other) => other is CdsPaginationEllipsisItem;

  @override
  int get hashCode => 0;

  @override
  String toString() => '...';
}

List<int> _range(int start, int end) =>
    end < start ? const [] : List<int>.generate(end - start + 1, (i) => start + i);

/// Computes the pages and ellipses [CdsPagination] shows, using the same
/// algorithm as CDS `usePagination`.
///
/// [activePage] is 1-based. [boundaryCount] pages always show at each end,
/// [siblingCount] pages show on each side of the active page, and gaps
/// collapse into an ellipsis only when they hide two or more pages.
///
/// ```dart
/// cdsPaginationItems(activePage: 1, totalPages: 10);
/// // [1] 2 3 4 5 ... 10
/// ```
List<CdsPaginationItem> cdsPaginationItems({
  required int activePage,
  required int totalPages,
  int siblingCount = 1,
  int boundaryCount = 1,
}) {
  final total = math.max(1, totalPages);
  assert(activePage >= 1 && activePage <= total, 'activePage must be between 1 and totalPages');
  final active = activePage.clamp(1, total);

  final startPages = _range(1, math.min(boundaryCount, total));
  final endPages = _range(math.max(total - boundaryCount + 1, boundaryCount + 1), total);
  final siblingsStart = math.max(
    math.min(active - siblingCount, total - boundaryCount - siblingCount * 2 - 1),
    boundaryCount + 2,
  );
  final siblingsEnd = math.min(
    math.max(active + siblingCount, boundaryCount + siblingCount * 2 + 2),
    endPages.isNotEmpty ? endPages.first - 2 : total - 1,
  );

  CdsPaginationItem page(int p) => CdsPaginationPageItem(p, selected: p == active);

  return [
    for (final p in startPages) page(p),
    if (siblingsStart > boundaryCount + 2)
      const CdsPaginationEllipsisItem()
    else if (boundaryCount + 1 < total - boundaryCount)
      page(boundaryCount + 1),
    for (final p in _range(siblingsStart, siblingsEnd)) page(p),
    if (siblingsEnd < total - boundaryCount - 1)
      const CdsPaginationEllipsisItem()
    else if (total - boundaryCount > boundaryCount)
      page(total - boundaryCount),
    for (final p in endPages) page(p),
  ];
}

/// Accessibility labels for the controls inside [CdsPagination].
@immutable
class CdsPaginationAccessibilityLabels {
  const CdsPaginationAccessibilityLabels({
    this.next = 'Next page',
    this.previous = 'Previous page',
    this.first = 'First page',
    this.last = 'Last page',
    this.page = _defaultPageLabel,
  });

  final String next;
  final String previous;
  final String first;
  final String last;

  /// Label for a page button, given its 1-based number.
  final String Function(int page) page;

  static String _defaultPageLabel(int page) => 'Page $page';
}

/// A row of page buttons with previous and next controls, for moving
/// through paged lists and tables.
///
/// Controlled: [activePage] is 1-based, and [onChange] receives the page the
/// user picked. Arrow keys move focus between page buttons.
///
/// ```dart
/// CdsPagination(
///   totalPages: 12,
///   activePage: page,
///   onChange: (next) => setState(() => page = next),
/// )
/// ```
class CdsPagination extends StatefulWidget {
  const CdsPagination({
    super.key,
    required this.totalPages,
    required this.activePage,
    required this.onChange,
    this.siblingCount = 1,
    this.boundaryCount = 1,
    this.showFirstLastButtons = false,
    this.disabled = false,
    this.firstPageButtonLabel = 'First',
    this.lastPageButtonLabel = 'Last',
    this.accessibilityLabel = 'Pagination',
    this.accessibilityLabels = const CdsPaginationAccessibilityLabels(),
  });

  final int totalPages;

  /// The current page, 1-based.
  final int activePage;
  final ValueChanged<int> onChange;

  /// Pages shown on each side of the active page.
  final int siblingCount;

  /// Pages always shown at the start and end.
  final int boundaryCount;

  /// Adds "First" and "Last" text buttons at the ends.
  final bool showFirstLastButtons;
  final bool disabled;
  final String firstPageButtonLabel;
  final String lastPageButtonLabel;

  /// Label for the whole navigation group.
  final String accessibilityLabel;
  final CdsPaginationAccessibilityLabels accessibilityLabels;

  @override
  State<CdsPagination> createState() => _CdsPaginationState();
}

class _CdsPaginationState extends State<CdsPagination> {
  final Map<int, FocusNode> _pageNodes = {};

  int get _total => math.max(1, widget.totalPages);

  FocusNode _nodeFor(int page) =>
      _pageNodes.putIfAbsent(page, () => FocusNode(debugLabel: 'CdsPagination page $page'));

  @override
  void dispose() {
    for (final node in _pageNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _goTo(int page) {
    if (widget.disabled || page < 1 || page > _total || page == widget.activePage) return;
    widget.onChange(page);
  }

  // Keeps focus on a page button when the control that held it becomes disabled.
  void _goToAndFocus(int page) {
    _goTo(page);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pageNodes[page]?.requestFocus();
    });
  }

  void _moveFocus(int delta) {
    final visible = <int>[
      for (final item in _items)
        if (item is CdsPaginationPageItem) item.page,
    ];
    final focused = visible.indexWhere((p) => _pageNodes[p]?.hasPrimaryFocus ?? false);
    if (focused < 0) return;
    final next = (focused + delta).clamp(0, visible.length - 1);
    _nodeFor(visible[next]).requestFocus();
  }

  List<CdsPaginationItem> get _items => cdsPaginationItems(
        activePage: widget.activePage.clamp(1, _total),
        totalPages: _total,
        siblingCount: widget.siblingCount,
        boundaryCount: widget.boundaryCount,
      );

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final labels = widget.accessibilityLabels;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final active = widget.activePage;
    final atFirst = active <= 1 || widget.disabled;
    final atLast = active >= _total || widget.disabled;

    Widget textButton(String label, String semantic, bool off, VoidCallback onPress) => CdsButton(
          label: label,
          size: CdsButtonSize.s,
          variant: CdsButtonVariant.secondary,
          disabled: off,
          semanticLabel: semantic,
          onPress: off ? null : onPress,
        );

    Widget arrow(CdsIconName icon, String semantic, bool off, VoidCallback onPress) => CdsIconButton(
          icon,
          semanticLabel: semantic,
          transparent: true,
          size: CdsButtonSize.s,
          variant: CdsButtonVariant.secondary,
          disabled: off,
          onPress: off ? null : onPress,
        );

    final children = <Widget>[
      if (widget.showFirstLastButtons)
        textButton(widget.firstPageButtonLabel, labels.first, atFirst, () => _goToAndFocus(1)),
      arrow(rtl ? CdsIconName.caretRight : CdsIconName.caretLeft, labels.previous, atFirst, () {
        if (active - 1 == 1) {
          _goToAndFocus(1);
        } else {
          _goTo(active - 1);
        }
      }),
      for (final item in _items)
        switch (item) {
          CdsPaginationPageItem(:final page, :final selected) => _PageButton(
              key: ValueKey('page-$page'),
              page: page,
              selected: selected,
              disabled: widget.disabled,
              semanticLabel: labels.page(page),
              focusNode: _nodeFor(page),
              onPress: () => _goTo(page),
            ),
          CdsPaginationEllipsisItem() => const ExcludeSemantics(
              child: CdsText('...', font: CdsFont.headline, color: CdsColor.fgMuted, softWrap: false),
            ),
        },
      arrow(rtl ? CdsIconName.caretLeft : CdsIconName.caretRight, labels.next, atLast, () {
        if (active + 1 == _total) {
          _goToAndFocus(_total);
        } else {
          _goTo(active + 1);
        }
      }),
      if (widget.showFirstLastButtons)
        textButton(widget.lastPageButtonLabel, labels.last, atLast, () => _goToAndFocus(_total)),
    ];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.accessibilityLabel,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _moveFocus(rtl ? 1 : -1),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _moveFocus(rtl ? -1 : 1),
        },
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: theme.space(0.5),
          runSpacing: theme.space(0.5),
          children: children,
        ),
      ),
    );
  }
}

/// Mirrors CDS `DefaultPaginationPageButton`: a small button, primary when
/// current and transparent secondary otherwise, circular for 1 to 9.
class _PageButton extends StatelessWidget {
  const _PageButton({
    super.key,
    required this.page,
    required this.selected,
    required this.disabled,
    required this.semanticLabel,
    required this.focusNode,
    required this.onPress,
  });

  final int page;
  final bool selected;
  final bool disabled;
  final String semanticLabel;
  final FocusNode focusNode;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final colors = CdsButtonColors.of(
      selected ? CdsButtonVariant.primary : CdsButtonVariant.secondary,
      transparent: !selected,
    );
    final circular = page < 10;
    final label = CdsText('$page', font: CdsFont.headline, color: colors.foreground, maxLines: 1, tabularNumbers: true);
    return CdsPressable(
      onPress: disabled ? null : onPress,
      disabled: disabled,
      background: colors.background,
      borderColor: colors.border,
      borderRadius: circular ? 1000 : 700,
      transparentWhileInactive: !selected,
      feedback: CdsHapticFeedback.light,
      selected: selected,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      focusNode: focusNode,
      minTapTargetSize: 44,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: circular ? 0 : theme.space(2),
            vertical: theme.space(1),
          ),
          child: Center(widthFactor: 1, heightFactor: 1, child: label),
        ),
      ),
    );
  }
}
