import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_tabs.dart';
import 'tab_list.dart';

/// One destination in a [CdsBottomNavigation].
@immutable
class CdsBottomNavigationItem {
  const CdsBottomNavigationItem({
    required this.id,
    required this.icon,
    required this.label,
    this.count,
    this.max,
    this.disabled = false,
    this.accessibilityLabel,
  });

  final String id;

  /// Drawn outlined when inactive and with the filled (active) glyph when
  /// selected, so the selection never relies on color alone.
  final CdsIconName icon;
  final String label;

  /// Badge on the icon when greater than zero.
  final int? count;

  /// Counts above this show as `max+`. Defaults to 99.
  final int? max;
  final bool disabled;
  final String? accessibilityLabel;
}

/// A phone bottom tab bar in CDS style: icons with labels, the active
/// destination drawn with the filled glyph and `fgPrimary`, 44px+ targets and
/// the bottom safe area applied.
///
/// CDS React Native leaves the bottom tab bar to the app's navigator, so this
/// is a cds_flutter extra built from CDS tokens.
///
/// ```dart
/// CdsBottomNavigation(
///   items: const [
///     CdsBottomNavigationItem(id: 'home', icon: CdsIconName.home, label: 'Home'),
///     CdsBottomNavigationItem(id: 'trade', icon: CdsIconName.trading, label: 'Trade'),
///     CdsBottomNavigationItem(id: 'wallet', icon: CdsIconName.wallet, label: 'Wallet'),
///   ],
///   value: destination,
///   onChange: (id) => setState(() => destination = id),
/// )
/// ```
class CdsBottomNavigation extends StatelessWidget {
  const CdsBottomNavigation({
    super.key,
    required this.items,
    required this.value,
    required this.onChange,
    this.background = CdsColor.bg,
    this.bordered = true,
    this.showLabels = true,
    this.respectSafeArea = true,
    this.accessibilityLabel = 'Main navigation',
  });

  final List<CdsBottomNavigationItem> items;

  /// Id of the selected destination.
  final String value;
  final ValueChanged<String> onChange;
  final CdsColor background;

  /// Draw a hairline above the bar.
  final bool bordered;

  /// Hide labels to show icons only. Each item still reads its label to
  /// screen readers.
  final bool showLabels;

  /// Pad the bottom by the platform's safe area (home indicator).
  final bool respectSafeArea;
  final String accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final bottomInset = respectSafeArea ? MediaQuery.paddingOf(context).bottom : 0.0;
    final tabs = [
      for (final item in items)
        CdsTabValue(id: item.id, label: item.label, disabled: item.disabled, count: item.count, max: item.max),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorOf(background),
        border: bordered
            ? Border(top: BorderSide(color: theme.color.bgLine, width: theme.borderWidth(100)))
            : null,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: theme.space(1),
          end: theme.space(1),
          bottom: bottomInset,
        ),
        child: TabList(
          tabs: tabs,
          activeId: value,
          onChange: onChange,
          equalWidth: true,
          semanticLabel: accessibilityLabel,
          buildTab: (context, slot) => _BottomItem(slot: slot, item: items[slot.index], showLabel: showLabels),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({required this.slot, required this.item, required this.showLabel});

  final TabSlot slot;
  final CdsBottomNavigationItem item;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final color = slot.active ? CdsColor.fgPrimary : CdsColor.fgMuted;
    final count = item.count ?? 0;
    Widget icon = CdsIcon(item.icon, size: CdsIconSize.m, active: slot.active, color: color);
    if (count > 0) {
      icon = Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          PositionedDirectional(
            top: -theme.space(1),
            start: theme.space(1.5),
            child: TabDotCount(count: count, max: item.max),
          ),
        ],
      );
    }
    final label = item.accessibilityLabel ?? (count > 0 ? '${item.label}, $count' : item.label);
    return CdsPressable(
      onPress: slot.onPress,
      disabled: !slot.enabled,
      focusNode: slot.focusNode,
      isButton: false,
      selected: slot.active,
      debounce: Duration.zero,
      minTapTargetSize: 44,
      semanticLabel: label,
      child: slot.semantics(
        ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: theme.space(1), horizontal: theme.space(0.5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: theme.space(0.5),
                children: [
                  icon,
                  if (showLabel)
                    CdsText(item.label, font: CdsFont.legal, color: color, maxLines: 1, align: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
