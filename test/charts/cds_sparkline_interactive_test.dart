import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import 'chart_test_utils.dart';

final _start = DateTime(2024, 1, 1);

List<CdsChartDataPoint> _points(List<double> values) => [
  for (var i = 0; i < values.length; i++)
    CdsChartDataPoint(
      value: values[i],
      date: _start.add(Duration(days: i)),
    ),
];

final _data = <String, List<CdsChartDataPoint>>{
  '1D': _points(const [10, 20, 15, 30, 25]),
  '1W': _points(const [5, 8, 6, 9, 12, 11, 14]),
  '1M': const [],
};

const _periods = [
  CdsSparklinePeriod(label: '1D', value: '1D'),
  CdsSparklinePeriod(label: '1W', value: '1W'),
  CdsSparklinePeriod(label: '1M', value: '1M'),
];

Widget _chart({
  ValueChanged<CdsChartScrubParams<String>>? onScrub,
  VoidCallback? onScrubStart,
  VoidCallback? onScrubEnd,
  ValueChanged<String>? onPeriodChanged,
  String defaultPeriod = '1D',
  bool compact = false,
  bool hideMinMaxLabel = false,
  CdsSparklineFillType fillType = CdsSparklineFillType.gradient,
  Widget? fallback,
  FocusNode? focusNode,
  Widget? headerNode,
}) {
  return SizedBox(
    width: 390,
    child: CdsSparklineInteractive<String>(
      data: _data,
      periods: _periods,
      defaultPeriod: defaultPeriod,
      formatDate: (d, _) => '${d.month}/${d.day}',
      formatHoverDate: (d, _) => 'Jan ${d.day}',
      formatHoverPrice: (v) => '\$${v.toStringAsFixed(2)}',
      onScrub: onScrub,
      onScrubStart: onScrubStart,
      onScrubEnd: onScrubEnd,
      onPeriodChanged: onPeriodChanged,
      compact: compact,
      hideMinMaxLabel: hideMinMaxLabel,
      fillType: fillType,
      fallback: fallback,
      focusNode: focusNode,
      headerNode: headerNode,
      strokeColor: CdsColor.fgPositive,
    ),
  );
}

void main() {
  // A 390px-wide chart minus the 24px gutter on each side leaves a 342px chart;
  // five evenly spaced points land at x = 2, 86.5, 171, 255.5, 340.
  Offset at(WidgetTester tester, double x) =>
      tester.getTopLeft(find.byType(CdsSparklineInteractive<String>)) + Offset(24 + x, 184);

  testWidgets('renders variants in light and dark', (tester) async {
    for (final brightness in Brightness.values) {
      await pumpCds(tester, _chart(), brightness: brightness);
      await pumpCds(
        tester,
        _chart(compact: true, hideMinMaxLabel: true, fillType: CdsSparklineFillType.dotted),
        brightness: brightness,
      );
      expect(tester.takeException(), isNull);
    }
    expect(find.text('30'), findsNothing, reason: 'min/max hidden');
    await pumpCds(tester, _chart());
    expect(find.text('30'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('scrubbing snaps to the nearest point, fires haptics on change and ends cleanly', (tester) async {
    final haptics = HapticLog(tester);
    final indices = <int>[];
    var starts = 0, ends = 0;
    await pumpCds(
      tester,
      _chart(onScrub: (p) => indices.add(p.index), onScrubStart: () => starts++, onScrubEnd: () => ends++),
    );

    final gesture = await tester.startGesture(at(tester, 5));
    await gesture.moveTo(at(tester, 5 + kTouchSlop + 1));
    await tester.pump();
    await gesture.moveTo(at(tester, 170));
    await tester.pump();
    await gesture.moveTo(at(tester, 175));
    await tester.pump();
    expect(find.text('Jan 3'), findsOneWidget);
    await gesture.moveTo(at(tester, 341));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(indices, [0, 2, 4]);
    expect(haptics.selections, 3);
    expect(starts, 1);
    expect(ends, 1);
  });

  testWidgets('switching periods reports the change and morphs the line', (tester) async {
    final periods = <String>[];
    await pumpCds(tester, _chart(onPeriodChanged: periods.add));
    await tester.tap(find.text('1W'));
    await tester.pump();
    expect(periods, ['1W']);
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpAndSettle();
    expect(find.text('14'), findsOneWidget);
  });

  testWidgets('period switches are instant under reduced motion', (tester) async {
    await pumpCds(tester, _chart(), disableAnimations: true);
    await tester.tap(find.text('1W'));
    await tester.pump();
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('an empty period shows the fallback without exceptions', (tester) async {
    await pumpCds(tester, _chart(defaultPeriod: '1M'));
    expect(tester.takeException(), isNull);
    await pumpCds(tester, _chart(defaultPeriod: '1M', fallback: const CdsText('Loading sample data')));
    expect(find.text('Loading sample data'), findsOneWidget);
    await tester.dragFrom(at(tester, 50), const Offset(100, 0));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('arrow keys scrub when focused', (tester) async {
    final indices = <int>[];
    var ends = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await pumpCds(tester, _chart(onScrub: (p) => indices.add(p.index), onScrubEnd: () => ends++, focusNode: focusNode));
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(indices, [4, 3, 4]);
    expect(ends, 1);
  });

  testWidgets('semantics summarize the period and expose the current value', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _chart());
    final finder = find.bySemanticsLabel(
      RegExp(r'Price chart, 1 day\. Lowest \$10\.00, highest \$30\.00, latest \$25\.00'),
    );
    expect(finder, findsOneWidget);
    expect(tester.getSemantics(finder).value, r'1/5, $25.00');
    expect(find.bySemanticsLabel('1 week'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('header shows defaults and follows controller updates', (tester) async {
    final handle = tester.ensureSemantics();
    final controller = CdsSparklineInteractiveHeaderController();
    addTearDown(controller.dispose);
    const subHead = CdsSparklineInteractiveSubHead(
      percent: '4.55%',
      priceChange: r'$52.40',
      sign: CdsSparklineInteractiveHeaderSignVariant.positive,
      variant: CdsSparklineInteractiveHeaderVariant.positive,
      accessoryText: 'Today',
    );
    await pumpCds(
      tester,
      _chart(
        headerNode: CdsSparklineInteractiveHeader(
          controller: controller,
          defaultLabel: 'Sample asset',
          defaultTitle: r'$1,204.18',
          defaultSubHead: subHead,
        ),
        onScrub: (p) => controller.update(title: '\$${p.point.value.toStringAsFixed(2)}'),
        onScrubEnd: controller.reset,
      ),
    );
    expect(find.text(r'$1,204.18'), findsOneWidget);
    expect(find.text(r'$52.40 (4.55%)'), findsOneWidget);
    expect(find.bySemanticsLabel(r'Sample asset, $1,204.18, up $52.40, 4.55%'), findsOneWidget);

    controller.update(title: r'$15.00');
    await tester.pump();
    expect(find.text(r'$15.00'), findsOneWidget);
    controller.reset();
    await tester.pump();
    expect(find.text(r'$1,204.18'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('header shrinks long titles and handles text scale 2', (tester) async {
    await pumpCds(
      tester,
      const CdsSparklineInteractiveHeader(
        defaultTitle: r'$123,456,789.12',
        trailing: CdsText('Sample'),
        defaultSubHead: CdsSparklineInteractiveSubHead(
          percent: '0.00%',
          sign: CdsSparklineInteractiveHeaderSignVariant.none,
          variant: CdsSparklineInteractiveHeaderVariant.foregroundMuted,
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.text(r'$123,456,789.12'));
    expect(text.style!.fontSize, closeTo(28 * 12 / 15, 0.01));
  });
}
