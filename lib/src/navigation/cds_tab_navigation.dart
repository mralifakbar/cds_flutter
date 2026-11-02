import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import 'cds_tab_indicator.dart';
import 'cds_tab_label.dart';
import 'cds_tabs.dart';
import 'tab_list.dart';

/// How a [CdsTabNavigation] announces itself to assistive technology.
enum CdsTabNavigationRole { tablist, radiogroup }

/// The top-level tab bar of a screen: a horizontally scrolling row of
/// [CdsTabLabel]s with a [CdsTabIndicator] under the active one.
///
/// ```dart
/// CdsTabNavigation(
///   accessibilityLabel: 'Home sections',
///   tabs: const [
///     CdsTabValue(id: 'foryou', label: 'For you'),
///     CdsTabValue(id: 'portfolio', label: 'Portfolio'),
///     CdsTabValue(id: 'explore', label: 'Explore'),
///   ],
///   value: section,
///   onChange: (id) => setState(() => section = id),
/// )
/// ```
///
/// Overflowing tabs scroll, the active tab scrolls into view, and the trailing
/// edge fades while more tabs are offscreen. Connect [pageController] to let
/// the indicator follow a `PageView` swipe. For a bottom tab bar on phones use
/// [CdsBottomNavigation].
class CdsTabNavigation extends StatelessWidget {
  const CdsTabNavigation({
    super.key,
    required this.tabs,
    required this.onChange,
    this.value,
    this.variant = CdsTabLabelVariant.primary,
    this.background = CdsColor.bg,
    this.gap = 4,
    this.paddingX = 0,
    this.role = CdsTabNavigationRole.tablist,
    this.pageController,
    this.tabBuilder,
    this.accessibilityLabel,
  });

  final List<CdsTabValue> tabs;

  /// Id of the active tab. Defaults to the first tab, like CDS.
  final String? value;
  final ValueChanged<String> onChange;

  /// The secondary variant has no indicator and is deprecated in CDS.
  final CdsTabLabelVariant variant;
  final CdsColor background;

  /// Space token between tabs.
  final double gap;

  /// Space token inset at both ends of the scrolling row.
  final double paddingX;
  final CdsTabNavigationRole role;
  final PageController? pageController;

  /// Replaces each tab's label (CDS `Component`).
  final CdsTabContentBuilder? tabBuilder;
  final String? accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final primary = variant == CdsTabLabelVariant.primary;
    return ColoredBox(
      color: theme.colorOf(background),
      child: TabList(
        tabs: tabs,
        activeId: value ?? (tabs.isEmpty ? null : tabs.first.id),
        onChange: onChange,
        gap: theme.space(gap),
        scrollable: true,
        overflowGradient: true,
        padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(paddingX)),
        pageController: pageController,
        semanticLabel: accessibilityLabel,
        radio: role == CdsTabNavigationRole.radiogroup,
        buildTab: (context, slot) {
          final tab = slot.tab;
          final content = tabBuilder?.call(context, tab, slot.active) ??
              CdsTabLabel(tab.label, active: slot.active, variant: variant, count: tab.count ?? 0, max: tab.max);
          return CdsPressable(
            onPress: slot.onPress,
            disabled: !slot.enabled,
            focusNode: slot.focusNode,
            isButton: false,
            selected: role == CdsTabNavigationRole.tablist ? slot.active : null,
            noScaleOnPress: true,
            debounce: Duration.zero,
            minTapTargetSize: 44,
            semanticLabel: tab.accessibilityLabel,
            child: slot.semantics(tab.accessibilityLabel == null ? content : ExcludeSemantics(child: content)),
          );
        },
        buildIndicator: primary
            ? (context, g) => Align(
                  alignment: Alignment.bottomLeft,
                  child: CdsTabIndicator(x: g.x, width: g.width, animate: g.animate),
                )
            : null,
      ),
    );
  }
}
