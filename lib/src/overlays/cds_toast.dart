import 'dart:async';
import 'dart:collection';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../buttons/cds_button_variant.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Default time a toast stays up (CDS `defaultDuration`).
const Duration cdsToastDefaultDuration = Duration(milliseconds: 5000);

/// Extra time when a toast has an action (CDS `withActionDuration`).
const Duration cdsToastActionDuration = Duration(milliseconds: 2000);

/// A button shown at the end of a toast.
@immutable
class CdsToastAction {
  const CdsToastAction({required this.label, required this.onPress});

  final String label;
  final VoidCallback onPress;
}

/// How long CDS keeps a toast up: 5s, plus 2s with an action, plus 300ms for
/// every 10 characters past 50.
Duration cdsToastDuration(String text, {bool hasAction = false}) {
  var ms = cdsToastDefaultDuration.inMilliseconds;
  if (hasAction) ms += cdsToastActionDuration.inMilliseconds;
  if (text.length > 50) ms += (((text.length - 50) / 10) * 300).round();
  return Duration(milliseconds: ms);
}

/// Shows a toast at the bottom of the screen, above the safe area. Toasts
/// queue: a new one waits until the current one leaves.
///
/// Uses the nearest [CdsToastHost] when there is one, otherwise the root
/// [Overlay]. The toast pauses its timer while touched, can be swiped down
/// or sideways to dismiss, and is announced to screen readers.
///
/// ```dart
/// showCdsToast(context, 'Address copied');
/// showCdsToast(
///   context,
///   'Sent 25 USDC',
///   action: CdsToastAction(label: 'Undo', onPress: undoSend),
/// );
/// ```
void showCdsToast(
  BuildContext context,
  String text, {
  CdsToastAction? action,
  Duration? duration,
  CdsColor? variant,
  String? accessibilityLabel,
  VoidCallback? onDidHide,
}) {
  CdsToastHost.of(context).show(
    text,
    action: action,
    duration: duration,
    variant: variant,
    accessibilityLabel: accessibilityLabel,
    onDidHide: onDidHide,
  );
}

/// The toast surface: text and an optional action on the `bgAlternate`
/// card. Shown by [showCdsToast]; use it directly only for previews.
///
/// ```dart
/// const CdsToast(text: 'Saved to watchlist')
/// ```
class CdsToast extends StatelessWidget {
  const CdsToast({super.key, required this.text, this.action, this.onActionPress});

  final String text;
  final CdsToastAction? action;

  /// Called after [action] runs; the host uses it to hide the toast.
  final VoidCallback? onActionPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.color.bgAlternate,
        borderRadius: BorderRadius.circular(theme.radius(200)),
        border: Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)),
        boxShadow: theme.shadow(CdsElevation.level2),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: theme.space(3),
          end: theme.space(1),
          top: theme.space(1),
          bottom: theme.space(1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: theme.space(2), top: theme.space(1), bottom: theme.space(1)),
                child: CdsText(text, font: CdsFont.headline),
              ),
            ),
            if (action != null)
              CdsButton(
                label: action!.label,
                variant: CdsButtonVariant.primary,
                transparent: true,
                size: CdsButtonSize.s,
                onPress: () {
                  action!.onPress();
                  onActionPress?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ToastRequest {
  _ToastRequest({
    required this.id,
    required this.text,
    required this.duration,
    this.action,
    this.variant,
    this.accessibilityLabel,
    this.onDidHide,
  });

  final int id;
  final String text;
  final Duration duration;
  final CdsToastAction? action;
  final CdsColor? variant;
  final String? accessibilityLabel;
  final VoidCallback? onDidHide;
}

/// Queues toasts and owns the auto-dismiss timer. One per [CdsToastHost] (or
/// per root overlay when there is no host).
class CdsToastController extends ChangeNotifier {
  final Queue<_ToastRequest> _queue = Queue<_ToastRequest>();
  _ToastRequest? _active;
  int _nextId = 0;
  int _hideRequests = 0;

  Timer? _timer;
  final Stopwatch _elapsed = Stopwatch();
  Duration _remaining = Duration.zero;

  _ToastRequest? get _current => _active;

  /// Bumps when the active toast should animate out.
  int get hideRequests => _hideRequests;

  /// Whether a toast is on screen.
  bool get hasActiveToast => _active != null;

  /// Number of toasts waiting behind the current one.
  int get queueLength => _queue.length;

  /// Adds a toast to the queue. See [showCdsToast].
  void show(
    String text, {
    CdsToastAction? action,
    Duration? duration,
    CdsColor? variant,
    String? accessibilityLabel,
    VoidCallback? onDidHide,
  }) {
    final request = _ToastRequest(
      id: _nextId++,
      text: text,
      action: action,
      duration: duration ?? cdsToastDuration(text, hasAction: action != null),
      variant: variant,
      accessibilityLabel: accessibilityLabel,
      onDidHide: onDidHide,
    );
    if (_active == null) {
      _activate(request);
    } else {
      _queue.add(request);
    }
  }

  /// Animates the current toast out.
  void hide() {
    if (_active == null) return;
    _timer?.cancel();
    _hideRequests++;
    notifyListeners();
  }

  /// Drops waiting toasts and hides the current one.
  void clearQueue() {
    _queue.clear();
    hide();
  }

  void _activate(_ToastRequest request) {
    _active = request;
    _remaining = request.duration;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsed
      ..reset()
      ..start();
    _timer = Timer(_remaining, hide);
  }

  void _pause() {
    if (_timer == null || !_timer!.isActive) return;
    _timer!.cancel();
    _elapsed.stop();
    _remaining -= _elapsed.elapsed;
    if (_remaining < Duration.zero) _remaining = Duration.zero;
  }

  void _resume() {
    if (_active == null || (_timer?.isActive ?? false)) return;
    _startTimer();
  }

  void _didHide(_ToastRequest request) {
    if (_active?.id != request.id) return;
    _timer?.cancel();
    _timer = null;
    _active = null;
    request.onDidHide?.call();
    if (_queue.isNotEmpty) {
      _activate(_queue.removeFirst());
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Shows toasts for its subtree. Place it under your app's `Navigator` (for
/// example in `MaterialApp.builder`) to control where toasts sit; without a
/// host, [showCdsToast] uses the root overlay.
///
/// ```dart
/// MaterialApp(builder: (context, child) => CdsToastHost(child: child!))
/// ```
class CdsToastHost extends StatefulWidget {
  const CdsToastHost({super.key, required this.child, this.bottomOffset});

  final Widget child;

  /// Distance from the bottom edge in px. Defaults to the bottom safe-area inset.
  final double? bottomOffset;

  /// The controller of the nearest host, or of the root overlay when there is
  /// no host above [context].
  static CdsToastController of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_CdsToastScope>();
    if (scope != null) return scope.controller;
    final overlay = Overlay.of(context, rootOverlay: true);
    return _OverlayToastHost.forOverlay(overlay).controller;
  }

  @override
  State<CdsToastHost> createState() => _CdsToastHostState();
}

class _CdsToastHostState extends State<CdsToastHost> {
  final CdsToastController _controller = CdsToastController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CdsToastScope(
      controller: _controller,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          Positioned.fill(child: _ToastLayer(controller: _controller, bottomOffset: widget.bottomOffset)),
        ],
      ),
    );
  }
}

class _CdsToastScope extends InheritedWidget {
  const _CdsToastScope({required this.controller, required super.child});

  final CdsToastController controller;

  @override
  bool updateShouldNotify(_CdsToastScope oldWidget) => controller != oldWidget.controller;
}

/// Toast layer inserted into an overlay when the app has no [CdsToastHost].
class _OverlayToastHost {
  _OverlayToastHost._(this.overlay) {
    entry = OverlayEntry(builder: (context) => _ToastLayer(controller: controller));
    overlay.insert(entry);
  }

  static final Expando<_OverlayToastHost> _hosts = Expando<_OverlayToastHost>();

  static _OverlayToastHost forOverlay(OverlayState overlay) {
    final existing = _hosts[overlay];
    if (existing != null) {
      // Keep the toast layer above routes pushed after it was created, but
      // never while a toast is animating in it.
      if (existing.entry.mounted && !existing.controller.hasActiveToast) {
        existing.entry.remove();
        overlay.insert(existing.entry);
      }
      return existing;
    }
    return _hosts[overlay] = _OverlayToastHost._(overlay);
  }

  final OverlayState overlay;
  final CdsToastController controller = CdsToastController();
  late final OverlayEntry entry;
}

class _ToastLayer extends StatelessWidget {
  const _ToastLayer({required this.controller, this.bottomOffset});

  final CdsToastController controller;
  final double? bottomOffset;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final request = controller._current;
        if (request == null) return const SizedBox.shrink();
        final theme = context.cds;
        final bottom = bottomOffset ?? MediaQuery.paddingOf(context).bottom;
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottom),
            child: Padding(
              padding: EdgeInsets.all(theme.space(2)),
              child: _AnimatedToast(key: ValueKey(request.id), request: request, controller: controller),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedToast extends StatefulWidget {
  const _AnimatedToast({super.key, required this.request, required this.controller});

  final _ToastRequest request;
  final CdsToastController controller;

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast> with TickerProviderStateMixin {
  // 0 = hidden 25px below its rest position, 1 = shown (CDS toast tokens).
  late final AnimationController _presence = AnimationController(vsync: this);
  // Swipe offset that follows the finger.
  late final AnimationController _dx = AnimationController.unbounded(vsync: this);
  late final AnimationController _dy = AnimationController.unbounded(vsync: this);
  late final AnimationController _surge = AnimationController(vsync: this);

  Axis? _lockedAxis;
  bool _leaving = false;
  late int _hideRequests;

  @override
  void initState() {
    super.initState();
    _hideRequests = widget.controller.hideRequests;
    widget.controller.addListener(_onController);
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _presence.dispose();
    _dx.dispose();
    _dy.dispose();
    _surge.dispose();
    super.dispose();
  }

  void _onController() {
    if (widget.controller.hideRequests != _hideRequests) {
      _hideRequests = widget.controller.hideRequests;
      _leave();
    }
  }

  Future<void> _enter() async {
    if (!mounted) return;
    final reduce = CdsMotion.reduceMotion(context);
    _presence.duration = reduce ? CdsDurations.fast1 : CdsDurations.moderate3;
    if (!reduce) _playSurge();
    await _presence.forward().orCancel.catchError((_) {});
    if (!mounted || _leaving) return;
    _announce();
    widget.controller._startTimer();
  }

  void _playSurge() {
    // CDS ColorSurge: a single 30% tint flash on arrival, then gone.
    _surge.duration = CdsDurations.fast1;
    _surge.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _surge.duration = CdsDurations.slow4;
        _surge.reverse();
      });
    });
  }

  void _announce() {
    final request = widget.request;
    final message = request.accessibilityLabel ?? '${request.text}${request.action != null ? ', ${request.action!.label}' : ''}';
    SemanticsService.sendAnnouncement(View.of(context), message, Directionality.of(context));
  }

  Future<void> _leave() async {
    if (_leaving || !mounted) return;
    _leaving = true;
    final reduce = CdsMotion.reduceMotion(context);
    _presence.reverseDuration = reduce ? CdsDurations.fast1 : CdsDurations.moderate3;
    await _presence.reverse().orCancel.catchError((_) {});
    widget.controller._didHide(widget.request);
  }

  void _onPanStart(DragStartDetails details) {
    _dx.stop();
    _dy.stop();
    _lockedAxis = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_leaving) return;
    final delta = details.delta;
    if (delta == Offset.zero) return;
    _lockedAxis ??= delta.dx.abs() > delta.dy.abs() ? Axis.horizontal : Axis.vertical;
    if (_lockedAxis == Axis.horizontal) {
      _dx.value += delta.dx;
    } else {
      final raw = _dy.value + delta.dy;
      // Downward follows the finger; upward resists.
      _dy.value = raw >= 0 ? raw : -CdsMotion.rubberband(-raw, 120);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_leaving) return;
    final v = details.velocity.pixelsPerSecond;
    final size = context.size ?? const Size(300, 56);
    final reduce = CdsMotion.reduceMotion(context);
    _lockedAxis ??= v.dx.abs() > v.dy.abs() ? Axis.horizontal : Axis.vertical;
    if (_lockedAxis == Axis.horizontal) {
      final projected = _dx.value + CdsMotion.project(v.dx);
      if (projected.abs() > size.width / 2) {
        final target = projected.sign * (MediaQuery.sizeOf(context).width);
        _dismissBySwipe(_dx, target, v.dx, reduce);
        return;
      }
      CdsMotion.springTo(_dx, 0, velocity: v.dx);
    } else if (_lockedAxis == Axis.vertical) {
      final projected = _dy.value + CdsMotion.project(v.dy);
      if (projected > size.height / 2 && v.dy >= 0) {
        _dismissBySwipe(_dy, size.height * 3, v.dy, reduce);
        return;
      }
      CdsMotion.springTo(_dy, 0, velocity: v.dy);
    }
  }

  void _dismissBySwipe(AnimationController axis, double target, double velocity, bool reduce) {
    widget.controller._timer?.cancel();
    if (reduce) {
      _leave();
      return;
    }
    _leaving = true;
    CdsMotion.springTo(axis, target, spring: CdsSprings.momentum, velocity: velocity);
    _presence.reverseDuration = CdsDurations.moderate3;
    _presence.reverse().whenComplete(() => widget.controller._didHide(widget.request));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final request = widget.request;
    final reduce = CdsMotion.reduceMotion(context);
    final enter = CurvedAnimation(
      parent: _presence,
      curve: CdsCurves.enterFunctional,
      reverseCurve: CdsCurves.exitFunctional,
    );

    final surgeColor = theme.colorOf(request.variant ?? CdsColor.bgPrimary);
    Widget toast = Stack(
      children: [
        CdsToast(text: request.text, action: request.action, onActionPress: widget.controller.hide),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _surge,
              builder: (context, _) => DecoratedBox(
                decoration: BoxDecoration(
                  color: surgeColor.withValues(alpha: 0.3 * _surge.value),
                  borderRadius: BorderRadius.circular(theme.radius(200)),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    toast = AnimatedBuilder(
      animation: Listenable.merge([enter, _dx, _dy]),
      child: toast,
      builder: (context, child) => Opacity(
        opacity: enter.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(_dx.value, _dy.value + (reduce ? 0 : 25 * (1 - enter.value))),
          child: child,
        ),
      ),
    );

    return Semantics(
      liveRegion: true,
      container: true,
      label: request.accessibilityLabel,
      child: Listener(
        onPointerDown: (_) => widget.controller._pause(),
        onPointerUp: (_) {
          if (!_leaving) widget.controller._resume();
        },
        onPointerCancel: (_) {
          if (!_leaving) widget.controller._resume();
        },
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: toast,
        ),
      ),
    );
  }
}
