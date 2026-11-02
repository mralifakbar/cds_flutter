import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// One level in a [CdsBreadcrumb].
@immutable
class CdsBreadcrumbItem {
  const CdsBreadcrumbItem({required this.label, this.onPress});

  final String label;

  /// Navigates to this level. Ignored for the last item, which is the
  /// current page.
  final VoidCallback? onPress;
}

/// A trail of links from the top of a hierarchy to the current page, for
/// tablet and desktop layouts with deep navigation.
///
/// The last item is the current page. When [maxItems] is set and exceeded,
/// middle items collapse into `...`, which expands the trail when pressed.
///
/// ```dart
/// CdsBreadcrumb(
///   items: [
///     CdsBreadcrumbItem(label: 'Assets', onPress: () => go('/assets')),
///     CdsBreadcrumbItem(label: 'Bitcoin', onPress: () => go('/assets/btc')),
///     const CdsBreadcrumbItem(label: 'Transactions'),
///   ],
/// )
/// ```
class CdsBreadcrumb extends StatefulWidget {
  const CdsBreadcrumb({
    super.key,
    required this.items,
    this.accessibilityLabel = 'Breadcrumb',
    this.maxItems,
    this.expandAccessibilityLabel = 'Show all levels',
  }) : assert(maxItems == null || maxItems >= 2, 'maxItems must keep at least the first and last item');

  final List<CdsBreadcrumbItem> items;
  final String accessibilityLabel;

  /// Collapse middle items into `...` beyond this many visible items.
  final int? maxItems;

  /// Screen reader label for the `...` button.
  final String expandAccessibilityLabel;

  @override
  State<CdsBreadcrumb> createState() => _CdsBreadcrumbState();
}

class _CdsBreadcrumbState extends State<CdsBreadcrumb> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final items = widget.items;
    final max = widget.maxItems;
    final collapse = !_expanded && max != null && items.length > max;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    final entries = <Widget>[];
    void addSeparator() => entries.add(CdsIcon(
          rtl ? CdsIconName.caretLeft : CdsIconName.caretRight,
          size: CdsIconSize.xs,
          color: CdsColor.fgMuted,
        ));

    Widget link(String label, VoidCallback? onPress, {String? semanticLabel}) => CdsPressable(
          onPress: onPress,
          borderRadius: 200,
          transparentWhileInactive: true,
          background: CdsColor.bgSecondary,
          minTapTargetSize: 44,
          isButton: true,
          semanticLabel: semanticLabel,
          excludeChildSemantics: semanticLabel != null,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(0.5)),
            child: CdsText(label, font: CdsFont.label2, color: CdsColor.fgMuted),
          ),
        );

    final visible = <(int, CdsBreadcrumbItem)?>[
      if (collapse) ...[
        (0, items.first),
        null,
        for (var i = items.length - (max - 1); i < items.length; i++) (i, items[i]),
      ] else
        for (var i = 0; i < items.length; i++) (i, items[i]),
    ];

    for (var v = 0; v < visible.length; v++) {
      if (v > 0) addSeparator();
      final entry = visible[v];
      if (entry == null) {
        entries.add(link('...', () => setState(() => _expanded = true),
            semanticLabel: widget.expandAccessibilityLabel));
        continue;
      }
      final (index, item) = entry;
      if (index == items.length - 1) {
        entries.add(Semantics(
          selected: true,
          label: item.label,
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(0.5)),
                child: Align(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: CdsText(item.label, font: CdsFont.label1),
                ),
              ),
            ),
          ),
        ));
      } else {
        entries.add(link(item.label, item.onPress));
      }
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.accessibilityLabel,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: theme.space(0.5),
        children: entries,
      ),
    );
  }
}
