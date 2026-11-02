import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../buttons/cds_button_variant.dart';
import '../buttons/cds_icon_button.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_page_indicator.dart';

/// How a [CdsCarousel] groups items into pages for navigation, pagination
/// and snapping.
enum CdsCarouselSnapMode {
  /// Each item is its own page.
  item,

  /// Items that fit in the viewport together form one page.
  page,
}

/// How a [CdsCarousel] responds to drags.
enum CdsCarouselDrag {
  /// Dragging is off; use the buttons, dots or keyboard.
  none,

  /// Glides with momentum and stops wherever it lands.
  free,

  /// Settles on the page the gesture was heading toward.
  snap,
}

String _defaultPaginationLabel(int pageIndex) => 'Go to page ${pageIndex + 1}';

/// Drives a [CdsCarousel] from outside and reports its page.
///
/// ```dart
/// final controller = CdsCarouselController();
/// CdsCarousel(controller: controller, children: cards);
/// controller.goToPage(2);
/// ```
class CdsCarouselController extends ChangeNotifier {
  _CdsCarouselState? _state;

  /// Zero-based index of the current page. 0 before the carousel lays out.
  int get activePageIndex => _state?._activePage ?? 0;

  /// Number of pages, which depends on layout. 0 before the carousel lays out.
  int get totalPages => _state?._pageOffsets.length ?? 0;

  /// Animates to [pageIndex], clamped to the available pages.
  void goToPage(int pageIndex) => _state?._goToPage(pageIndex);

  void _attach(_CdsCarouselState state) => _state = state;

  void _detach(_CdsCarouselState state) {
    if (_state == state) _state = null;
  }

  void _notify() => notifyListeners();
}

/// A horizontally paged row of items with optional title, previous/next
/// buttons and dot pagination.
///
/// ```dart
/// CdsCarousel(
///   title: 'Explore',
///   itemWidth: 280,
///   onChangePage: (page) => debugPrint('page $page'),
///   children: [for (final asset in assets) AssetCard(asset)],
/// )
/// ```
///
/// Dragging follows the finger, stretches with resistance past the first and
/// last page, and on release settles where the gesture was heading, carrying
/// the finger's velocity into the spring. Left and Right arrows page when the
/// carousel has focus.
///
/// [autoplay] is off by default. When on, it advances every
/// [autoplayInterval], stops for good as soon as the user drags, hovers,
/// focuses or presses a control (until they press play), and never runs
/// under reduced motion.
class CdsCarousel extends StatefulWidget {
  const CdsCarousel({
    super.key,
    required this.children,
    this.itemWidth,
    this.gap = 1,
    this.snapMode = CdsCarouselSnapMode.page,
    this.drag = CdsCarouselDrag.snap,
    this.initialPage = 0,
    this.title,
    this.hideNavigation = false,
    this.hidePagination = false,
    this.onChangePage,
    this.onDragStart,
    this.onDragEnd,
    this.autoplay = false,
    this.autoplayInterval = const Duration(milliseconds: 3000),
    this.controller,
    this.accessibilityLabel,
    this.nextPageAccessibilityLabel = 'Next page',
    this.previousPageAccessibilityLabel = 'Previous page',
    this.paginationAccessibilityLabel = _defaultPaginationLabel,
    this.startAutoplayAccessibilityLabel = 'Play Carousel',
    this.stopAutoplayAccessibilityLabel = 'Pause Carousel',
  });

  final List<Widget> children;

  /// Width of each item in logical px. Null makes every item as wide as the
  /// carousel.
  final double? itemWidth;

  /// Space token between items (1 = 8px).
  final double gap;
  final CdsCarouselSnapMode snapMode;
  final CdsCarouselDrag drag;

  /// Page shown on first layout, without animation. Later changes are ignored.
  final int initialPage;

  /// Shown above the carousel in `title3`.
  final String? title;
  final bool hideNavigation;
  final bool hidePagination;

  /// Called with the new page index after a drag, button, dot or key press.
  final ValueChanged<int>? onChangePage;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  /// Advance pages on a timer. Off by default.
  final bool autoplay;
  final Duration autoplayInterval;
  final CdsCarouselController? controller;

  /// Screen reader label for the carousel. Defaults to [title] or `Carousel`.
  final String? accessibilityLabel;
  final String nextPageAccessibilityLabel;
  final String previousPageAccessibilityLabel;
  final String Function(int pageIndex) paginationAccessibilityLabel;
  final String startAutoplayAccessibilityLabel;
  final String stopAutoplayAccessibilityLabel;

  @override
  State<CdsCarousel> createState() => _CdsCarouselState();
}

class _CdsCarouselState extends State<CdsCarousel> with SingleTickerProviderStateMixin {
  late final AnimationController _scroll = AnimationController.unbounded(vsync: this);
  late final FocusNode _focusNode = FocusNode(debugLabel: 'CdsCarousel');

  List<double> _pageOffsets = const [0];
  double _maxScroll = 0;
  double _viewport = 0;
  int _activePage = 0;
  bool _initialized = false;
  bool _dragging = false;
  bool _focused = false;
  double _dragStartScroll = 0;
  double _dragDistance = 0;
  int _dragStartPage = 0;

  /// Set once the user interacts; autoplay stays off until they press play.
  bool _autoplayStopped = false;
  Timer? _autoplayTimer;

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAutoplay();
  }

  @override
  void didUpdateWidget(CdsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (oldWidget.autoplay != widget.autoplay && widget.autoplay) _autoplayStopped = false;
    _syncAutoplay();
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    widget.controller?._detach(this);
    _scroll.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _autoplayAllowed =>
      // TickerMode.of is the API on the minimum supported Flutter (3.35); its
      // replacement, TickerMode.valuesOf, only exists on newer releases.
      // ignore: deprecated_member_use
      widget.autoplay && !CdsMotion.reduceMotion(context) && TickerMode.of(context);

  bool get _autoplayRunning => _autoplayAllowed && !_autoplayStopped && _pageOffsets.length > 1;

  void _syncAutoplay() {
    final shouldRun = _autoplayRunning;
    if (!shouldRun) {
      _autoplayTimer?.cancel();
      _autoplayTimer = null;
    } else {
      _autoplayTimer ??= Timer(widget.autoplayInterval, _onAutoplayTick);
    }
  }

  void _onAutoplayTick() {
    _autoplayTimer = null;
    if (!mounted || !_autoplayRunning) return;
    final next = _activePage + 1 >= _pageOffsets.length ? 0 : _activePage + 1;
    _goToPage(next, fromAutoplay: true);
    _syncAutoplay();
  }

  void _stopAutoplay() {
    if (!widget.autoplay || _autoplayStopped) return;
    setState(() => _autoplayStopped = true);
    _syncAutoplay();
  }

  void _toggleAutoplay() {
    setState(() => _autoplayStopped = !_autoplayStopped);
    _syncAutoplay();
  }

  void _setActivePage(int page) {
    if (page == _activePage) return;
    setState(() => _activePage = page);
    cdsHaptic(CdsHapticFeedback.selection);
    widget.onChangePage?.call(page);
    widget.controller?._notify();
  }

  void _goToPage(int page, {bool fromAutoplay = false}) {
    if (!fromAutoplay) _stopAutoplay();
    final target = page.clamp(0, _pageOffsets.length - 1);
    final offset = _pageOffsets[target];
    if (CdsMotion.reduceMotion(context)) {
      _scroll.value = offset;
    } else {
      CdsMotion.springTo(_scroll, offset, velocity: _scroll.velocity);
    }
    _setActivePage(target);
  }

  // Page breaks follow CDS: in item mode every item starts a page until the
  // remaining items all fit; in page mode a new page starts at the first item
  // that overflows the current viewport.
  void _computeLayout(double viewport, double itemWidth, double gap) {
    final n = widget.children.length;
    final contentWidth = n == 0 ? 0.0 : n * itemWidth + (n - 1) * gap;
    _maxScroll = math.max(0, contentWidth - viewport);
    double x(int i) => i * (itemWidth + gap);
    final offsets = <double>[];
    if (n == 0) {
      offsets.add(0);
    } else if (widget.snapMode == CdsCarouselSnapMode.item) {
      final lastEnd = x(n - 1) + itemWidth;
      var lastStart = n - 1;
      while (lastStart - 1 >= 0 && x(lastStart - 1) + viewport >= lastEnd - 0.5) {
        lastStart--;
      }
      for (var i = 0; i <= lastStart; i++) {
        offsets.add(math.min(x(i), _maxScroll));
      }
    } else {
      offsets.add(0);
      for (var i = 0; i < n; i++) {
        final start = offsets.last;
        if (x(i) + itemWidth > start + viewport + 0.5 && x(i) != start) {
          offsets.add(math.min(x(i), _maxScroll));
        }
      }
    }
    _pageOffsets = offsets;
  }

  int _nearestPage(double offset) {
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < _pageOffsets.length; i++) {
      final d = (offset - _pageOffsets[i]).abs();
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    return best;
  }

  void _onDragStart(DragStartDetails details) {
    _stopAutoplay();
    _scroll.stop();
    _dragging = true;
    _dragStartScroll = _scroll.value;
    _dragStartPage = _activePage;
    _dragDistance = 0;
    widget.onDragStart?.call();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragDistance += _rtl ? -details.delta.dx : details.delta.dx;
    final raw = _dragStartScroll - _dragDistance;
    if (raw < 0) {
      _scroll.value = CdsMotion.rubberband(raw, _viewport);
    } else if (raw > _maxScroll) {
      _scroll.value = _maxScroll + CdsMotion.rubberband(raw - _maxScroll, _viewport);
    } else {
      _scroll.value = raw;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    _dragging = false;
    final fingerVelocity = details.velocity.pixelsPerSecond.dx;
    final velocity = _rtl ? fingerVelocity : -fingerVelocity;
    final projected = _scroll.value + CdsMotion.project(velocity);
    double target;
    int page;
    if (widget.drag == CdsCarouselDrag.free) {
      target = projected.clamp(0.0, _maxScroll);
      page = _nearestPage(target);
    } else {
      page = _nearestPage(projected);
      if (widget.snapMode == CdsCarouselSnapMode.page) {
        // A flick turns one page at a time when whole pages are in view.
        page = page.clamp(_dragStartPage - 1, _dragStartPage + 1).clamp(0, _pageOffsets.length - 1);
      }
      target = _pageOffsets[page];
    }
    if (CdsMotion.reduceMotion(context)) {
      _scroll.value = target;
    } else {
      CdsMotion.springTo(
        _scroll,
        target,
        spring: velocity.abs() > 300 ? CdsSprings.momentum : CdsSprings.standard,
        velocity: velocity,
      );
    }
    _setActivePage(page);
    widget.onDragEnd?.call();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final forward = _rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight;
    final back = _rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft;
    if (key == forward) {
      _goToPage(_activePage + 1);
      return KeyEventResult.handled;
    }
    if (key == back) {
      _goToPage(_activePage - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildTrack(BuildContext context) {
    final theme = context.cds;
    final gap = theme.space(widget.gap);
    return LayoutBuilder(builder: (context, constraints) {
      final viewport = constraints.maxWidth;
      assert(viewport.isFinite, 'CdsCarousel needs a bounded width.');
      final itemWidth = widget.itemWidth ?? viewport;
      final previousPages = _pageOffsets.length;
      final viewportChanged = viewport != _viewport;
      _viewport = viewport;
      _computeLayout(viewport, itemWidth, gap);
      final n = widget.children.length;

      if (!_initialized) {
        _initialized = true;
        _activePage = widget.initialPage.clamp(0, _pageOffsets.length - 1);
        _scroll.value = _pageOffsets[_activePage];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {});
          widget.controller?._notify();
          _syncAutoplay();
        });
      } else if (_activePage >= _pageOffsets.length || previousPages != _pageOffsets.length || viewportChanged) {
        _activePage = math.min(_activePage, _pageOffsets.length - 1);
        if (!_dragging && !_scroll.isAnimating) _scroll.value = _pageOffsets[_activePage];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {});
          widget.controller?._notify();
          _syncAutoplay();
        });
      }

      return _CarouselTrack(
        scroll: _scroll,
        itemWidth: itemWidth,
        gap: gap,
        textDirection: Directionality.of(context),
        children: [
          for (var i = 0; i < n; i++)
            Semantics(
              container: true,
              value: '${i + 1} of $n',
              child: widget.children[i],
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final pages = _pageOffsets.length;
    final canGoBack = _activePage > 0;
    final canGoForward = _activePage < pages - 1;
    final showAutoplayButton = widget.autoplay && _autoplayAllowed;

    Widget track = _buildTrack(context);
    if (widget.drag != CdsCarouselDrag.none) {
      track = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: () {
          if (_dragging) _onDragEnd(DragEndDetails());
        },
        child: track,
      );
    }
    track = Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      onFocusChange: (focused) {
        setState(() => _focused = focused);
        if (focused) _stopAutoplay();
      },
      child: _focused
          ? CustomPaint(
              foregroundPainter: CdsFocusRingPainter(
                borderRadius: BorderRadius.circular(theme.radius(200)),
                color: theme.color.bgLinePrimary,
                width: theme.borderWidth(200),
                gap: theme.borderWidth(200),
              ),
              child: track,
            )
          : track,
    );

    final rtl = _rtl;
    void scrollNext() => _goToPage(_activePage + 1);
    void scrollPrevious() => _goToPage(_activePage - 1);
    track = Semantics(
      container: true,
      label: widget.accessibilityLabel ?? widget.title ?? 'Carousel',
      value: pages > 0 ? 'Page ${_activePage + 1} of $pages' : null,
      onScrollLeft: (rtl ? canGoBack : canGoForward) ? (rtl ? scrollPrevious : scrollNext) : null,
      onScrollRight: (rtl ? canGoForward : canGoBack) ? (rtl ? scrollNext : scrollPrevious) : null,
      child: track,
    );

    final header = (widget.title != null || !widget.hideNavigation)
        ? Row(
            children: [
              if (widget.title != null)
                Expanded(
                  child: Semantics(
                    header: true,
                    child: CdsText(widget.title!, font: CdsFont.title3, maxLines: 1),
                  ),
                )
              else
                const Spacer(),
              if (!widget.hideNavigation)
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(vertical: theme.space(0.5)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: theme.space(1),
                    children: [
                      if (showAutoplayButton)
                        CdsIconButton(
                          _autoplayStopped ? CdsIconName.play : CdsIconName.pause,
                          semanticLabel: _autoplayStopped
                              ? widget.startAutoplayAccessibilityLabel
                              : widget.stopAutoplayAccessibilityLabel,
                          variant: CdsButtonVariant.secondary,
                          size: CdsButtonSize.s,
                          onPress: _toggleAutoplay,
                        ),
                      CdsIconButton(
                        rtl ? CdsIconName.caretRight : CdsIconName.caretLeft,
                        semanticLabel: widget.previousPageAccessibilityLabel,
                        variant: CdsButtonVariant.secondary,
                        size: CdsButtonSize.s,
                        onPress: canGoBack ? scrollPrevious : null,
                      ),
                      CdsIconButton(
                        rtl ? CdsIconName.caretLeft : CdsIconName.caretRight,
                        semanticLabel: widget.nextPageAccessibilityLabel,
                        variant: CdsButtonVariant.secondary,
                        size: CdsButtonSize.s,
                        onPress: canGoForward ? scrollNext : null,
                      ),
                    ],
                  ),
                ),
            ],
          )
        : null;

    return MouseRegion(
      onEnter: (_) => _stopAutoplay(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: theme.space(2),
        children: [
          ?header,
          track,
          if (!widget.hidePagination)
            Center(
              child: CdsPageIndicator(
                totalPages: pages,
                activePageIndex: _activePage,
                accessibilityLabel: widget.paginationAccessibilityLabel,
                onPressPage: _goToPage,
              ),
            ),
        ],
      ),
    );
  }
}

/// Lays items out side by side at a fixed width, equalizes their heights,
/// and paints them shifted by the scroll offset without rebuilding.
class _CarouselTrack extends MultiChildRenderObjectWidget {
  const _CarouselTrack({
    required this.scroll,
    required this.itemWidth,
    required this.gap,
    required this.textDirection,
    required super.children,
  });

  final Animation<double> scroll;
  final double itemWidth;
  final double gap;
  final TextDirection textDirection;

  @override
  _RenderCarouselTrack createRenderObject(BuildContext context) => _RenderCarouselTrack(
        scroll: scroll,
        itemWidth: itemWidth,
        gap: gap,
        textDirection: textDirection,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderCarouselTrack renderObject) {
    renderObject
      ..scroll = scroll
      ..itemWidth = itemWidth
      ..gap = gap
      ..textDirection = textDirection;
  }
}

class _TrackParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderCarouselTrack extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _TrackParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _TrackParentData> {
  _RenderCarouselTrack({
    required Animation<double> scroll,
    required double itemWidth,
    required double gap,
    required TextDirection textDirection,
  })  : _scroll = scroll,
        _itemWidth = itemWidth,
        _gap = gap,
        _textDirection = textDirection;

  Animation<double> _scroll;
  set scroll(Animation<double> value) {
    if (value == _scroll) return;
    if (attached) {
      _scroll.removeListener(_onScroll);
      value.addListener(_onScroll);
    }
    _scroll = value;
    _onScroll();
  }

  double _itemWidth;
  set itemWidth(double value) {
    if (value == _itemWidth) return;
    _itemWidth = value;
    markNeedsLayout();
  }

  double _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    _onScroll();
  }

  void _onScroll() {
    _positionChildren();
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scroll.addListener(_onScroll);
  }

  @override
  void detach() {
    _scroll.removeListener(_onScroll);
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TrackParentData) child.parentData = _TrackParentData();
  }

  @override
  double computeMinIntrinsicHeight(double width) => _maxChildHeight((c) => c.getMinIntrinsicHeight(_itemWidth));

  @override
  double computeMaxIntrinsicHeight(double width) => _maxChildHeight((c) => c.getMaxIntrinsicHeight(_itemWidth));

  double _maxChildHeight(double Function(RenderBox child) measure) {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      height = math.max(height, measure(child));
      child = childAfter(child);
    }
    return height;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final height = _maxChildHeight((c) => c.getDryLayout(BoxConstraints.tightFor(width: _itemWidth)).height);
    return constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void performLayout() {
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      child.layout(BoxConstraints.tightFor(width: _itemWidth), parentUsesSize: true);
      height = math.max(height, child.size.height);
      child = childAfter(child);
    }
    child = firstChild;
    while (child != null) {
      if (child.size.height != height) {
        child.layout(BoxConstraints.tightFor(width: _itemWidth, height: height), parentUsesSize: true);
      }
      child = childAfter(child);
    }
    size = constraints.constrain(Size(constraints.maxWidth, height));
    _positionChildren();
  }

  void _positionChildren() {
    if (!hasSize) return;
    var i = 0;
    var child = firstChild;
    while (child != null) {
      final start = i * (_itemWidth + _gap) - _scroll.value;
      final dx = _textDirection == TextDirection.rtl ? size.width - _itemWidth - start : start;
      (child.parentData! as _TrackParentData).offset = Offset(dx, 0);
      i++;
      child = childAfter(child);
    }
  }

  bool _isVisible(RenderBox child) {
    final dx = (child.parentData! as _TrackParentData).offset.dx;
    return dx < size.width && dx + child.size.width > 0;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (context, offset) {
      var child = firstChild;
      while (child != null) {
        if (_isVisible(child)) {
          context.paintChild(child, (child.parentData! as _TrackParentData).offset + offset);
        }
        child = childAfter(child);
      }
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (!(Offset.zero & size).contains(position)) return false;
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var child = firstChild;
    while (child != null) {
      if (_isVisible(child)) visitor(child);
      child = childAfter(child);
    }
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) => Offset.zero & size;
}
