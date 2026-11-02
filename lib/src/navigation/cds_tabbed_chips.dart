import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_tabs.dart';
import 'tab_list.dart';

/// A horizontally scrolling row of chips that acts as a tab list. The active
/// chip inverts its color scheme. Good for nested or secondary tabs, such as
/// filters under a [CdsTabNavigation].
///
/// ```dart
/// CdsTabbedChips(
///   accessibilityLabel: 'Asset filters',
///   tabs: const [
///     CdsTabValue(id: 'all', label: 'All'),
///     CdsTabValue(id: 'gainers', label: 'Top gainers'),
///     CdsTabValue(id: 'new', label: 'New'),
///   ],
///   value: filter,
///   onChange: (id) => setState(() => filter = id),
/// )
/// ```
///
/// The active chip scrolls into view when it changes, and the trailing edge
/// fades while more chips are offscreen.
class CdsTabbedChips extends StatelessWidget {
  const CdsTabbedChips({
    super.key,
    required this.tabs,
    required this.onChange,
    this.value,
    this.gap = 1,
    this.paddingX = 0,
    this.tabBuilder,
    this.accessibilityLabel,
  });

  final List<CdsTabValue> tabs;

  /// Id of the active chip. Defaults to the first tab, like CDS.
  final String? value;
  final ValueChanged<String> onChange;

  /// Space token between chips.
  final double gap;

  /// Space token inset at both ends of the scrolling row.
  final double paddingX;

  /// Replaces each chip's label content (CDS `Component`).
  final CdsTabContentBuilder? tabBuilder;
  final String? accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return TabList(
      tabs: tabs,
      activeId: value ?? (tabs.isEmpty ? null : tabs.first.id),
      onChange: onChange,
      gap: theme.space(gap),
      scrollable: true,
      overflowGradient: true,
      padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(paddingX)),
      semanticLabel: accessibilityLabel,
      buildTab: (context, slot) => _TabChip(slot: slot, builder: tabBuilder),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.slot, required this.builder});

  final TabSlot slot;
  final CdsTabContentBuilder? builder;

  Widget _chip(BuildContext context) {
    final theme = context.cds;
    final tab = slot.tab;
    final content = builder?.call(context, tab, slot.active) ??
        CdsText(tab.label, font: CdsFont.headline, maxLines: 1);
    return CdsPressable(
      onPress: slot.onPress,
      disabled: !slot.enabled,
      focusNode: slot.focusNode,
      isButton: false,
      selected: slot.active,
      background: CdsColor.bgSecondary,
      borderRadius: 700,
      debounce: Duration.zero,
      minTapTargetSize: 44,
      semanticLabel: tab.accessibilityLabel,
      child: slot.semantics(
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(2), vertical: theme.space(1)),
          child: tab.accessibilityLabel == null ? content : ExcludeSemantics(child: content),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    // Always wrap in CdsTheme so toggling the active state keeps the same
    // element tree and the chip keeps keyboard focus.
    final data = slot.active
        ? CdsThemeData(config: theme.config, brightness: theme.isDark ? Brightness.light : Brightness.dark)
        : theme;
    return Center(
      widthFactor: 1,
      child: CdsTheme(data: data, child: Builder(builder: _chip)),
    );
  }
}
