import 'dart:math' as math;
import 'dart:ui';

/// Curve used to connect data points, matching the d3-shape curves CDS uses.
enum CdsChartCurve {
  /// Smooth S-shaped segments between points (d3 `curveBumpX`). CDS default.
  bump,
  catmullRom,
  linear,
  monotone,
  natural,
  step,
  stepBefore,
  stepAfter,

  /// B-spline through the control points (d3 `curveBasis`). Used by sparklines.
  basis,
}

/// Builds chart paths and transforms point arrays. Every function is pure so
/// painters and tests can share them.
abstract final class CdsChartPath {
  /// A path through [points] using [curve]. Null entries split the line into
  /// separate segments unless [connectNulls] is true. [horizontal] swaps the
  /// independent axis for `bump` and `monotone` (horizontal chart layout).
  static Path line(
    List<Offset?> points, {
    CdsChartCurve curve = CdsChartCurve.bump,
    bool connectNulls = false,
    bool horizontal = false,
  }) {
    final path = Path();
    for (final segment in segments(points, connectNulls: connectNulls)) {
      _addCurve(path, segment, curve, horizontal: horizontal, move: true);
    }
    return path;
  }

  /// A closed area between [top] and [bottom] (same length, null for gaps).
  static Path area(
    List<Offset?> top,
    List<Offset?> bottom, {
    CdsChartCurve curve = CdsChartCurve.bump,
    bool connectNulls = false,
    bool horizontal = false,
  }) {
    assert(top.length == bottom.length);
    final path = Path();
    final pairs = <(Offset, Offset)?>[
      for (var i = 0; i < top.length; i++) top[i] == null || bottom[i] == null ? null : (top[i]!, bottom[i]!),
    ];
    final runs = <List<(Offset, Offset)>>[];
    var current = <(Offset, Offset)>[];
    for (final p in pairs) {
      if (p == null) {
        if (connectNulls) continue;
        if (current.isNotEmpty) runs.add(current);
        current = [];
      } else {
        current.add(p);
      }
    }
    if (current.isNotEmpty) runs.add(current);
    for (final run in runs) {
      final upper = [for (final p in run) p.$1];
      final lower = [for (final p in run.reversed) p.$2];
      _addCurve(path, upper, curve, horizontal: horizontal, move: true);
      // d3-area draws the baseline with the same curve, walking backwards.
      path.lineTo(lower.first.dx, lower.first.dy);
      _addCurve(path, lower, curve, horizontal: horizontal, move: false);
      path.close();
    }
    return path;
  }

  /// Splits [points] into runs of consecutive non-null points.
  static List<List<Offset>> segments(List<Offset?> points, {bool connectNulls = false}) {
    final out = <List<Offset>>[];
    var current = <Offset>[];
    for (final p in points) {
      if (p == null) {
        if (connectNulls) continue;
        if (current.isNotEmpty) out.add(current);
        current = [];
      } else {
        current.add(p);
      }
    }
    if (current.isNotEmpty) out.add(current);
    return out;
  }

  /// Resamples [points] to [length] entries by interpolating along the index,
  /// so a path can morph between datasets of different sizes.
  static List<Offset?> resample(List<Offset?> points, int length) {
    if (length <= 0) return const [];
    if (points.isEmpty) return List<Offset?>.filled(length, null);
    if (points.length == length) return List<Offset?>.of(points);
    if (points.length == 1 || length == 1) {
      Offset? only;
      for (final p in points) {
        if (p != null) {
          only = p;
          break;
        }
      }
      return List<Offset?>.filled(length, only);
    }
    final scale = (points.length - 1) / (length - 1);
    return List<Offset?>.generate(length, (i) {
      final t = i * scale;
      final lo = t.floor().clamp(0, points.length - 1);
      final hi = t.ceil().clamp(0, points.length - 1);
      final a = points[lo];
      final b = points[hi];
      if (a == null || b == null) return a ?? b;
      return Offset.lerp(a, b, t - lo)!;
    });
  }

  /// Interpolates two point lists. [from] is resampled to the length of [to].
  /// A gap in [to] stays a gap; a gap in [from] grows from the target point.
  static List<Offset?> lerp(List<Offset?> from, List<Offset?> to, double t) {
    if (t >= 1) return to;
    final a = resample(from, to.length);
    return List<Offset?>.generate(to.length, (i) {
      final target = to[i];
      if (target == null) return null;
      final start = a[i] ?? target;
      return Offset.lerp(start, target, t)!;
    });
  }

  /// Index of the value in ascending [positions] closest to [target], or -1
  /// when [positions] is empty.
  static int nearestIndex(List<double> positions, double target) {
    if (positions.isEmpty) return -1;
    var lo = 0;
    var hi = positions.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (positions[mid] < target) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    if (lo > 0 && (target - positions[lo - 1]).abs() <= (positions[lo] - target).abs()) {
      return lo - 1;
    }
    return lo;
  }

  /// Largest-Triangle-Three-Buckets downsampling, ported from CDS. Returns
  /// [data] unchanged when [threshold] is 0 or not smaller than its length.
  static List<double> largestTriangleThreeBucket(List<double> data, double threshold) {
    final f = data.length;
    if (threshold >= f || threshold == 0 || f < 3) return data;
    final out = <double>[data[0]];
    final p = (f - 2) / (threshold - 2);
    var c = 0;
    var v = 0.0;
    var w = 0;
    final buckets = (threshold - 2).ceil();
    for (var e = 0; e < buckets; e++) {
      var g = 0.0;
      var h = 0.0;
      var a = ((e + 1) * p).floor() + 1;
      var d = ((e + 2) * p).floor() + 1;
      d = d < f ? d : f;
      final k = d - a;
      for (; a < d; a++) {
        g += a;
        h += data[a];
      }
      if (k > 0) {
        g /= k;
        h /= k;
      }
      a = (e * p).floor() + 1;
      d = ((e + 1) * p).floor() + 1;
      final kx = c.toDouble();
      final x = data[c];
      var best = -1.0;
      for (; a < d && a < f; a++) {
        final u = 0.5 * ((kx - g) * (data[a] - x) - (kx - a) * (h - x)).abs();
        if (u > best) {
          best = u;
          v = data[a];
          w = a;
        }
      }
      out.add(v);
      c = w;
    }
    out.add(data[f - 1]);
    return out;
  }

  static void _addCurve(
    Path path,
    List<Offset> pts,
    CdsChartCurve curve, {
    required bool horizontal,
    required bool move,
  }) {
    if (pts.isEmpty) return;
    void start(Offset p) => move ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    if (pts.length == 1) {
      start(pts.first);
      // A lone point still needs a drawable segment for round caps.
      path.lineTo(pts.first.dx, pts.first.dy);
      return;
    }
    switch (curve) {
      case CdsChartCurve.linear:
        start(pts.first);
        for (final p in pts.skip(1)) {
          path.lineTo(p.dx, p.dy);
        }
      case CdsChartCurve.bump:
        start(pts.first);
        for (var i = 1; i < pts.length; i++) {
          final a = pts[i - 1];
          final b = pts[i];
          if (horizontal) {
            final my = (a.dy + b.dy) / 2;
            path.cubicTo(a.dx, my, b.dx, my, b.dx, b.dy);
          } else {
            final mx = (a.dx + b.dx) / 2;
            path.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
          }
        }
      case CdsChartCurve.step:
      case CdsChartCurve.stepBefore:
      case CdsChartCurve.stepAfter:
        final t = switch (curve) {
          CdsChartCurve.stepBefore => 0.0,
          CdsChartCurve.stepAfter => 1.0,
          _ => 0.5,
        };
        start(pts.first);
        for (var i = 1; i < pts.length; i++) {
          final a = pts[i - 1];
          final b = pts[i];
          if (t <= 0) {
            path.lineTo(a.dx, b.dy);
          } else {
            final x1 = a.dx * (1 - t) + b.dx * t;
            path.lineTo(x1, a.dy);
            path.lineTo(x1, b.dy);
          }
          path.lineTo(b.dx, b.dy);
        }
      case CdsChartCurve.basis:
        _basis(path, pts, start);
      case CdsChartCurve.monotone:
        _monotone(path, pts, start, horizontal: horizontal);
      case CdsChartCurve.natural:
        _natural(path, pts, start);
      case CdsChartCurve.catmullRom:
        _catmullRom(path, pts, start);
    }
  }

  static void _basis(Path path, List<Offset> pts, void Function(Offset) start) {
    start(pts.first);
    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
      return;
    }
    var x0 = pts[0].dx, y0 = pts[0].dy, x1 = pts[1].dx, y1 = pts[1].dy;
    path.lineTo((5 * x0 + x1) / 6, (5 * y0 + y1) / 6);
    void seg(double x, double y) {
      path.cubicTo(
        (2 * x0 + x1) / 3,
        (2 * y0 + y1) / 3,
        (x0 + 2 * x1) / 3,
        (y0 + 2 * y1) / 3,
        (x0 + 4 * x1 + x) / 6,
        (y0 + 4 * y1 + y) / 6,
      );
    }

    for (var i = 2; i < pts.length; i++) {
      seg(pts[i].dx, pts[i].dy);
      x0 = x1;
      y0 = y1;
      x1 = pts[i].dx;
      y1 = pts[i].dy;
    }
    seg(x1, y1);
    path.lineTo(x1, y1);
  }

  static void _monotone(Path path, List<Offset> input, void Function(Offset) start, {required bool horizontal}) {
    // MonotoneY is MonotoneX with the axes swapped.
    final pts = horizontal ? [for (final p in input) Offset(p.dy, p.dx)] : input;
    void cubic(double ax, double ay, double bx, double by, double x, double y) =>
        horizontal ? path.cubicTo(ay, ax, by, bx, y, x) : path.cubicTo(ax, ay, bx, by, x, y);
    final first = pts.first;
    start(horizontal ? Offset(first.dy, first.dx) : first);
    final n = pts.length;
    if (n == 2) {
      final p = input[1];
      path.lineTo(p.dx, p.dy);
      return;
    }
    double sign(double v) => v < 0 ? -1 : 1;
    final tangents = List<double>.filled(n, 0);
    for (var i = 1; i < n - 1; i++) {
      final h0 = pts[i].dx - pts[i - 1].dx;
      final h1 = pts[i + 1].dx - pts[i].dx;
      final s0 = h0 == 0 ? 0.0 : (pts[i].dy - pts[i - 1].dy) / h0;
      final s1 = h1 == 0 ? 0.0 : (pts[i + 1].dy - pts[i].dy) / h1;
      final p = (h0 + h1) == 0 ? 0.0 : (s0 * h1 + s1 * h0) / (h0 + h1);
      final t = (sign(s0) + sign(s1)) * math.min(math.min(s0.abs(), s1.abs()), 0.5 * p.abs());
      tangents[i] = t.isFinite ? t : 0;
    }
    double endSlope(int a, int b, double t) {
      final h = pts[b].dx - pts[a].dx;
      return h != 0 ? (3 * (pts[b].dy - pts[a].dy) / h - t) / 2 : t;
    }

    tangents[0] = endSlope(0, 1, tangents[1]);
    tangents[n - 1] = endSlope(n - 2, n - 1, tangents[n - 2]);
    for (var i = 1; i < n; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final dx = (b.dx - a.dx) / 3;
      cubic(a.dx + dx, a.dy + dx * tangents[i - 1], b.dx - dx, b.dy - dx * tangents[i], b.dx, b.dy);
    }
  }

  static List<List<double>> _controlPoints(List<double> x) {
    final n = x.length - 1;
    final a = List<double>.filled(n, 0), b = List<double>.filled(n, 0), r = List<double>.filled(n, 0);
    a[0] = 0;
    b[0] = 2;
    r[0] = x[0] + 2 * x[1];
    for (var i = 1; i < n - 1; ++i) {
      a[i] = 1;
      b[i] = 4;
      r[i] = 4 * x[i] + 2 * x[i + 1];
    }
    a[n - 1] = 2;
    b[n - 1] = 7;
    r[n - 1] = 8 * x[n - 1] + x[n];
    for (var i = 1; i < n; ++i) {
      final m = a[i] / b[i - 1];
      b[i] -= m;
      r[i] -= m * r[i - 1];
    }
    a[n - 1] = r[n - 1] / b[n - 1];
    for (var i = n - 2; i >= 0; --i) {
      a[i] = (r[i] - a[i + 1]) / b[i];
    }
    b[n - 1] = (x[n] + a[n - 1]) / 2;
    for (var i = 0; i < n - 1; ++i) {
      b[i] = 2 * x[i + 1] - a[i + 1];
    }
    return [a, b];
  }

  static void _natural(Path path, List<Offset> pts, void Function(Offset) start) {
    start(pts.first);
    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
      return;
    }
    final px = _controlPoints([for (final p in pts) p.dx]);
    final py = _controlPoints([for (final p in pts) p.dy]);
    for (var i = 1; i < pts.length; i++) {
      path.cubicTo(px[0][i - 1], py[0][i - 1], px[1][i - 1], py[1][i - 1], pts[i].dx, pts[i].dy);
    }
  }

  static void _catmullRom(Path path, List<Offset> pts, void Function(Offset) start, {double alpha = 0.5}) {
    start(pts.first);
    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
      return;
    }
    const epsilon = 1e-12;
    double dist2a(Offset a, Offset b) => math.pow((a - b).distanceSquared, alpha).toDouble();
    // Duplicate the endpoints so every segment has neighbors, as d3 does.
    final p = [pts.first, ...pts, pts.last];
    for (var i = 1; i < p.length - 2; i++) {
      final p0 = p[i - 1], p1 = p[i], p2 = p[i + 1], p3 = p[i + 2];
      final l01_2a = i == 1 ? 0.0 : dist2a(p0, p1);
      final l12_2a = dist2a(p1, p2);
      final l23_2a = i == p.length - 3 ? 0.0 : dist2a(p2, p3);
      final l01a = math.sqrt(l01_2a), l12a = math.sqrt(l12_2a), l23a = math.sqrt(l23_2a);
      var c1 = p1, c2 = p2;
      if (l01a > epsilon) {
        final a = 2 * l01_2a + 3 * l01a * l12a + l12_2a;
        final n = 3 * l01a * (l01a + l12a);
        c1 = Offset(
          (p1.dx * a - p0.dx * l12_2a + p2.dx * l01_2a) / n,
          (p1.dy * a - p0.dy * l12_2a + p2.dy * l01_2a) / n,
        );
      }
      if (l23a > epsilon) {
        final b = 2 * l23_2a + 3 * l23a * l12a + l12_2a;
        final m = 3 * l23a * (l23a + l12a);
        c2 = Offset(
          (p2.dx * b + p1.dx * l23_2a - p3.dx * l12_2a) / m,
          (p2.dy * b + p1.dy * l23_2a - p3.dy * l12_2a) / m,
        );
      }
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
  }
}
