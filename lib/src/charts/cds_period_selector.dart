import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// One option in a [CdsPeriodSelector].
@immutable
class CdsPeriodSelectorTab {
  const CdsPeriodSelectorTab({required this.id, required this.label, this.labelWidget, this.semanticLabel});

  /// Value passed to `onChange` and matched against `activeTab`.
  final String id;

  /// Visible text, such as `1D`.
  final String label;

  /// Replaces the text, for example with [CdsLiveTabLabel].
  final Widget? labelWidget;

  /// Spoken name, such as `1 day`. Defaults to the CDS period names for
  /// `1H`, `1D`, `1W`, `1M` and `1Y`, otherwise [label].
  final String? semanticLabel;
}

/// Spoken names CDS uses for common period labels.
const Map<String, String> cdsPeriodLabelMap = {
  '1H': '1 hour',
  '1D': '1 day',
  '1W': '1 week',
  '1M': '1 month',
  '1Y': '1 year',
};

/// Chart period tabs (1H, 1D, 1W...) with a pill that slides to the active
/// tab. Controlled: pass [activeTab] and update it in [onChange].
///
/// ```dart
/// CdsPeriodSelector(
///   tabs: const [
///     CdsPeriodSelectorTab(id: '1D', label: '1D'),
///     CdsPeriodSelectorTab(id: '1W', label: '1W'),
///     CdsPeriodSelectorTab(id: '1M', label: '1M'),
///   ],
///   activeTab: period,
///   onChange: (id) => setState(() => period = id),
/// )
/// ```
class CdsPeriodSelector extends StatefulWidget {
  const CdsPeriodSelector({
    super.key,
    required this.tabs,
    required this.activeTab,
    required this.onChange,
    this.background = CdsColor.transparent,
    this.activeBackground = CdsColor.bgPrimaryWash,
    this.color = CdsColor.fg,
    this.activeColor = CdsColor.fgPrimary,
    this.font = CdsFont.label1,
    this.block = true,
    this.gap = 0,
    this.disabled = false,
    this.semanticLabel,
  });

  final List<CdsPeriodSelectorTab> tabs;

  /// Id of the selected tab, or null for none.
  final String? activeTab;
  final ValueChanged<String> onChange;
  final CdsColor background;

  /// Color of the sliding pill behind the active tab.
  final CdsColor activeBackground;

  /// Inactive label color.
  final CdsColor color;
  final CdsColor activeColor;
  final CdsFont font;

  /// Spread tabs across the full width. When false, tabs hug their labels
  /// and are separated by [gap].
  final bool block;

  /// Space token between tabs when [block] is false.
  final double gap;
  final bool disabled;

  /// Label for the group, read before the tabs.
  final String? semanticLabel;

  @override
  State<CdsPeriodSelector> createState() => _CdsPeriodSelectorState();
}

class _CdsPeriodSelectorState extends State<CdsPeriodSelector> with SingleTickerProviderStateMixin {
  final GlobalKey _stackKey = GlobalKey();
  final Map<String, GlobalKey> _tabKeys = {};
  final Map<String, FocusNode> _focusNodes = {};
  late final AnimationController _slide = AnimationController.unbounded(vsync: this, value: 1);
  Rect? _from;
  Rect? _to;

  @override
  void dispose() {
    _slide.dispose();
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  GlobalKey _keyFor(String id) => _tabKeys.putIfAbsent(id, GlobalKey.new);
  FocusNode _nodeFor(String id) => _focusNodes.putIfAbsent(id, () => FocusNode(debugLabel: 'period $id'));

  Rect? get _current {
    final to = _to;
    if (to == null) return null;
    if (_from == null || _slide.value >= 1) return to;
    return Rect.lerp(_from, to, _slide.value.clamp(0.0, 1.0));
  }

  void _measure(Duration _) {
    if (!mounted) return;
    final id = widget.activeTab;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final tabBox = id == null ? null : _tabKeys[id]?.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;
    if (tabBox == null || !tabBox.hasSize) {
      if (_to != null) setState(() => _to = _from = null);
      return;
    }
    final target = tabBox.localToGlobal(Offset.zero, ancestor: stackBox) & tabBox.size;
    if (target == _to) return;
    setState(() {
      final animate = _to != null && !CdsMotion.reduceMotion(context);
      _from = animate ? _current : null;
      _to = target;
      if (animate) {
        _slide.value = 0;
        CdsMotion.springTo(_slide, 1);
      } else {
        _slide.value = 1;
      }
    });
  }

  void _select(int delta) {
    final tabs = widget.tabs;
    if (tabs.isEmpty || widget.disabled) return;
    final current = tabs.indexWhere((t) => t.id == widget.activeTab);
    final next = ((current < 0 ? 0 : current) + delta).clamp(0, tabs.length - 1);
    final id = tabs[next].id;
    _nodeFor(id).requestFocus();
    if (id != widget.activeTab) {
      cdsHaptic(CdsHapticFeedback.selection);
      widget.onChange(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(_measure);
    final theme = context.cds;
    final measured = _to != null;
    final pillHeight =
        MediaQuery.textScalerOf(context).scale(theme.typography[widget.font].lineHeight) + theme.space(2);
    final tabs = [
      for (final tab in widget.tabs)
        _PeriodTab(
          key: _keyFor(tab.id),
          tab: tab,
          active: tab.id == widget.activeTab,
          // Until the pill has been measured, the active tab paints its own background.
          showBackground: !measured && tab.id == widget.activeTab,
          activeBackground: widget.activeBackground,
          color: widget.color,
          activeColor: widget.activeColor,
          font: widget.font,
          disabled: widget.disabled,
          focusNode: _nodeFor(tab.id),
          onPress: () {
            if (tab.id != widget.activeTab) widget.onChange(tab.id);
          },
        ),
    ];
    // Fills the width when the periods fit; scrolls horizontally when they do
    // not (narrow screens, large text) so targets never shrink or overflow.
    final row = widget.block
        ? LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: tabs),
              ),
            ),
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisSize: MainAxisSize.min, spacing: theme.space(widget.gap), children: tabs),
          );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowLeft): _StepIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowRight): _StepIntent(1),
        },
        child: Actions(
          actions: {
            _StepIntent: CallbackAction<_StepIntent>(
              onInvoke: (i) {
                _select(Directionality.of(context) == TextDirection.rtl ? -i.delta : i.delta);
                return null;
              },
            ),
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorOf(widget.background),
              borderRadius: BorderRadius.circular(theme.radius(1000)),
            ),
            child: Stack(
              key: _stackKey,
              children: [
                AnimatedBuilder(
                  animation: _slide,
                  builder: (context, _) {
                    final rect = _current;
                    if (rect == null) return const SizedBox.shrink();
                    return Positioned.fromRect(
                      rect: rect,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: rect.width,
                            height: pillHeight.clamp(0.0, rect.height),
                            decoration: BoxDecoration(
                              color: theme.colorOf(widget.activeBackground),
                              borderRadius: BorderRadius.circular(theme.radius(1000)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                row,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIntent extends Intent {
  const _StepIntent(this.delta);

  final int delta;
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    super.key,
    required this.tab,
    required this.active,
    required this.showBackground,
    required this.activeBackground,
    required this.color,
    required this.activeColor,
    required this.font,
    required this.disabled,
    required this.focusNode,
    required this.onPress,
  });

  final CdsPeriodSelectorTab tab;
  final bool active;
  final bool showBackground;
  final CdsColor activeBackground;
  final CdsColor color;
  final CdsColor activeColor;
  final CdsFont font;
  final bool disabled;
  final FocusNode focusNode;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final target = theme.colorOf(active ? activeColor : color);
    return CdsPressable(
      onPress: onPress,
      disabled: disabled,
      selected: active,
      borderRadius: 1000,
      background: showBackground ? activeBackground : CdsColor.transparent,
      feedback: CdsHapticFeedback.selection,
      debounce: Duration.zero,
      minTapTargetSize: 44,
      focusNode: focusNode,
      semanticLabel: tab.semanticLabel ?? cdsPeriodLabelMap[tab.label] ?? tab.label,
      excludeChildSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.space(2), vertical: theme.space(1)),
        child:
            tab.labelWidget ??
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: target),
              duration: CdsMotion.duration(context, CdsDurations.fast3),
              curve: CdsCurves.global,
              builder: (context, c, _) => CdsText(tab.label, font: font, dangerouslySetColor: c ?? target),
            ),
      ),
    );
  }
}

/// A "LIVE" tab label with a dot, for a real-time period in [CdsPeriodSelector].
class CdsLiveTabLabel extends StatelessWidget {
  const CdsLiveTabLabel({
    super.key,
    this.label = 'LIVE',
    this.color = CdsColor.fgNegative,
    this.font = CdsFont.label1,
    this.hideDot = false,
  });

  final String label;
  final CdsColor color;
  final CdsFont font;
  final bool hideDot;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final dot = theme.space(1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!hideDot)
          Container(
            width: dot,
            height: dot,
            margin: EdgeInsetsDirectional.only(end: theme.space(0.75)),
            decoration: BoxDecoration(color: theme.colorOf(color), shape: BoxShape.circle),
          ),
        CdsText(label, font: font, color: color),
      ],
    );
  }
}
