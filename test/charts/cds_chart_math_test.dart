import 'dart:ui';

import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CdsLinearScale', () {
    test('maps domain to range and inverts', () {
      const s = CdsLinearScale(domain: CdsAxisBounds(0, 10), range: CdsAxisBounds(100, 0));
      expect(s(0), 100);
      expect(s(10), 0);
      expect(s(2.5), 75);
      expect(s.invert(75), 2.5);
    });

    test('a zero-width domain maps to the middle of the range', () {
      const s = CdsLinearScale(domain: CdsAxisBounds(5, 5), range: CdsAxisBounds(0, 200));
      expect(s(5), 100);
      expect(s(999), 100);
    });

    test('nice rounds the domain outward like d3', () {
      const s = CdsLinearScale(domain: CdsAxisBounds(1.2, 97.8), range: CdsAxisBounds(0, 1));
      expect(s.nice().domain, const CdsAxisBounds(0, 100));
      expect(CdsChartTicks.niceDomain(const CdsAxisBounds(-3.3, 41)), const CdsAxisBounds(-5, 45));
    });

    test('ticks match d3', () {
      expect(CdsChartTicks.ticks(0, 100, 5), [0, 20, 40, 60, 80, 100]);
      expect(CdsChartTicks.ticks(0, 1, 5), [0, 0.2, 0.4, 0.6, 0.8, 1.0]);
      expect(CdsChartTicks.ticks(3, 3, 5), [3]);
      expect(CdsChartTicks.ticks(10, 0, 2), [10, 5, 0]);
    });

    test('evenly distributed ticks include the first value and step in 1/2/5', () {
      const s = CdsLinearScale(domain: CdsAxisBounds(0, 10), range: CdsAxisBounds(0, 400));
      final ticks = CdsChartTicks.evenlyDistributed(s, 32, minStep: 1);
      expect(ticks.first, 0);
      expect(ticks.last, 10);
      expect(ticks, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });
  });

  group('CdsBandScale', () {
    test('matches d3 scaleBand with inner padding and half outer padding', () {
      final s = CdsBandScale(count: 4, range: const CdsAxisBounds(0, 100), padding: 0.2);
      // step = 100 / (4 - 0.2 + 0.2) = 25
      expect(s.step, closeTo(25, 1e-9));
      expect(s.bandwidth, closeTo(20, 1e-9));
      expect(s.bandStart(0), closeTo(2.5, 1e-9));
      expect(s(0), closeTo(12.5, 1e-9));
      expect(s.anchorOf(3, CdsPointAnchor.stepEnd), closeTo(100, 1e-9));
    });

    test('invert returns the nearest band', () {
      final s = CdsBandScale(count: 3, range: const CdsAxisBounds(0, 90), padding: 0);
      expect(s.invert(0), 0);
      expect(s.invert(46), 1);
      expect(s.invert(500), 2);
    });
  });

  group('CdsChartPath', () {
    test('nearestIndex finds the closest ascending position', () {
      const xs = [0.0, 10.0, 20.0, 30.0];
      expect(CdsChartPath.nearestIndex(xs, -5), 0);
      expect(CdsChartPath.nearestIndex(xs, 4.9), 0);
      expect(CdsChartPath.nearestIndex(xs, 5.1), 1);
      expect(CdsChartPath.nearestIndex(xs, 26), 3);
      expect(CdsChartPath.nearestIndex(xs, 99), 3);
      expect(CdsChartPath.nearestIndex(const [], 1), -1);
    });

    test('resample keeps endpoints and interpolates between them', () {
      final out = CdsChartPath.resample(const [Offset(0, 0), Offset(10, 10)], 3);
      expect(out, const [Offset(0, 0), Offset(5, 5), Offset(10, 10)]);
      final down = CdsChartPath.resample(const [Offset(0, 0), Offset(1, 1), Offset(2, 2), Offset(3, 3)], 2);
      expect(down, const [Offset(0, 0), Offset(3, 3)]);
      expect(CdsChartPath.resample(const [], 2), [null, null]);
      // A non-nullable single-point list resamples without a type error.
      expect(CdsChartPath.resample(<Offset>[const Offset(1, 1)], 3), const [Offset(1, 1), Offset(1, 1), Offset(1, 1)]);
    });

    test('lerp morphs lists of different lengths and keeps target gaps', () {
      const from = [Offset(0, 0), Offset(10, 0)];
      const to = [Offset(0, 10), null, Offset(10, 10)];
      final mid = CdsChartPath.lerp(from, to, 0.5);
      expect(mid[0], const Offset(0, 5));
      expect(mid[1], isNull);
      expect(mid[2], const Offset(10, 5));
      expect(CdsChartPath.lerp(from, to, 1), to);
    });

    test('segments split on nulls unless connectNulls', () {
      const pts = [Offset(0, 0), null, Offset(2, 2), Offset(3, 3)];
      expect(CdsChartPath.segments(pts).length, 2);
      expect(CdsChartPath.segments(pts, connectNulls: true).length, 1);
    });

    test('every curve builds a path through the endpoints', () {
      const pts = [Offset(0, 50), Offset(25, 10), Offset(50, 40), Offset(75, 0), Offset(100, 30)];
      for (final curve in CdsChartCurve.values) {
        final path = CdsChartPath.line(pts, curve: curve);
        final bounds = path.getBounds();
        expect(bounds.left, closeTo(0, 0.01), reason: '$curve');
        expect(bounds.right, closeTo(100, 0.01), reason: '$curve');
      }
    });

    test('a single point yields a path at that point', () {
      final path = CdsChartPath.line(const [Offset(5, 5)]);
      expect(path.getBounds().center, const Offset(5, 5));
    });

    test('area closes between top and bottom', () {
      final path = CdsChartPath.area(
        const [Offset(0, 0), Offset(10, 5)],
        const [Offset(0, 20), Offset(10, 20)],
        curve: CdsChartCurve.linear,
      );
      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 10, 20));
    });

    test('LTTB keeps the first and last values and reduces to the threshold', () {
      final data = List<double>.generate(100, (i) => (i % 7).toDouble());
      final out = CdsChartPath.largestTriangleThreeBucket(data, 10);
      expect(out.length, 10);
      expect(out.first, data.first);
      expect(out.last, data.last);
      expect(CdsChartPath.largestTriangleThreeBucket(data, 200), same(data));
    });
  });

  group('stacking', () {
    test('stacks positive values up and negative values down from the baseline', () {
      final stacked = cdsStackSeries(const [
        CdsChartSeries(id: 'a', data: [1, -1], stackId: 's'),
        CdsChartSeries(id: 'b', data: [2, -2], stackId: 's'),
        CdsChartSeries(id: 'c', data: [5, null]),
      ]);
      expect(stacked['a'], [(0.0, 1.0), (-1.0, 0.0)]);
      expect(stacked['b'], [(1.0, 3.0), (-3.0, -1.0)]);
      expect(stacked['c'], [(0.0, 5.0), null]);
      expect(cdsStackedExtent(stacked), const CdsAxisBounds(-3, 5));
    });

    test('percentages split each group by its total and drop empty groups', () {
      final series = cdsPercentageSeries([
        const CdsPercentageBarSeries(id: 'a', data: [40, null, 0]),
        const CdsPercentageBarSeries(id: 'b', data: [-10, 60, 0]),
        CdsPercentageBarSeries.single(id: 'c', value: 60),
      ]);
      expect(series[0].data, [40, null, null]);
      expect(series[1].data, [0, 100, null]);
      expect(series[2].data, [60, null, null]);
    });
  });

  test('cdsChartFormatValue trims trailing zeros', () {
    expect(cdsChartFormatValue(12), '12');
    expect(cdsChartFormatValue(12.5), '12.5');
    expect(cdsChartFormatValue(12.345), '12.35');
    expect(cdsChartFormatValue(double.nan), '');
  });
}
