import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../theme/cds_motion.dart';
import '../cds_chart_path.dart';

/// CDS default update transition for chart elements: a spring with
/// stiffness 900 and damping 120 (overdamped, settles in about half a second).
const SpringDescription cdsChartUpdateSpring = SpringDescription(mass: 1, stiffness: 900, damping: 120);

/// CDS sparkline path transition: 450ms ease-out-quint.
const Duration cdsSparklinePathDuration = Duration(milliseconds: 450);

/// `1 - (1 - t)^5`, the easing CDS uses for sparkline period changes.
class EaseOutQuint extends Curve {
  const EaseOutQuint();

  @override
  double transformInternal(double t) {
    final u = 1 - t;
    return 1 - u * u * u * u * u;
  }
}

/// Animates a chart element from whatever it shows now to a new target.
///
/// The animation starts from the currently displayed (possibly mid-flight)
/// value, so a new dataset arriving mid-transition redirects without a jump.
class ChartValueAnimator<T> {
  ChartValueAnimator({required TickerProvider vsync, required this.lerp, bool Function(T a, T b)? equals})
    : _equals = equals ?? ((a, b) => a == b),
      controller = AnimationController.unbounded(vsync: vsync, value: 1);

  final T Function(T from, T to, double t) lerp;
  final bool Function(T a, T b) _equals;
  final AnimationController controller;

  T? _from;
  T? _to;
  int? _revision;

  /// The value to paint this frame.
  T? get value {
    final to = _to;
    if (to == null) return null;
    final from = _from;
    final t = controller.value;
    if (from == null || t >= 1) return to;
    return lerp(from, to, t.clamp(0.0, 1.0));
  }

  T? get target => _to;

  bool get isAnimating => controller.isAnimating;

  /// Moves toward [target]. Animates only when [animate] is true and the data
  /// [revision] changed since the last call; layout-only changes snap.
  void sync(
    T target, {
    required int revision,
    required bool animate,
    SpringDescription? spring,
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    final previous = _to;
    final revisionChanged = _revision != null && _revision != revision;
    _revision = revision;
    if (previous == null) {
      _to = target;
      return;
    }
    if (_equals(previous, target)) return;
    if (animate && revisionChanged) {
      _from = value;
      _to = target;
      controller.value = 0;
      if (duration != null) {
        controller.animateTo(1, duration: duration, curve: curve);
      } else {
        CdsMotion.springTo(controller, 1, spring: spring ?? cdsChartUpdateSpring);
      }
    } else {
      _from = null;
      _to = target;
      controller.stop();
      controller.value = 1;
    }
  }

  void dispose() => controller.dispose();
}

bool offsetListEquals(List<ui.Offset?> a, List<ui.Offset?> b) => listEquals(a, b);

/// Draws [path] as round dots every [spacing] pixels, matching CDS dotted
/// lines (`dashIntervals: [0, 4]` with round caps).
void drawDottedPath(ui.Canvas canvas, ui.Path path, ui.Paint paint, {double spacing = 4}) {
  final points = <ui.Offset>[];
  for (final metric in path.computeMetrics()) {
    for (var d = 0.0; d <= metric.length; d += spacing) {
      final tangent = metric.getTangentForOffset(d);
      if (tangent != null) points.add(tangent.position);
    }
  }
  canvas.drawPoints(
    ui.PointMode.points,
    points,
    ui.Paint()
      ..color = paint.color
      ..shader = paint.shader
      ..strokeWidth = paint.strokeWidth
      ..strokeCap = ui.StrokeCap.round,
  );
}

/// Horizontal anchor for [paintChartText].
enum ChartTextAlign { left, center, right }

/// Vertical anchor for [paintChartText].
enum ChartTextBaseline { top, middle, bottom }

/// Lays out [text] once so callers can measure before painting.
TextPainter layoutChartText(String text, TextStyle style, TextScaler scaler, {TextDirection? direction}) {
  return TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: direction ?? TextDirection.ltr,
    textScaler: scaler,
    maxLines: 1,
  )..layout();
}

/// Paints [painter] anchored at [anchor] and returns the painted rect.
ui.Rect paintLaidOutText(
  ui.Canvas canvas,
  TextPainter painter,
  ui.Offset anchor, {
  ChartTextAlign align = ChartTextAlign.center,
  ChartTextBaseline baseline = ChartTextBaseline.middle,
}) {
  final dx = switch (align) {
    ChartTextAlign.left => anchor.dx,
    ChartTextAlign.center => anchor.dx - painter.width / 2,
    ChartTextAlign.right => anchor.dx - painter.width,
  };
  final dy = switch (baseline) {
    ChartTextBaseline.top => anchor.dy,
    ChartTextBaseline.middle => anchor.dy - painter.height / 2,
    ChartTextBaseline.bottom => anchor.dy - painter.height,
  };
  painter.paint(canvas, ui.Offset(dx, dy));
  return ui.Rect.fromLTWH(dx, dy, painter.width, painter.height);
}

/// Linear interpolation of rect lists for bars. Missing source rects grow
/// from [origin] (the baseline edge of the target rect).
List<ui.Rect?> lerpRects(List<ui.Rect?> from, List<ui.Rect?> to, double t, {required bool horizontal}) {
  return List<ui.Rect?>.generate(to.length, (i) {
    final target = to[i];
    if (target == null) return null;
    final start = i < from.length ? from[i] : null;
    final origin =
        start ??
        (horizontal
            ? ui.Rect.fromLTWH(target.left, target.top, 0, target.height)
            : ui.Rect.fromLTWH(target.left, target.bottom, target.width, 0));
    return ui.Rect.lerp(origin, target, t);
  });
}

/// Top and bottom outline of an area, in pixels. Null entries are gaps.
typedef AreaPoints = (List<ui.Offset?>, List<ui.Offset?>);

/// Interpolates `(top, bottom)` point lists for areas.
AreaPoints lerpAreaPoints(AreaPoints from, AreaPoints to, double t) =>
    (CdsChartPath.lerp(from.$1, to.$1, t), CdsChartPath.lerp(from.$2, to.$2, t));

bool areaPointsEquals(AreaPoints a, AreaPoints b) => listEquals(a.$1, b.$1) && listEquals(a.$2, b.$2);

/// Darkens a color the way d3-color `darker()` does (each channel x 0.7).
ui.Color darkerColor(ui.Color c) => ui.Color.from(
  alpha: c.a,
  red: (c.r * 0.7).clamp(0.0, 1.0),
  green: (c.g * 0.7).clamp(0.0, 1.0),
  blue: (c.b * 0.7).clamp(0.0, 1.0),
);
