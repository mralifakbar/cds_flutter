import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import 'chart_test_utils.dart';

const _five = [10.0, 20.0, 15.0, 30.0, 25.0];

Widget _chart({
  List<double?> data = _five,
  ValueChanged<int?>? onChange,
  FocusNode? focusNode,
  bool showAxes = false,
  List<Widget> children = const [CdsScrubber()],
}) {
  return CdsLineChart(
    width: 300,
    height: 200,
    enableScrubbing: true,
    onScrubberPositionChange: onChange,
    focusNode: focusNode,
    showXAxis: showAxes,
    showYAxis: showAxes,
    showArea: true,
    points: true,
    series: [CdsLineSeries(id: 'prices', label: 'Sample', data: data)],
    children: children,
  );
}

void main() {
  // Default inset is 16px on each side, so the 5 points sit at x = 16, 83, 150, 217, 284.
  Offset at(WidgetTester tester, double x) => tester.getTopLeft(find.byType(CdsLineChart)) + Offset(x, 100);

  testWidgets('renders in light and dark without exceptions', (tester) async {
    await pumpCds(tester, _chart(showAxes: true));
    expect(tester.takeException(), isNull);
    await pumpCds(tester, _chart(showAxes: true), brightness: Brightness.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('drag follows the finger, snaps to the nearest index and fires haptics on change only', (tester) async {
    final haptics = HapticLog(tester);
    final positions = <int?>[];
    await pumpCds(tester, _chart(onChange: positions.add));

    final gesture = await tester.startGesture(at(tester, 17));
    await gesture.moveTo(at(tester, 40));
    await tester.pump();
    await gesture.moveTo(at(tester, 150));
    await tester.pump();
    await gesture.moveTo(at(tester, 155));
    await tester.pump();
    await gesture.moveTo(at(tester, 290));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(positions, [0, 2, 4, null]);
    expect(haptics.selections, 3);
  });

  testWidgets('long-press then drag scrubs', (tester) async {
    final positions = <int?>[];
    await pumpCds(tester, _chart(onChange: positions.add));
    final gesture = await tester.startGesture(at(tester, 83));
    await tester.pump(const Duration(milliseconds: 150));
    expect(positions, [1]);
    await gesture.moveTo(at(tester, 217));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(positions, [1, 3, null]);
  });

  testWidgets('arrow keys move the scrubber when the chart is focused', (tester) async {
    final positions = <int?>[];
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await pumpCds(tester, _chart(onChange: positions.add, focusNode: focusNode));
    focusNode.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(positions, [3, 2, 3, 0, 4, null]);
  });

  testWidgets('semantics summarize the series and expose the scrubbed value', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _chart());
    final finder = find.bySemanticsLabel(RegExp('Sample: lowest 10, highest 30, latest 25'));
    expect(finder, findsOneWidget);
    expect(tester.getSemantics(finder).value, '5 of 5: Sample 25');

    final gesture = await tester.startGesture(at(tester, 150));
    await gesture.moveTo(at(tester, 151 + kTouchSlop));
    await tester.pump();
    expect(tester.getSemantics(finder).value, '3 of 5: Sample 15');
    await gesture.up();
    await tester.pump();
    handle.dispose();
  });

  testWidgets('data changes animate, and change instantly under reduced motion', (tester) async {
    await pumpCds(tester, _chart());
    await pumpCds(tester, _chart(data: const [30, 10, 40, 5, 20, 8]), settle: false);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpAndSettle();

    await pumpCds(tester, _chart(), disableAnimations: true);
    await pumpCds(tester, _chart(data: const [30, 10, 40]), disableAnimations: true, settle: false);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('handles empty, single-point, flat and gappy data', (tester) async {
    for (final data in <List<double?>>[
      const [],
      const [42],
      const [5, 5, 5, 5],
      const [1, null, 3, double.nan, 5],
    ]) {
      final positions = <int?>[];
      await pumpCds(tester, _chart(data: data, onChange: positions.add, showAxes: true));
      expect(tester.takeException(), isNull, reason: '$data');
      await tester.dragFrom(at(tester, 100), const Offset(60, 0));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$data');
      if (data.isEmpty) expect(positions, isEmpty);
    }
    await pumpCds(tester, const CdsLineChart(height: 100, series: []));
    expect(tester.takeException(), isNull);
  });

  testWidgets('text scale 2 with axes does not throw', (tester) async {
    await pumpCds(
      tester,
      CdsLineChart(
        height: 200,
        showXAxis: true,
        showYAxis: true,
        xAxis: const CdsAxisConfig(data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
        xAxisStyle: const CdsXAxis(showGrid: true, showLine: true, showTickMarks: true, label: 'Day'),
        yAxisStyle: CdsYAxis(showGrid: true, label: 'Value', tickLabelFormatter: (v) => '\$${v.toInt()}'),
        series: const [CdsLineSeries(id: 'a', data: _five)],
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('legend lists labeled series and the reference line renders', (tester) async {
    await pumpCds(
      tester,
      const CdsLineChart(
        height: 200,
        legend: CdsLegend(),
        series: [
          CdsLineSeries(id: 'a', label: 'Alpha', data: _five),
          CdsLineSeries(
            id: 'b',
            label: 'Beta',
            data: [5, 6, 7, 8, 9],
            color: CdsColor.fgWarning,
            type: CdsChartLineType.dotted,
          ),
          CdsLineSeries(id: 'c', data: [1, 2, 3]),
        ],
        children: [
          CdsReferenceLine(dataY: 20, label: 'Target', labelElevated: true),
          CdsReferenceLine(dataX: 2, label: 'Event'),
          CdsPoint(dataX: 3, dataY: 30, label: 'High', labelPosition: CdsPointLabelPosition.top),
        ],
      ),
    );
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.byType(CdsLegendEntry), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('every curve renders', (tester) async {
    for (final curve in CdsChartCurve.values) {
      await pumpCds(
        tester,
        CdsLineChart(
          height: 120,
          curve: curve,
          series: const [CdsLineSeries(id: 'a', data: _five)],
        ),
      );
      expect(tester.takeException(), isNull, reason: '$curve');
    }
  });
}
