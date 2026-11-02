import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// A closed numeric interval, used for both data domains and pixel ranges.
@immutable
class CdsAxisBounds {
  const CdsAxisBounds(this.min, this.max);

  final double min;
  final double max;

  double get span => max - min;

  @override
  bool operator ==(Object other) => other is CdsAxisBounds && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'CdsAxisBounds($min, $max)';
}

/// Maps data values to pixels along one axis.
///
/// Charts build these for you. Use them directly when you paint custom
/// elements inside a [CdsCartesianChart] through `CdsCartesianChartScope.of`.
sealed class CdsChartScale {
  const CdsChartScale();

  /// The data interval this scale covers.
  CdsAxisBounds get domain;

  /// The pixel interval this scale maps onto. `min` may be greater than `max`
  /// (y axes grow upward).
  CdsAxisBounds get range;

  /// Pixel position of [value]. For band scales [value] is a category index and
  /// the result is the band's center.
  double call(double value);

  /// Data value at [pixel]. For band scales, the nearest category index.
  double invert(double pixel);
}

/// A linear scale, the equivalent of d3 `scaleLinear`.
class CdsLinearScale extends CdsChartScale {
  const CdsLinearScale({required this.domain, required this.range});

  @override
  final CdsAxisBounds domain;
  @override
  final CdsAxisBounds range;

  @override
  double call(double value) {
    final d = domain.span;
    // d3 maps a zero-width domain to the middle of the range.
    if (d == 0) return (range.min + range.max) / 2;
    return range.min + (value - domain.min) / d * range.span;
  }

  @override
  double invert(double pixel) {
    final r = range.span;
    if (r == 0) return (domain.min + domain.max) / 2;
    return domain.min + (pixel - range.min) / r * domain.span;
  }

  /// Extends the domain to round values, like d3 `scale.nice(count)`.
  CdsLinearScale nice([int count = 10]) =>
      CdsLinearScale(domain: CdsChartTicks.niceDomain(domain, count), range: range);

  /// Round tick values inside the domain, like d3 `scale.ticks(count)`.
  List<double> ticks([int count = 10]) => CdsChartTicks.ticks(domain.min, domain.max, count);
}

/// Where along a band a point is anchored.
enum CdsPointAnchor { stepStart, bandStart, middle, bandEnd, stepEnd }

/// A band scale for categories, the equivalent of d3 `scaleBand` with
/// `paddingInner(padding)` and `paddingOuter(padding / 2)`.
class CdsBandScale extends CdsChartScale {
  CdsBandScale({required int count, required this.range, this.padding = 0.3}) : count = math.max(0, count) {
    final start = math.min(range.min, range.max);
    final stop = math.max(range.min, range.max);
    final paddingOuter = padding / 2;
    final n = this.count;
    step = (stop - start) / math.max(1, n - padding + paddingOuter * 2);
    _start = start + (stop - start - step * (n - padding)) * 0.5;
    bandwidth = step * (1 - padding);
  }

  /// Number of categories.
  final int count;

  /// Fraction of each step left empty between bands (0..1).
  final double padding;
  @override
  final CdsAxisBounds range;

  /// Distance between the starts of adjacent bands.
  late final double step;

  /// Width of one band.
  late final double bandwidth;
  late final double _start;

  bool get _reversed => range.max < range.min;

  @override
  CdsAxisBounds get domain => CdsAxisBounds(0, math.max(0, count - 1).toDouble());

  /// Start of the band at [index].
  double bandStart(int index) {
    final i = _reversed ? count - 1 - index : index;
    return _start + step * i;
  }

  /// Position within the band at [index] for [anchor].
  double anchorOf(int index, CdsPointAnchor anchor) {
    final start = bandStart(index);
    final stepStart = start - (step - bandwidth) / 2;
    return switch (anchor) {
      CdsPointAnchor.stepStart => stepStart,
      CdsPointAnchor.bandStart => start,
      CdsPointAnchor.middle => start + bandwidth / 2,
      CdsPointAnchor.bandEnd => start + bandwidth,
      CdsPointAnchor.stepEnd => stepStart + step,
    };
  }

  @override
  double call(double value) => anchorOf(value.round(), CdsPointAnchor.middle);

  @override
  double invert(double pixel) {
    if (count == 0) return 0;
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < count; i++) {
      final d = (anchorOf(i, CdsPointAnchor.middle) - pixel).abs();
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    return best.toDouble();
  }
}

/// Tick generation shared by the axes. Ports d3-array `ticks`, `tickIncrement`
/// and d3-scale `nice`, plus CDS's pixel-interval tick spacing.
abstract final class CdsChartTicks {
  static final double _e10 = math.sqrt(50);
  static final double _e5 = math.sqrt(10);
  static final double _e2 = math.sqrt(2);

  static (double, double, double) _tickSpec(double start, double stop, double count) {
    final step = (stop - start) / math.max(0, count);
    final power = (math.log(step) / math.ln10).floor();
    final error = step / math.pow(10, power);
    final factor = error >= _e10
        ? 10
        : error >= _e5
        ? 5
        : error >= _e2
        ? 2
        : 1;
    double i1, i2, inc;
    if (power < 0) {
      inc = math.pow(10, -power) / factor;
      i1 = (start * inc).roundToDouble();
      i2 = (stop * inc).roundToDouble();
      if (i1 / inc < start) i1++;
      if (i2 / inc > stop) i2--;
      inc = -inc;
    } else {
      inc = math.pow(10, power) * factor.toDouble();
      i1 = (start / inc).roundToDouble();
      i2 = (stop / inc).roundToDouble();
      if (i1 * inc < start) i1++;
      if (i2 * inc > stop) i2--;
    }
    if (i2 < i1 && 0.5 <= count && count < 2) return _tickSpec(start, stop, count * 2);
    return (i1, i2, inc);
  }

  /// Step between round ticks; negative values mean 1 / step (d3 convention).
  static double tickIncrement(double start, double stop, int count) {
    if (!(start.isFinite && stop.isFinite) || stop == start) return 0;
    return _tickSpec(start, stop, count.toDouble()).$3;
  }

  /// About [count] round values between [start] and [stop], inclusive.
  static List<double> ticks(double start, double stop, int count) {
    if (count <= 0 || !start.isFinite || !stop.isFinite) return const [];
    if (start == stop) return [start];
    final reverse = stop < start;
    final a = reverse ? stop : start;
    final b = reverse ? start : stop;
    final (i1, i2, inc) = _tickSpec(a, b, count.toDouble());
    if (!(i2 >= i1)) return const [];
    final n = (i2 - i1 + 1).round();
    final out = List<double>.generate(n, (i) => inc < 0 ? (i1 + i) / -inc : (i1 + i) * inc);
    return reverse ? out.reversed.toList() : out;
  }

  /// Extends [domain] outward to round values (d3 `nice`).
  static CdsAxisBounds niceDomain(CdsAxisBounds domain, [int count = 10]) {
    var start = domain.min;
    var stop = domain.max;
    if (start == stop || !start.isFinite || !stop.isFinite) return domain;
    final reversed = stop < start;
    if (reversed) {
      final t = start;
      start = stop;
      stop = t;
    }
    double? prestep;
    for (var i = 0; i < 10; i++) {
      final step = tickIncrement(start, stop, count);
      if (step == prestep) break;
      if (step > 0) {
        start = (start / step).floorToDouble() * step;
        stop = (stop / step).ceilToDouble() * step;
      } else if (step < 0) {
        start = (start * step).ceilToDouble() / step;
        stop = (stop * step).floorToDouble() / step;
      } else {
        break;
      }
      prestep = step;
    }
    return reversed ? CdsAxisBounds(stop, start) : CdsAxisBounds(start, stop);
  }

  /// Rounds a raw step to 1, 2 or 5 times a power of ten, clamped to
  /// [minStep]..[maxStep].
  static double niceStep(double roughStep, {double? minStep, double? maxStep}) {
    if (roughStep <= 0) return minStep ?? 1;
    final magnitude = math.pow(10, (math.log(roughStep) / math.ln10).floor()).toDouble();
    final residual = roughStep / magnitude;
    final rounded = residual <= 1
        ? 1
        : residual <= 2
        ? 2
        : residual <= 5
        ? 5
        : 10;
    var step = rounded * magnitude;
    if (minStep != null && step < minStep) step = minStep;
    if (maxStep != null && step > maxStep) step = maxStep;
    return step;
  }

  /// Ticks spaced roughly [tickInterval] pixels apart that always include the
  /// first domain value, the CDS default for x axes.
  static List<double> evenlyDistributed(
    CdsLinearScale scale,
    double tickInterval, {
    int minTickCount = 4,
    double? minStep,
    double? maxStep,
  }) {
    final rangeSize = scale.range.span.abs();
    final tickCount = math.max((rangeSize / tickInterval).floor(), minTickCount);
    final domainMin = scale.domain.min;
    final domainMax = scale.domain.max;
    if (tickCount < 1) return const [];
    if (tickCount == 1 || domainMin == domainMax) return [domainMin];
    if (tickCount == 2) return [domainMin, domainMax];
    final step = niceStep((domainMax - domainMin) / (tickCount - 1), minStep: minStep, maxStep: maxStep);
    final ticks = <double>[domainMin];
    var current = domainMin + step;
    while (current < domainMax) {
      ticks.add(double.parse(current.toStringAsFixed(10)));
      current += step;
    }
    final last = ticks.last;
    final distanceToMax = domainMax - last;
    final tolerance = step * 0.0001;
    final includeMax = (distanceToMax - step).abs() < tolerance || distanceToMax > step * 0.5;
    if (includeMax && domainMax != last) ticks.add(domainMax);
    return ticks;
  }
}
