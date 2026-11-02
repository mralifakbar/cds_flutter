import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import 'cds_tabs.dart';
import 'tab_list.dart';

/// Pill-shaped tabs on a tinted track. The active pill slides between
/// options with a spring and the label colors cross-fade.
///
/// ```dart
/// CdsSegmentedTabs(
///   accessibilityLabel: 'Order type',
///   tabs: const [
///     CdsTabValue(id: 'buy', label: 'Buy'),
///     CdsTabValue(id: 'sell', label: 'Sell'),
///   ],
///   activeTab: side,
///   onChange: (id) => setState(() => side = id),
/// )
/// ```
///
/// Set [equalWidth] to stretch the control to its parent and give every tab
/// the same width.
class CdsSegmentedTabs extends StatelessWidget {
  const CdsSegmentedTabs({
    super.key,
    required this.tabs,
    required this.activeTab,
    required this.onChange,
    this.disabled = false,
    this.equalWidth = false,
    this.color = CdsColor.fg,
    this.activeColor = CdsColor.fgInverse,
    this.background = CdsColor.bgSecondary,
    this.activeBackground = CdsColor.bgInverse,
    this.borderRadius = 700,
    this.font = CdsFont.headline,
    this.gap = 0,
    this.pageController,
    this.tabBuilder,
    this.accessibilityLabel,
  });

  final List<CdsTabValue> tabs;

  /// Id of the active tab. Null shows no pill.
  final String? activeTab;
  final ValueChanged<String> onChange;
  final bool disabled;

  /// Fill the parent's width and split it evenly between tabs.
  final bool equalWidth;

  /// Inactive label color.
  final CdsColor color;

  /// Active label color.
  final CdsColor activeColor;

  /// Track color.
  final CdsColor background;

  /// Active pill color.
  final CdsColor activeBackground;

  /// Track radius token.
  final int borderRadius;
  final CdsFont font;

  /// Space token between tabs.
  final double gap;

  /// Lets the pill track a `PageView` drag.
  final PageController? pageController;

  /// Replaces each tab's label content.
  final CdsTabContentBuilder? tabBuilder;
  final String? accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return TabList(
      tabs: tabs,
      activeId: activeTab,
      onChange: onChange,
      disabled: disabled,
      equalWidth: equalWidth,
      gap: theme.space(gap),
      background: background,
      borderRadius: borderRadius,
      pageController: pageController,
      semanticLabel: accessibilityLabel,
      indicatorBehind: true,
      buildTab: (context, slot) => _SegmentedTab(
        slot: slot,
        color: color,
        activeColor: activeColor,
        font: font,
        builder: tabBuilder,
      ),
      buildIndicator: (context, g) => _SegmentedIndicator(geometry: g, color: activeBackground),
    );
  }
}

class _SegmentedTab extends StatelessWidget {
  const _SegmentedTab({
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
    final target = theme.colorOf(slot.active ? activeColor : color);
    final content = builder?.call(context, tab, slot.active) ??
        TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: target),
          duration: CdsMotion.duration(context, CdsDurations.fast3),
          curve: CdsCurves.global,
          builder: (context, value, _) => Text(
            tab.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.typography[font].toTextStyle(color: value),
          ),
        );
    return CdsPressable(
      onPress: slot.onPress,
      disabled: !slot.enabled,
      focusNode: slot.focusNode,
      isButton: false,
      selected: slot.active,
      borderRadius: 1000,
      debounce: Duration.zero,
      semanticLabel: tab.accessibilityLabel,
      child: slot.semantics(
        ConstrainedBox(
          // CDS draws 40px pills; 44 keeps the whole pill inside the minimum tap target.
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(2), vertical: theme.space(1)),
            child: Center(
              widthFactor: 1,
              child: tab.accessibilityLabel == null ? content : ExcludeSemantics(child: content),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentedIndicator extends StatefulWidget {
  const _SegmentedIndicator({required this.geometry, required this.color});

  final TabIndicatorGeometry geometry;
  final CdsColor color;

  @override
  State<_SegmentedIndicator> createState() => _SegmentedIndicatorState();
}

class _SegmentedIndicatorState extends State<_SegmentedIndicator> with TickerProviderStateMixin, SpanSpring {
  @override
  void initState() {
    super.initState();
    moveSpan(widget.geometry.x, widget.geometry.width, animate: false);
  }

  @override
  void didUpdateWidget(_SegmentedIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final g = widget.geometry;
    if (oldWidget.geometry.x != g.x || oldWidget.geometry.width != g.width || !g.animate) {
      moveSpan(g.x, g.width, animate: g.animate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final color = theme.colorOf(widget.color);
    return AnimatedBuilder(
      animation: span,
      builder: (context, _) => Stack(
        children: [
          Positioned(
            left: spanX.value,
            width: spanWidth.value,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(theme.radius(1000))),
            ),
          ),
        ],
      ),
    );
  }
}
