import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_tab_indicator.dart';
import 'tab_list.dart';

/// One tab in [CdsTabs], [CdsSegmentedTabs], [CdsTabbedChips] or
/// [CdsTabNavigation]. Mirrors the CDS `TabValue` shape.
///
/// ```dart
/// const CdsTabValue(id: 'inbox', label: 'Inbox', count: 3)
/// ```
@immutable
class CdsTabValue {
  const CdsTabValue({
    required this.id,
    required this.label,
    this.disabled = false,
    this.count,
    this.max,
    this.accessibilityLabel,
  });

  /// Unique within one tab list. Passed to `onChange`.
  final String id;
  final String label;
  final bool disabled;

  /// Shows a count badge next to the label when greater than zero.
  final int? count;

  /// Counts above this render as `max+`. Defaults to 99.
  final int? max;

  /// Read by screen readers instead of [label].
  final String? accessibilityLabel;

  @override
  bool operator ==(Object other) =>
      other is CdsTabValue &&
      other.id == id &&
      other.label == label &&
      other.disabled == disabled &&
      other.count == count &&
      other.max == max &&
      other.accessibilityLabel == accessibilityLabel;

  @override
  int get hashCode => Object.hash(id, label, disabled, count, max, accessibilityLabel);
}

/// Builds custom content for one tab. Receives the tab and whether it is the
/// active one; the tab list still provides the pressable, focus and semantics.
typedef CdsTabContentBuilder = Widget Function(BuildContext context, CdsTabValue tab, bool active);

/// Builds a custom active indicator. [x] is measured from the left edge of the
/// tab list, [width] is the active tab's width. Return [CdsTabIndicator] or
/// any widget that fills the tab list's bounds.
typedef CdsTabsIndicatorBuilder = Widget Function(BuildContext context, double x, double width, bool animate);

/// A row of text tabs with an underline that slides to the active tab.
///
/// Controlled: pass [activeTab] and update it in [onChange].
///
/// ```dart
/// CdsTabs(
///   accessibilityLabel: 'Portfolio sections',
///   tabs: const [
///     CdsTabValue(id: 'crypto', label: 'Crypto'),
///     CdsTabValue(id: 'nfts', label: 'NFTs'),
///   ],
///   activeTab: tab,
///   onChange: (id) => setState(() => tab = id),
/// )
/// ```
///
/// The underline springs from wherever it is, so rapid taps never jump. Pass
/// the [pageController] of a `PageView` showing the tab panels and the
/// underline follows the page drag 1:1; update [activeTab] from
/// `PageView.onPageChanged` so the selection stays in sync.
///
/// For pill-shaped controls use [CdsSegmentedTabs]; for a horizontally
/// scrolling top-level tab bar use [CdsTabNavigation].
class CdsTabs extends StatelessWidget {
  const CdsTabs({
    super.key,
    required this.tabs,
    required this.activeTab,
    required this.onChange,
    this.disabled = false,
    this.color = CdsColor.fg,
    this.activeColor = CdsColor.fgPrimary,
    this.activeBackground = CdsColor.bgPrimary,
    this.background,
    this.font = CdsFont.headline,
    this.gap = 4,
    this.borderRadius,
    this.pageController,
    this.tabBuilder,
    this.indicatorBuilder,
    this.accessibilityLabel,
  });

  final List<CdsTabValue> tabs;

  /// Id of the active tab. Null shows no active tab and no underline.
  final String? activeTab;

  /// Called with the id of the tab the user picked.
  final ValueChanged<String> onChange;

  /// Disables every tab and dims the list.
  final bool disabled;

  /// Inactive label color.
  final CdsColor color;

  /// Active label color.
  final CdsColor activeColor;

  /// Underline color.
  final CdsColor activeBackground;

  /// Fill behind the whole tab row.
  final CdsColor? background;
  final CdsFont font;

  /// Space token between tabs (4 = 32px).
  final double gap;
  final int? borderRadius;

  /// Lets the underline track a `PageView` drag.
  final PageController? pageController;

  /// Replaces each tab's label content (CDS `TabComponent`).
  final CdsTabContentBuilder? tabBuilder;

  /// Replaces the underline (CDS `TabsActiveIndicatorComponent`).
  final CdsTabsIndicatorBuilder? indicatorBuilder;

  /// Names the tab list for screen readers.
  final String? accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return TabList(
      tabs: tabs,
      activeId: activeTab,
      onChange: onChange,
      disabled: disabled,
      gap: theme.space(gap),
      background: background,
      borderRadius: borderRadius,
      pageController: pageController,
      semanticLabel: accessibilityLabel,
      buildTab: (context, slot) => _DefaultTab(
        slot: slot,
        color: color,
        activeColor: activeColor,
        font: font,
        builder: tabBuilder,
      ),
      buildIndicator: (context, g) {
        if (indicatorBuilder != null) return indicatorBuilder!(context, g.x, g.width, g.animate);
        return Align(
          alignment: Alignment.bottomLeft,
          child: CdsTabIndicator(x: g.x, width: g.width, background: activeBackground, animate: g.animate),
        );
      },
    );
  }
}

class _DefaultTab extends StatelessWidget {
  const _DefaultTab({
    required this.slot,
    required this.color,
    required this.activeColor,
    required this.font,
    required this.builder,
  });

  final TabSlot slot;
  final CdsColor color;
  final CdsColor activeColor;
  final CdsFont font;
  final CdsTabContentBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final tab = slot.tab;
    final count = tab.count ?? 0;
    final content = builder?.call(context, tab, slot.active) ??
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.space(0.5),
          children: [
            Flexible(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: theme.space(2)),
                child: CdsText(tab.label, font: font, color: slot.active ? activeColor : color, maxLines: 1),
              ),
            ),
            if (count > 0) TabDotCount(count: count, max: tab.max),
          ],
        );
    return CdsPressable(
      onPress: slot.onPress,
      disabled: !slot.enabled,
      focusNode: slot.focusNode,
      isButton: false,
      selected: slot.active,
      noScaleOnPress: true,
      debounce: Duration.zero,
      minTapTargetSize: 44,
      semanticLabel: tab.accessibilityLabel,
      child: slot.semantics(tab.accessibilityLabel == null ? content : ExcludeSemantics(child: content)),
    );
  }
}
