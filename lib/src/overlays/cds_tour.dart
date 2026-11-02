import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import 'cds_focus_trap.dart';
import 'cds_overlay.dart';
import 'cds_overlay_internal.dart';

/// Builds the card for a tour step, usually a [CdsCoachmark].
typedef CdsTourStepBuilder = Widget Function(BuildContext context, CdsTourController tour);

/// One step of a [CdsTour]: which [CdsTourStep] target to highlight and
/// what to show next to it.
@immutable
class CdsTourStepValue {
  const CdsTourStepValue({
    required this.id,
    required this.builder,
    this.disabled = false,
    this.hideOverlay,
    this.tourMaskPadding,
    this.tourMaskBorderRadius,
    this.disableAutoScroll = false,
    this.onActive,
    this.onInactive,
  });

  /// Matches the `id` of a [CdsTourStep] in the tree.
  final String id;
  final CdsTourStepBuilder builder;

  /// Skipped by next and previous.
  final bool disabled;

  /// Overrides [CdsTour.hideOverlay] for this step.
  final bool? hideOverlay;

  /// Overrides [CdsTour.tourMaskPadding] for this step.
  final double? tourMaskPadding;

  /// Overrides [CdsTour.tourMaskBorderRadius] for this step.
  final double? tourMaskBorderRadius;

  /// Do not scroll the target into view when the step starts.
  final bool disableAutoScroll;
  final VoidCallback? onActive;
  final VoidCallback? onInactive;
}

/// Moves a [CdsTour] between steps. Get it from [CdsTour.of] or from the
/// step builder.
abstract class CdsTourController {
  /// Id of the step on screen, or null when the tour is not running.
  String? get activeTourStep;

  /// Starts at [tourStepId], or the first enabled step.
  void startTour([String? tourStepId]);
  void stopTour();
  void goNextTourStep();
  void goPreviousTourStep();
  void setActiveTourStep(String? tourStepId);
}

/// Steps through feature introductions. Each step dims the screen except a
/// spotlight around its target and shows a card (usually a [CdsCoachmark])
/// next to it, with an arrow pointing at the target. The spotlight glides
/// from one target to the next.
///
/// The tour is controlled: [activeTourStep] says which step is showing and
/// [onChange] is called with the next id (or null to end).
///
/// ```dart
/// CdsTour(
///   activeTourStep: step,
///   onChange: (id) => setState(() => step = id),
///   steps: [
///     CdsTourStepValue(
///       id: 'balance',
///       builder: (context, tour) => CdsCoachmark(
///         title: 'Your balance',
///         content: 'Sample data: the total value of your assets.',
///         action: CdsButton(label: 'Next', size: CdsButtonSize.s, onPress: tour.goNextTourStep),
///         onClose: tour.stopTour,
///       ),
///     ),
///   ],
///   child: CdsTourStep(id: 'balance', child: BalanceCard()),
/// )
/// ```
class CdsTour extends StatefulWidget {
  const CdsTour({
    super.key,
    required this.steps,
    required this.activeTourStep,
    required this.onChange,
    required this.child,
    this.hideOverlay = false,
    this.tourMaskPadding = 2,
    this.tourMaskBorderRadius = 12,
    this.tourStepOffset = 3,
    this.accessibilityLabel,
  });

  final List<CdsTourStepValue> steps;

  /// Id of the step to show, or null when the tour is not running.
  final String? activeTourStep;
  final ValueChanged<String?> onChange;
  final Widget child;

  /// Do not dim the screen around the target.
  final bool hideOverlay;

  /// Space token added around the target's spotlight (half on each side).
  final double tourMaskPadding;

  /// Corner radius of the spotlight in px.
  final double tourMaskBorderRadius;

  /// Space token between the target and the step card.
  final double tourStepOffset;

  /// Screen reader label for the tour layer.
  final String? accessibilityLabel;

  /// The controller of the nearest tour.
  static CdsTourController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_CdsTourScope>();
    assert(scope != null, 'CdsTour.of called without a CdsTour ancestor.');
    return scope!.state;
  }

  @override
  State<CdsTour> createState() => _CdsTourState();
}

class _CdsTourScope extends InheritedWidget {
  const _CdsTourScope({required this.state, required this.active, required super.child});

  final _CdsTourState state;
  final String? active;

  @override
  bool updateShouldNotify(_CdsTourScope old) => old.active != active;
}

class _CdsTourState extends State<CdsTour> with SingleTickerProviderStateMixin implements CdsTourController {
  final OverlayPortalController _portal = OverlayPortalController();
  final Map<String, BuildContext> _targets = {};
  final GlobalKey _cardKey = GlobalKey();
  // Created eagerly: a lazy controller first touched in dispose() would create
  // a ticker on a deactivated element.
  late final AnimationController _presence;

  Rect? _targetRect;
  Rect? _cardRect;
  bool _measureScheduled = false;
  String? _shownStep;

  @override
  String? get activeTourStep => widget.activeTourStep;

  CdsTourStepValue? get _active {
    final id = widget.activeTourStep;
    if (id == null) return null;
    for (final s in widget.steps) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _presence = AnimationController(vsync: this, duration: CdsDurations.moderate3);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncActive(null));
  }

  @override
  void didUpdateWidget(CdsTour oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTourStep != widget.activeTourStep) {
      final previous = oldWidget.activeTourStep;
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncActive(previous));
    }
  }

  @override
  void dispose() {
    _presence.dispose();
    super.dispose();
  }

  Future<void> _syncActive(String? previous) async {
    if (!mounted) return;
    if (previous != null) {
      for (final s in widget.steps) {
        if (s.id == previous) s.onInactive?.call();
      }
    }
    final step = _active;
    if (step == null) {
      if (_portal.isShowing) {
        _presence.duration = CdsMotion.duration(context, CdsDurations.moderate1);
        await _presence.reverse().orCancel.catchError((_) {});
        if (mounted && _active == null) {
          _portal.hide();
          setState(() {
            _targetRect = null;
            _cardRect = null;
            _shownStep = null;
          });
        }
      }
      return;
    }
    final target = _targets[step.id];
    if (target != null && !step.disableAutoScroll && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        alignment: 0.5,
        duration: CdsMotion.duration(context, CdsDurations.moderate3),
        curve: CdsCurves.global,
      );
    }
    if (!mounted || _active?.id != step.id) return;
    _portal.show();
    setState(() {
      _shownStep = step.id;
      _cardRect = null;
    });
    _measure();
    _presence.duration = CdsMotion.duration(context, CdsDurations.moderate3);
    unawaited(_presence.forward(from: 0));
    step.onActive?.call();
  }

  void _register(String id, BuildContext context) => _targets[id] = context;

  void _unregister(String id, BuildContext context) {
    if (_targets[id] == context) _targets.remove(id);
  }

  void _scheduleMeasure() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      _measure();
    });
  }

  void _measure() {
    if (!mounted) return;
    final step = _active;
    final overlayBox = Overlay.maybeOf(context)?.context.findRenderObject();
    if (step == null || overlayBox is! RenderBox) return;
    final target = _targets[step.id]?.findRenderObject();
    Rect? targetRect;
    if (target is RenderBox && target.attached && target.hasSize) {
      targetRect = MatrixUtils.transformRect(target.getTransformTo(overlayBox), Offset.zero & target.size);
    }
    Rect? cardRect;
    final card = _cardKey.currentContext?.findRenderObject();
    if (card is RenderBox && card.attached && card.hasSize) {
      cardRect = MatrixUtils.transformRect(card.getTransformTo(overlayBox), Offset.zero & card.size);
    }
    bool differs(Rect? a, Rect? b) {
      if (a == null || b == null) return (a == null) != (b == null);
      return (a.left - b.left).abs() + (a.top - b.top).abs() + (a.width - b.width).abs() + (a.height - b.height).abs() > 0.5;
    }
    if (differs(targetRect, _targetRect) || differs(cardRect, _cardRect)) {
      setState(() {
        _targetRect = targetRect;
        _cardRect = cardRect;
      });
    }
  }

  List<CdsTourStepValue> get _enabled => [for (final s in widget.steps) if (!s.disabled) s];

  @override
  void startTour([String? tourStepId]) {
    final enabled = _enabled;
    if (enabled.isEmpty) return;
    widget.onChange(tourStepId ?? enabled.first.id);
  }

  @override
  void stopTour() => widget.onChange(null);

  @override
  void goNextTourStep() {
    final enabled = _enabled;
    final i = enabled.indexWhere((s) => s.id == widget.activeTourStep);
    widget.onChange(i >= 0 && i + 1 < enabled.length ? enabled[i + 1].id : null);
  }

  @override
  void goPreviousTourStep() {
    final enabled = _enabled;
    final i = enabled.indexWhere((s) => s.id == widget.activeTourStep);
    if (i > 0) widget.onChange(enabled[i - 1].id);
  }

  @override
  void setActiveTourStep(String? tourStepId) => widget.onChange(tourStepId);

  Widget _buildOverlay(BuildContext context) {
    final step = _active;
    final rect = _targetRect;
    if (step == null || rect == null || _shownStep != step.id) {
      if (step != null) _scheduleMeasure();
      return const SizedBox.shrink();
    }
    _scheduleMeasure();
    final theme = context.cds;
    final reduce = CdsMotion.reduceMotion(context);
    final padding = theme.space(step.tourMaskPadding ?? widget.tourMaskPadding);
    final radius = step.tourMaskBorderRadius ?? widget.tourMaskBorderRadius;
    final hideOverlay = step.hideOverlay ?? widget.hideOverlay;
    final hole = rect.inflate(padding / 2);
    final fade = CurvedAnimation(parent: _presence, curve: CdsCurves.global);

    final mask = TweenAnimationBuilder<Rect?>(
      tween: RectTween(end: hole),
      duration: reduce ? Duration.zero : CdsDurations.moderate3,
      curve: CdsCurves.global,
      builder: (context, animated, _) => CustomPaint(
        size: Size.infinite,
        painter: _TourMaskPainter(
          hole: animated ?? hole,
          radius: radius,
          color: hideOverlay ? const Color(0x00000000) : theme.color.bgOverlay,
        ),
      ),
    );

    final card = KeyedSubtree(key: _cardKey, child: step.builder(context, this));
    final arrow = _cardRect == null ? null : _arrow(context, rect, _cardRect!);

    return CdsFocusTrap(
      onEscPress: stopTour,
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        label: widget.accessibilityLabel,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: fade,
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}, child: ExcludeSemantics(child: mask)),
            ),
            if (arrow != null) FadeTransition(opacity: fade, child: arrow),
            CdsAnchoredBox(
              anchorRect: rect,
              placement: CdsPlacement.bottom,
              gap: theme.space(widget.tourStepOffset),
              margin: EdgeInsets.all(theme.space(2)) + MediaQuery.paddingOf(context),
              animation: fade,
              textDirection: Directionality.of(context),
              slide: reduce ? 0 : 8,
              scaleFrom: reduce ? 1 : 0.97,
              child: card,
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrow(BuildContext context, Rect target, Rect card) {
    final theme = context.cds;
    const size = 24.0;
    final below = card.center.dy > target.center.dy;
    final x = target.center.dx.clamp(card.left + size, math.max(card.left + size, card.right - size)) - size / 2;
    final y = below ? card.top - size / 2 : card.bottom - size / 2;
    return Stack(
      children: [
        Positioned(
          left: x,
          top: y,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: SizedBox.square(
              dimension: size,
              child: ColoredBox(color: theme.color.bgInverse),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CdsTourScope(
      state: this,
      active: widget.activeTourStep,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: widget.child,
      ),
    );
  }
}

class _TourMaskPainter extends CustomPainter {
  const _TourMaskPainter({required this.hole, required this.radius, required this.color});

  final Rect hole;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(hole, Radius.circular(radius)));
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TourMaskPainter old) => old.hole != hole || old.radius != radius || old.color != color;
}

/// Marks a widget as the target of the [CdsTourStepValue] with the same [id].
///
/// ```dart
/// CdsTourStep(id: 'send', child: CdsButton(label: 'Send', onPress: send))
/// ```
class CdsTourStep extends StatefulWidget {
  const CdsTourStep({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  State<CdsTourStep> createState() => _CdsTourStepState();
}

class _CdsTourStepState extends State<CdsTourStep> {
  _CdsTourState? _tour;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tour = context.dependOnInheritedWidgetOfExactType<_CdsTourScope>()?.state;
    if (tour != _tour) {
      _tour?._unregister(widget.id, context);
      _tour = tour;
    }
    _tour?._register(widget.id, context);
  }

  @override
  void didUpdateWidget(CdsTourStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _tour?._unregister(oldWidget.id, context);
      _tour?._register(widget.id, context);
    }
  }

  @override
  void dispose() {
    _tour?._unregister(widget.id, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
