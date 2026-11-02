import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_tabs.dart';

// Internal building blocks shared by CdsTabs, CdsSegmentedTabs,
// CdsTabbedChips, CdsTabNavigation and CdsBottomNavigation. Not exported.

/// Everything a tab needs to render itself inside a [TabList].
@immutable
class TabSlot {
  const TabSlot({
    required this.tab,
    required this.index,
    required this.active,
    required this.enabled,
    required this.focusNode,
    required this.onPress,
    required this.radio,
  });

  final CdsTabValue tab;
  final int index;
  final bool active;
  final bool enabled;
  final FocusNode focusNode;
  final VoidCallback? onPress;

  /// The list announces itself as a radio group instead of a tab list.
  final bool radio;

  /// Wraps [child] in the semantics a tab exposes. Place it inside the
  /// [CdsPressable] so the role merges into the pressable's node.
  Widget semantics(Widget child) {
    if (radio) {
      return Semantics(inMutuallyExclusiveGroup: true, checked: active, child: child);
    }
    return Semantics(role: SemanticsRole.tab, child: child);
  }
}

/// Where the active indicator should sit, in the tab list's own coordinates.
@immutable
class TabIndicatorGeometry {
  const TabIndicatorGeometry({required this.x, required this.width, required this.animate});

  /// Distance from the left edge (not the start edge) of the list.
  final double x;
  final double width;

  /// False while the indicator should track a gesture or a layout change
  /// exactly instead of springing.
  final bool animate;
}

typedef TabSlotBuilder = Widget Function(BuildContext context, TabSlot slot);
typedef TabIndicatorBuilder = Widget Function(BuildContext context, TabIndicatorGeometry geometry);

/// A row of tabs with a measured, animated active indicator, keyboard
/// navigation (arrow keys, Home, End), tab list semantics, optional
/// horizontal scrolling and optional [PageController] tracking.
class TabList extends StatefulWidget {
  const TabList({
    super.key,
    required this.tabs,
    required this.activeId,
    required this.onChange,
    required this.buildTab,
    this.buildIndicator,
    this.indicatorBehind = false,
    this.disabled = false,
    this.gap = 0,
    this.equalWidth = false,
    this.scrollable = false,
    this.overflowGradient = false,
    this.background,
    this.borderRadius,
    this.padding = EdgeInsetsDirectional.zero,
    this.pageController,
    this.semanticLabel,
    this.radio = false,
    this.haptics = true,
  });

  final List<CdsTabValue> tabs;
  final String? activeId;
  final ValueChanged<String> onChange;
  final TabSlotBuilder buildTab;
  final TabIndicatorBuilder? buildIndicator;
  final bool indicatorBehind;
  final bool disabled;

  /// Gap between tabs in logical pixels.
  final double gap;
  final bool equalWidth;
  final bool scrollable;

  /// Fade the trailing edge while more tabs are offscreen.
  final bool overflowGradient;
  final CdsColor? background;
  final int? borderRadius;
  final EdgeInsetsGeometry padding;
  final PageController? pageController;
  final String? semanticLabel;
  final bool radio;
  final bool haptics;

  @override
  State<TabList> createState() => _TabListState();
}

class _TabListState extends State<TabList> {
  final GlobalKey _stackKey = GlobalKey();
  final List<GlobalKey> _keys = [];
  final List<FocusNode> _nodes = [];
  ScrollController? _scroll;
  List<Rect>? _rects;
  bool _measureScheduled = false;
  bool _animateIndicator = false;
  double? _page;
  bool _offscreenEnd = false;

  int get _activeIndex => widget.activeId == null ? -1 : widget.tabs.indexWhere((t) => t.id == widget.activeId);

  @override
  void initState() {
    super.initState();
    _syncTabs();
    if (widget.scrollable) _scroll = ScrollController()..addListener(_onScroll);
    widget.pageController?.addListener(_onPage);
  }

  @override
  void didUpdateWidget(TabList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTabs();
    if (oldWidget.pageController != widget.pageController) {
      oldWidget.pageController?.removeListener(_onPage);
      widget.pageController?.addListener(_onPage);
      _page = null;
    }
    if (widget.scrollable && _scroll == null) _scroll = ScrollController()..addListener(_onScroll);
    if (oldWidget.activeId != widget.activeId) {
      _animateIndicator = !CdsMotion.reduceMotion(context);
      if (widget.scrollable) _scheduleScrollToActive();
    }
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_onPage);
    _scroll?.dispose();
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncTabs() {
    while (_nodes.length < widget.tabs.length) {
      _nodes.add(FocusNode(debugLabel: 'CdsTab ${_nodes.length}'));
      _keys.add(GlobalKey());
    }
    while (_nodes.length > widget.tabs.length) {
      _nodes.removeLast().dispose();
      _keys.removeLast();
    }
  }

  void _select(int index) {
    final tab = widget.tabs[index];
    if (tab.id == widget.activeId) return;
    if (widget.haptics) cdsHaptic(CdsHapticFeedback.selection);
    widget.onChange(tab.id);
  }

  bool _enabled(int index) => !widget.disabled && !widget.tabs[index].disabled;

  int? _step(int from, int delta) {
    for (var i = from + delta; i >= 0 && i < widget.tabs.length; i += delta) {
      if (_enabled(i)) return i;
    }
    return null;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final focused = _nodes.indexWhere((n) => n.hasFocus);
    if (focused < 0) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    int? target;
    if (key == LogicalKeyboardKey.arrowRight) {
      target = _step(focused, rtl ? -1 : 1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      target = _step(focused, rtl ? 1 : -1);
    } else if (key == LogicalKeyboardKey.home) {
      target = _step(-1, 1);
    } else if (key == LogicalKeyboardKey.end) {
      target = _step(widget.tabs.length, -1);
    } else {
      return KeyEventResult.ignored;
    }
    if (target != null) {
      _select(target);
      _nodes[target].requestFocus();
    }
    return KeyEventResult.handled;
  }

  void _scheduleMeasure() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (mounted) _measure();
    });
  }

  void _measure() {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;
    final rects = <Rect>[];
    for (final key in _keys) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      rects.add(box.localToGlobal(Offset.zero, ancestor: stackBox) & box.size);
    }
    if (!listEquals(rects, _rects)) {
      final first = _rects == null;
      setState(() {
        _rects = rects;
        _animateIndicator = false;
      });
      if (first && widget.scrollable) _scheduleScrollToActive(animate: false);
    }
    _onScroll();
  }

  void _onScroll() {
    final scroll = _scroll;
    if (scroll == null || !scroll.hasClients || !widget.overflowGradient) return;
    final position = scroll.position;
    final offscreen = position.hasContentDimensions && position.pixels < position.maxScrollExtent - 0.5;
    if (offscreen != _offscreenEnd) setState(() => _offscreenEnd = offscreen);
  }

  void _scheduleScrollToActive({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final index = _activeIndex;
      if (index < 0 || index >= _keys.length) return;
      final ctx = _keys[index].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: animate ? CdsMotion.duration(context, CdsDurations.moderate2) : Duration.zero,
        curve: CdsCurves.global,
      );
    });
  }

  void _onPage() {
    final controller = widget.pageController;
    if (controller == null || !controller.hasClients || controller.positions.length != 1) return;
    final position = controller.position;
    if (!position.hasContentDimensions) return;
    final page = controller.page;
    if (page == null) return;
    final atRest = !position.isScrollingNotifier.value && (page - page.roundToDouble()).abs() < 0.001;
    final next = atRest ? null : page;
    if (next == _page) return;
    setState(() {
      _page = next;
      // Settling back onto the active tab after a drag: spring the last bit.
      if (next == null) _animateIndicator = !CdsMotion.reduceMotion(context);
    });
  }

  TabIndicatorGeometry? _geometry() {
    final rects = _rects;
    if (rects == null || rects.isEmpty) return null;
    final page = _page;
    if (page != null) {
      final lower = page.floor().clamp(0, rects.length - 1);
      final upper = page.ceil().clamp(0, rects.length - 1);
      final t = (page - page.floor()).clamp(0.0, 1.0);
      final rect = Rect.lerp(rects[lower], rects[upper], t)!;
      return TabIndicatorGeometry(x: rect.left, width: rect.width, animate: false);
    }
    final index = _activeIndex;
    if (index < 0 || index >= rects.length) return null;
    final rect = rects[index];
    return TabIndicatorGeometry(x: rect.left, width: rect.width, animate: _animateIndicator);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    _scheduleMeasure();
    final active = _activeIndex;
    final gap = widget.gap;

    final children = <Widget>[];
    for (var i = 0; i < widget.tabs.length; i++) {
      final enabled = _enabled(i);
      Widget tab = KeyedSubtree(
        key: _keys[i],
        child: widget.buildTab(
          context,
          TabSlot(
            tab: widget.tabs[i],
            index: i,
            active: i == active,
            enabled: enabled,
            focusNode: _nodes[i],
            onPress: enabled ? () => _select(i) : null,
            radio: widget.radio,
          ),
        ),
      );
      if (widget.equalWidth) tab = Expanded(child: tab);
      children.add(tab);
    }

    Widget row = Row(
      mainAxisSize: widget.equalWidth ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: children,
    );
    row = IntrinsicHeight(child: row);
    row = NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _scheduleMeasure();
        return true;
      },
      child: SizeChangedLayoutNotifier(child: row),
    );

    final geometry = widget.buildIndicator == null ? null : _geometry();
    final indicator = geometry == null
        ? null
        : Positioned.fill(
            child: IgnorePointer(child: ExcludeSemantics(child: widget.buildIndicator!(context, geometry))),
          );

    Widget content = Stack(
      key: _stackKey,
      children: [
        if (indicator != null && widget.indicatorBehind) indicator,
        row,
        if (indicator != null && !widget.indicatorBehind) indicator,
      ],
    );

    content = Semantics(
      container: true,
      explicitChildNodes: true,
      role: widget.radio ? SemanticsRole.radioGroup : SemanticsRole.tabBar,
      label: widget.semanticLabel,
      child: content,
    );

    content = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: content,
    );

    if (widget.padding != EdgeInsetsDirectional.zero) content = Padding(padding: widget.padding, child: content);

    if (widget.background != null || widget.borderRadius != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          color: widget.background == null ? null : theme.colorOf(widget.background!),
          borderRadius: widget.borderRadius == null ? null : BorderRadius.circular(theme.radius(widget.borderRadius!)),
        ),
        child: content,
      );
    }

    // Tabs that keep their natural width scroll when they outgrow the space
    // (narrow screens, large text) instead of overflowing.
    if (widget.scrollable || !widget.equalWidth) {
      content = SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: content,
      );
      if (widget.overflowGradient) {
        content = Stack(
          children: [
            content,
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              width: theme.space(4),
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _offscreenEnd ? 1 : 0,
                  duration: CdsMotion.duration(context, CdsDurations.fast3),
                  child: _OverflowGradient(color: theme.color.bg),
                ),
              ),
            ),
          ],
        );
      }
    }
    return content;
  }
}

class _OverflowGradient extends StatelessWidget {
  const _OverflowGradient({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: rtl ? Alignment.centerRight : Alignment.centerLeft,
          end: rtl ? Alignment.centerLeft : Alignment.centerRight,
          colors: [color.withValues(alpha: 0), color],
        ),
      ),
    );
  }
}

/// Springs a horizontal span (x and width) toward a target, starting from
/// wherever it currently is so a new target mid-flight never jumps.
mixin SpanSpring<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController spanX = AnimationController.unbounded(vsync: this);
  late final AnimationController spanWidth = AnimationController.unbounded(vsync: this);
  bool _spanInitialized = false;

  Listenable get span => Listenable.merge([spanX, spanWidth]);

  void moveSpan(double x, double width, {required bool animate}) {
    if (!_spanInitialized || !animate || CdsMotion.reduceMotion(context)) {
      _spanInitialized = true;
      spanX.value = x;
      spanWidth.value = width;
      return;
    }
    if (spanX.value != x) CdsMotion.springTo(spanX, x, velocity: spanX.velocity);
    if (spanWidth.value != width) CdsMotion.springTo(spanWidth, width, velocity: spanWidth.velocity);
  }

  @override
  void dispose() {
    spanX.dispose();
    spanWidth.dispose();
    super.dispose();
  }
}

/// The count badge CDS shows next to tab labels (`DotCount`): a 24px pill on
/// `bgNegative` with caption text, truncated to `max+`.
class TabDotCount extends StatelessWidget {
  const TabDotCount({super.key, required this.count, this.max});

  final int count;
  final int? max;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final limit = max ?? 99;
    final text = count <= limit ? '$count' : '$limit+';
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(0.75)),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.color.bgNegative,
        borderRadius: BorderRadius.circular(theme.radius(400)),
        border: Border.all(color: theme.color.bgSecondary, width: theme.borderWidth(100)),
      ),
      child: CdsText(text, font: CdsFont.caption, color: CdsColor.fgInverse, maxLines: 1),
    );
  }
}
