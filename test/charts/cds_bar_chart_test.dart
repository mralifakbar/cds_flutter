import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import 'chart_test_utils.dart';

/// Captures the chart data so layout functions can be tested against it.
class _Probe extends StatelessWidget {
  const _Probe(this.onData);

  final void Function(CdsCartesianChartData) onData;

  @override
  Widget build(BuildContext context) {
    onData(CdsCartesianChartScope.of(context));
    return const SizedBox.shrink();
  }
}

void main() {
  testWidgets('bar chart renders grouped, stacked and horizontal bars in light and dark', (tester) async {
    for (final brightness in Brightness.values) {
      for (final layout in CdsChartLayout.values) {
        for (final stacked in [false, true]) {
          await pumpCds(
            tester,
            CdsBarChart(
              height: 200,
              layout: layout,
              stacked: stacked,
              showXAxis: true,
              showYAxis: true,
              legend: const CdsLegend(),
              series: const [
                CdsChartSeries(id: 'a', label: 'A', data: [4, -2, 6, null]),
                CdsChartSeries(id: 'b', label: 'B', data: [3, 5, 1, 2], color: CdsColor.fgWarning),
              ],
            ),
            brightness: brightness,
          );
          expect(tester.takeException(), isNull, reason: '$brightness $layout $stacked');
        }
      }
    }
  });

  testWidgets('grouped bars split the band and stacked bars share it', (tester) async {
    late CdsCartesianChartData data;
    await pumpCds(
      tester,
      CdsBarChart(
        width: 300,
        height: 200,
        inset: const CdsChartInset(),
        series: const [
          CdsChartSeries(id: 'a', data: [4, 2]),
          CdsChartSeries(id: 'b', data: [1, 3]),
        ],
        children: [_Probe((d) => data = d)],
      ),
    );
    final grouped = cdsBarLayout(data);
    expect(grouped.length, 4);
    final a0 = grouped.firstWhere((b) => b.seriesId == 'a' && b.index == 0).rect;
    final b0 = grouped.firstWhere((b) => b.seriesId == 'b' && b.index == 0).rect;
    expect(a0.right, lessThan(b0.left));
    expect(a0.bottom, closeTo(200, 0.01));
    expect(grouped.every((b) => b.roundHigh && !b.roundLow), isTrue);

    await pumpCds(
      tester,
      CdsBarChart(
        width: 300,
        height: 200,
        inset: const CdsChartInset(),
        stacked: true,
        series: const [
          CdsChartSeries(id: 'a', data: [4, 2]),
          CdsChartSeries(id: 'b', data: [1, 3]),
        ],
        children: [_Probe((d) => data = d)],
      ),
    );
    final stacked = cdsBarLayout(data, stackGap: 2);
    final sa = stacked.firstWhere((b) => b.seriesId == 'a' && b.index == 0).rect;
    final sb = stacked.firstWhere((b) => b.seriesId == 'b' && b.index == 0).rect;
    expect(sa.left, sb.left);
    expect(sa.top - sb.bottom, closeTo(2, 0.01));
  });

  testWidgets('bars scrub to the nearest category', (tester) async {
    final positions = <int?>[];
    final haptics = HapticLog(tester);
    await pumpCds(
      tester,
      CdsBarChart(
        width: 300,
        height: 200,
        enableScrubbing: true,
        onScrubberPositionChange: positions.add,
        series: const [
          CdsChartSeries(id: 'a', data: [1, 2, 3]),
        ],
        children: const [CdsScrubber()],
      ),
    );
    final origin = tester.getTopLeft(find.byType(CdsBarChart));
    final gesture = await tester.startGesture(origin + const Offset(30, 100));
    await gesture.moveTo(origin + const Offset(280, 100));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(positions, [0, 2, null]);
    expect(haptics.selections, 2);
  });

  testWidgets('percentage bar chart renders and summarizes shares', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(
      tester,
      CdsPercentageBarChart(
        height: 16,
        stackGap: 2,
        borderRadius: 1000,
        series: [
          CdsPercentageBarSeries.single(id: 'buy', value: 75, label: 'Buy', color: CdsColor.fgPositive),
          CdsPercentageBarSeries.single(id: 'sell', value: 25, label: 'Sell', color: CdsColor.fgNegative),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Percentage bar. Buy 75%, Sell 25%'), findsOneWidget);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('percentage bar chart with every group at zero draws nothing and does not throw', (tester) async {
    await pumpCds(
      tester,
      const CdsPercentageBarChart(
        height: 100,
        showXAxis: true,
        showYAxis: true,
        yAxis: CdsAxisConfig(data: ['Q1', 'Q2']),
        yAxisStyle: CdsYAxis(position: CdsYAxisPosition.left),
        series: [
          CdsPercentageBarSeries(id: 'a', data: [0, null]),
          CdsPercentageBarSeries(id: 'b', data: [-5, 0]),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('area chart renders every fill type, stacked, with lines', (tester) async {
    for (final type in CdsChartAreaType.values) {
      await pumpCds(
        tester,
        CdsAreaChart(
          height: 200,
          type: type,
          stacked: true,
          showLines: true,
          showYAxis: true,
          series: const [
            CdsAreaSeries(id: 'a', data: [4, 6, 5, 8], color: CdsColor.fgPositive),
            CdsAreaSeries(id: 'b', data: [2, null, 4, 3], color: CdsColor.fgWarning),
          ],
        ),
        brightness: type == CdsChartAreaType.dotted ? Brightness.dark : Brightness.light,
      );
      expect(tester.takeException(), isNull, reason: '$type');
    }
  });

  testWidgets('area chart includes the baseline in its domain', (tester) async {
    late CdsCartesianChartData data;
    await pumpCds(
      tester,
      CdsAreaChart(
        height: 200,
        series: const [
          CdsAreaSeries(id: 'a', data: [40, 60]),
        ],
        children: [_Probe((d) => data = d)],
      ),
    );
    expect(data.yScale.domain.min, 0);
  });

  testWidgets('bar data changes animate and settle', (tester) async {
    Widget chart(List<double?> d) => CdsBarChart(
      height: 200,
      series: [CdsChartSeries(id: 'a', data: d)],
    );
    await pumpCds(tester, chart(const [1, 2, 3]));
    await pumpCds(tester, chart(const [3, 1, 2, 5]), settle: false);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('legend can sit on any side', (tester) async {
    for (final position in CdsLegendPosition.values) {
      await pumpCds(
        tester,
        CdsBarChart(
          height: 160,
          legend: CdsLegend(direction: position.index > 1 ? Axis.vertical : Axis.horizontal),
          legendPosition: position,
          series: const [
            CdsChartSeries(id: 'a', label: 'Alpha', data: [1, 2, 3]),
          ],
        ),
      );
      expect(tester.takeException(), isNull, reason: '$position');
      expect(find.text('Alpha'), findsOneWidget);
    }
  });
}
