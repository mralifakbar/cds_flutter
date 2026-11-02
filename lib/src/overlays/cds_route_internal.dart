// Routes behind showCdsModal, showCdsAlert, showCdsFullscreenModal,
// showCdsTray and showCdsDrawer. Not exported from the overlays barrel.

import 'package:flutter/widgets.dart';

import '../theme/cds_motion.dart';
import 'cds_focus_trap.dart';
import 'cds_overlay.dart';

/// How a dialog route enters and leaves.
enum CdsDialogTransition {
  /// Fade plus a scale from 0.98 (CDS modal and alert tokens).
  scale,

  /// Fade plus an 80px rise (CDS fullscreen modal tokens).
  slideUp,
}

/// A route that draws the CDS scrim and runs CDS modal motion around
/// [builder]. Escape and the system back gesture pop it.
class CdsDialogRoute<T> extends PopupRoute<T> {
  CdsDialogRoute({
    required this.builder,
    required this.transition,
    this.disableOverlayPress = false,
    this.shouldCloseOnEscPress = true,
    this.restoreFocusOnUnmount = true,
    this.showScrim = true,
    this.semanticLabel,
    super.settings,
  });

  final WidgetBuilder builder;
  final CdsDialogTransition transition;
  final bool disableOverlayPress;
  final bool shouldCloseOnEscPress;
  final bool restoreFocusOnUnmount;
  final bool showScrim;
  final String? semanticLabel;

  bool get _reduceMotion {
    final nav = navigator;
    return nav != null && CdsMotion.reduceMotion(nav.context);
  }

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => _reduceMotion ? CdsDurations.fast1 : CdsDurations.moderate3;

  @override
  Duration get reverseTransitionDuration {
    if (_reduceMotion) return CdsDurations.fast1;
    return transition == CdsDialogTransition.scale ? CdsDurations.fast1 : CdsDurations.moderate1;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    // ModalRoute only handles Escape for barrier-dismissible routes, and the
    // scrim here is drawn by the route itself, so Escape is wired directly.
    final content = CdsFocusTrap(
      restoreFocusOnUnmount: restoreFocusOnUnmount,
      onEscPress: shouldCloseOnEscPress ? () => navigator?.maybePop() : null,
      child: Builder(builder: builder),
    );
    return Semantics(
      scopesRoute: true,
      namesRoute: semanticLabel != null,
      explicitChildNodes: true,
      label: semanticLabel,
      child: content,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduce = CdsMotion.reduceMotion(context);
    final scale = transition == CdsDialogTransition.scale;
    // Forward runs moderate3 (300ms); CDS fades the scrim in over moderate1
    // and the dialog over fast1 within that window.
    final scrimOpacity = CurvedAnimation(
      parent: animation,
      curve: reduce || !scale ? CdsCurves.global : const Interval(0, 2 / 3, curve: CdsCurves.enterFunctional),
      reverseCurve: CdsCurves.global,
    );
    final contentOpacity = CurvedAnimation(
      parent: animation,
      curve: reduce
          ? CdsCurves.global
          : (scale ? const Interval(0, 1 / 3, curve: CdsCurves.enterFunctional) : CdsCurves.enterFunctional),
      reverseCurve: scale ? CdsCurves.global : CdsCurves.exitFunctional,
    );
    final movement = CurvedAnimation(
      parent: animation,
      curve: CdsCurves.enterFunctional,
      reverseCurve: scale ? CdsCurves.global : CdsCurves.exitFunctional,
    );

    Widget content = FadeTransition(opacity: contentOpacity, child: child);
    if (!reduce) {
      content = scale
          ? ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(movement), child: content)
          : AnimatedBuilder(
              animation: movement,
              builder: (context, child) =>
                  Transform.translate(offset: Offset(0, 80 * (1 - movement.value)), child: child),
              child: content,
            );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showScrim)
          FadeTransition(
            opacity: scrimOpacity,
            child: CdsOverlay(
              onPress: disableOverlayPress ? null : () => navigator?.maybePop(),
            ),
          ),
        content,
      ],
    );
  }
}

/// Route for sheets (tray, drawer). The sheet widget owns all motion; the
/// route only waits for the sheet to say its exit is done before it
/// finalizes, so `Navigator.pop` still animates the sheet out along the path
/// it came in on.
class CdsSheetRoute<T> extends PopupRoute<T> {
  CdsSheetRoute({required this.builder, this.semanticLabel, super.settings});

  final WidgetBuilder builder;
  final String? semanticLabel;
  bool _exitDone = false;

  /// Called by the sheet once it is fully off screen.
  void completeExit() => _exitDone = true;

  /// True once a pop has started (by gesture, back button or code).
  bool get isExiting => animation?.status == AnimationStatus.reverse || _exitDone;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Simulation? createSimulation({required bool forward}) => forward ? null : _SheetExitSimulation(this);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Semantics(
      scopesRoute: true,
      namesRoute: semanticLabel != null,
      explicitChildNodes: true,
      label: semanticLabel,
      child: Builder(builder: builder),
    );
  }
}

/// Holds the route "visible" until the sheet reports its exit finished. The
/// time cap keeps a route from lingering if its sheet never reports back.
class _SheetExitSimulation extends Simulation {
  _SheetExitSimulation(this.route);

  final CdsSheetRoute<dynamic> route;

  @override
  double x(double time) => route._exitDone ? 0 : 1;

  @override
  double dx(double time) => 0;

  @override
  bool isDone(double time) => route._exitDone || time > 2;
}
