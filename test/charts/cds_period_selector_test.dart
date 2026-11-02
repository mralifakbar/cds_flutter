import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _tabs = [
  CdsPeriodSelectorTab(id: '1H', label: '1H', labelWidget: CdsLiveTabLabel()),
  CdsPeriodSelectorTab(id: '1D', label: '1D'),
  CdsPeriodSelectorTab(id: '1W', label: '1W'),
  CdsPeriodSelectorTab(id: 'All', label: 'All'),
];

class _Host extends StatefulWidget {
  const _Host({this.onChange, this.block = true});

  final ValueChanged<String>? onChange;
  final bool block;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String active = '1D';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: CdsPeriodSelector(
        tabs: _tabs,
        activeTab: active,
        block: widget.block,
        gap: 0.5,
        onChange: (id) {
          widget.onChange?.call(id);
          setState(() => active = id);
        },
      ),
    );
  }
}

void main() {
  testWidgets('renders in light and dark, block and hugging', (tester) async {
    for (final brightness in Brightness.values) {
      await pumpCds(tester, const _Host(), brightness: brightness);
      await pumpCds(tester, const _Host(block: false), brightness: brightness);
      expect(tester.takeException(), isNull);
    }
    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('tapping a tab calls onChange and slides the pill', (tester) async {
    final changes = <String>[];
    await pumpCds(tester, _Host(onChange: changes.add));
    await tester.tap(find.text('1W'));
    await tester.pump();
    await tester.pump();
    expect(changes, ['1W']);
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pumpAndSettle();
    await tester.tap(find.text('1W'));
    await tester.pump();
    expect(changes, ['1W'], reason: 'the active tab does not fire again');
  });

  testWidgets('arrow keys move the selection', (tester) async {
    final changes = <String>[];
    await pumpCds(tester, _Host(onChange: changes.add));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(changes, ['1W', 'All', '1W']);
  });

  testWidgets('tabs expose selected state and spoken period names', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const _Host());
    expect(
      tester.getSemantics(find.bySemanticsLabel('1 day')),
      containsSemantics(label: '1 day', isButton: true, isSelected: true, hasSelectedState: true, hasTapAction: true),
    );
    expect(find.bySemanticsLabel('1 week'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('selection changes instantly under reduced motion', (tester) async {
    await pumpCds(tester, const _Host(), disableAnimations: true);
    await tester.tap(find.text('All'));
    await tester.pump();
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('text scale 2 does not throw', (tester) async {
    await pumpCds(tester, const _Host(), textScale: 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legend works outside a chart and in a vertical direction', (tester) async {
    await pumpCds(
      tester,
      const CdsLegend(
        direction: Axis.vertical,
        series: [
          CdsChartSeries(id: 'a', label: 'Alpha', legendShape: CdsLegendShape.pill),
          CdsChartSeries(id: 'b', label: 'Beta', legendShape: CdsLegendShape.squircle),
          CdsChartSeries(id: 'c'),
        ],
      ),
    );
    expect(find.byType(CdsLegendEntry), findsNWidgets(2));
  });
}
