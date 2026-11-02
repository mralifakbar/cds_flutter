import 'dart:ui';

import 'package:cds_flutter/cds_flutter.dart';
import 'package:cds_flutter/src/charts/internal/sparkline_painter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import 'chart_test_utils.dart';

void main() {
  testWidgets('renders every stroke and fill type in light and dark', (tester) async {
    for (final brightness in Brightness.values) {
      for (final stroke in CdsSparklineStrokeType.values) {
        for (final fill in CdsSparklineFillType.values) {
          await pumpCds(
            tester,
            CdsSparkline(
              data: sampleValues,
              width: 200,
              height: 80,
              color: CdsColor.fgPositive,
              strokeType: stroke,
              fill: true,
              fillType: fill,
              yAxisScalingFactor: 0.8,
            ),
            brightness: brightness,
          );
          expect(tester.takeException(), isNull);
        }
      }
    }
    await pumpCds(tester, const CdsSparklineGradient(data: sampleValues, width: 64, height: 20, fill: true));
    expect(tester.takeException(), isNull);
  });

  testWidgets('handles empty, single and flat data', (tester) async {
    for (final data in const [
      <double>[],
      [5.0],
      [3.0, 3.0, 3.0],
      [1.0, double.nan, 2.0],
    ]) {
      await pumpCds(tester, CdsSparkline(data: data, width: 64, height: 20));
      expect(tester.takeException(), isNull, reason: '$data');
    }
  });

  testWidgets('labels itself with the lowest, highest and latest value', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const CdsSparkline(data: sampleValues, width: 64, height: 20));
    expect(find.bySemanticsLabel('Trend: lowest 10, highest 98, latest 22'), findsOneWidget);
    await pumpCds(tester, const CdsSparkline(data: sampleValues, width: 64, height: 20, semanticLabel: 'Sample asset'));
    expect(find.bySemanticsLabel('Sample asset'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('new data animates over 450ms, instantly under reduced motion', (tester) async {
    await pumpCds(tester, const CdsSparkline(data: sampleValues, width: 100, height: 40));
    await pumpCds(tester, const CdsSparkline(data: [5, 4, 3, 2, 1], width: 100, height: 40), settle: false);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);

    await pumpCds(tester, const CdsSparkline(data: sampleValues, width: 100, height: 40), disableAnimations: true);
    await pumpCds(
      tester,
      const CdsSparkline(data: [5, 4, 3], width: 100, height: 40),
      disableAnimations: true,
      settle: false,
    );
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  test('sparkline geometry matches the CDS range and transform', () {
    final pts = SparklineGeometry.indexPoints(const [1, 3, 2], const Size(100, 50), null);
    expect(pts.first.dx, 2);
    // x domain is [0, n], so the last point stops one step short of the edge.
    expect(pts.last.dx, closeTo(2 + 2 / 3 * 96, 1e-9));
    expect(pts.first.dy, 48);
    expect(pts[1].dy, 2);
    expect(SparklineGeometry.yTranslate(50, null), 0);
    expect(SparklineGeometry.yTranslate(50, 0.5), closeTo(25 - 22 / 2, 1e-9));
    final flat = SparklineGeometry.indexPoints(const [4, 4], const Size(100, 50), null);
    expect(flat.every((p) => p.dy == 25), isTrue);
  });
}
