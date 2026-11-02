import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// CDS easing curves (cubic-bezier values from `@coinbase/cds-common/motion/tokens`).
abstract final class CdsCurves {
  static const Cubic global = Cubic(0.6, 0, 0.15, 1);
  static const Cubic enterExpressive = Cubic(0.33, 0, 0, 1);
  static const Cubic enterFunctional = Cubic(0, 0, 0.15, 1);
  static const Cubic exitExpressive = Cubic(1, 0, 0.67, 1);
  static const Cubic exitFunctional = Cubic(0.6, 0, 1, 1);
  static const Curve linear = Curves.linear;
}

/// CDS durations.
abstract final class CdsDurations {
  static const Duration quick = Duration(milliseconds: 33);

  /// Buttons, toggles, text, icons, selection controls.
  static const Duration fast1 = Duration(milliseconds: 100);
  static const Duration fast2 = Duration(milliseconds: 133);
  static const Duration fast3 = Duration(milliseconds: 150);

  /// Short movements, system messaging, drawers, modals.
  static const Duration moderate1 = Duration(milliseconds: 200);
  static const Duration moderate2 = Duration(milliseconds: 250);
  static const Duration moderate3 = Duration(milliseconds: 300);

  /// Large movements, page transitions, full-screen dialogs.
  static const Duration slow1 = Duration(milliseconds: 350);
  static const Duration slow2 = Duration(milliseconds: 400);
  static const Duration slow3 = Duration(milliseconds: 500);
  static const Duration slow4 = Duration(milliseconds: 1000);
}

/// Springs for anything a finger can touch. Springs start from the current
/// value and carry velocity, so they can be interrupted and reversed mid-flight
/// without a jump. Parameters are expressed as damping ratio + response
/// (seconds to reach the target), the way Apple's fluid-interface guidance does.
abstract final class CdsSprings {
  /// Builds a spring from a damping ratio and a response time in seconds.
  static SpringDescription of({required double dampingRatio, required double response}) {
    final stiffness = math.pow(2 * math.pi / response, 2).toDouble();
    return SpringDescription.withDampingRatio(mass: 1, stiffness: stiffness, ratio: dampingRatio);
  }

  /// Default for UI that moves on its own: critically damped, no overshoot.
  static final SpringDescription standard = of(dampingRatio: 1, response: 0.35);

  /// Press-down and release feedback. Quick, no bounce.
  static final SpringDescription press = of(dampingRatio: 1, response: 0.2);

  /// After a flick or drag release, where the gesture carried momentum.
  static final SpringDescription momentum = of(dampingRatio: 0.8, response: 0.35);

  /// Sheets and trays settling after a drag.
  static final SpringDescription sheet = of(dampingRatio: 0.86, response: 0.32);
}

/// Motion helpers shared by components.
abstract final class CdsMotion {
  /// Scale applied to pressable surfaces while held. Matches CDS mobile (0.98).
  static const double pressScale = 0.98;

  /// True when the platform asks for reduced motion. Components swap slides,
  /// springs and loops for short cross-fades or no motion at all.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Duration to use for a transition, collapsed to zero under reduced motion.
  static Duration duration(BuildContext context, Duration normal) =>
      reduceMotion(context) ? Duration.zero : normal;

  /// Where a flick would come to rest, using exponential deceleration (the same
  /// projection UIScrollView uses). [velocity] is in logical px per second.
  static double project(double velocity, {double decelerationRate = 0.998}) =>
      (velocity / 1000) * decelerationRate / (1 - decelerationRate);

  /// Progressive resistance past a boundary so drags never stop dead.
  static double rubberband(double overshoot, double dimension, {double constant = 0.55}) {
    if (dimension <= 0) return 0;
    return (overshoot * dimension * constant) / (dimension + constant * overshoot.abs());
  }

  /// Drives [controller] to [target] with a spring that starts from the
  /// controller's current value and [velocity] (in controller units per second).
  static TickerFuture springTo(
    AnimationController controller,
    double target, {
    SpringDescription? spring,
    double velocity = 0,
  }) {
    final simulation = SpringSimulation(
      spring ?? CdsSprings.standard,
      controller.value,
      target,
      velocity,
      tolerance: const Tolerance(distance: 0.0005, velocity: 0.01),
    );
    final future = controller.animateWith(simulation);
    // Springs stop within tolerance of the target; land exactly on it so a
    // resting surface is never left a fraction of a pixel off. `then` only runs
    // on completion, not when another animation interrupts this one.
    future.then((_) {
      if (controller.value != target) controller.value = target;
    });
    return future;
  }
}
