import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _tabs = [
  CdsTabValue(id: 'buy', label: 'Buy'),
  CdsTabValue(id: 'sell', label: 'Sell'),
  CdsTabValue(id: 'convert', label: 'Convert'),
];

Widget _host({String? initial = 'buy', bool equalWidth = false, bool disabled = false, ValueChanged<String>? onChange}) {
  var active = initial;
  return StatefulBuilder(
    builder: (context, setState) => CdsSegmentedTabs(
      accessibilityLabel: 'Order type',
      tabs: _tabs,
      activeTab: active,
      equalWidth: equalWidth,
      disabled: disabled,
      onChange: (id) {
        onChange?.call(id);
        setState(() => active = id);
      },
    ),
  );
}

Rect _pill(WidgetTester tester) {
  final positioned = find.descendant(of: find.byType(CdsSegmentedTabs), matching: find.byType(DecoratedBox));
  // The track is the outermost DecoratedBox; the pill is the one with a pill radius inside the Positioned.
  final candidates = tester.widgetList<DecoratedBox>(positioned).toList();
  for (var i = 0; i < candidates.length; i++) {
    final parent = find.ancestor(of: find.byWidget(candidates[i]), matching: find.byType(Positioned));
    if (parent.evaluate().isNotEmpty) return tester.getRect(find.byWidget(candidates[i]));
  }
  throw StateError('pill not found');
}

void main() {
  testWidgets('renders in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, _host(), brightness: b);
      expect(find.text('Sell'), findsOneWidget);
    }
  });

  testWidgets('pill springs to the tapped tab and onChange fires', (tester) async {
    final calls = <String>[];
    await pumpCds(tester, _host(onChange: calls.add));
    final buyRect = _pill(tester);
    await tester.tap(find.text('Convert'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    final mid = _pill(tester);
    expect(mid.left, greaterThan(buyRect.left));
    await tester.pumpAndSettle();
    expect(calls, ['convert']);
    expect(_pill(tester).center.dx, closeTo(tester.getCenter(find.text('Convert')).dx, 1));
  });

  testWidgets('tabs are at least 44px tall', (tester) async {
    await pumpCds(tester, _host());
    expect(tester.getSize(find.byType(CdsPressable).first).height, greaterThanOrEqualTo(44));
  });

  testWidgets('equalWidth splits the width evenly', (tester) async {
    await pumpCds(tester, SizedBox(width: 300, child: _host(equalWidth: true)));
    final widths = tester.widgetList(find.byType(CdsPressable)).map((w) => tester.getSize(find.byWidget(w)).width).toList();
    expect(widths.toSet().length, 1);
    expect(widths.first, closeTo(100, 0.5));
  });

  testWidgets('disabled list ignores taps', (tester) async {
    final calls = <String>[];
    await pumpCds(tester, _host(disabled: true, onChange: calls.add));
    await tester.tap(find.text('Sell'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);
  });

  testWidgets('arrow keys change the selection', (tester) async {
    final calls = <String>[];
    await pumpCds(tester, _host(onChange: calls.add));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(calls, ['sell']);
  });

  testWidgets('selected tab semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _host());
    final data = tester.getSemantics(find.text('Buy')).getSemanticsData();
    expect(data.role, SemanticsRole.tab);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    handle.dispose();
  });

  testWidgets('reduced motion settles in one frame', (tester) async {
    await pumpCds(tester, _host(), disableAnimations: true);
    await tester.tap(find.text('Sell'));
    await tester.pump();
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('text scale 2.0 and RTL do not overflow', (tester) async {
    await pumpCds(tester, SizedBox(width: 360, child: _host(equalWidth: true)), textScale: 2, textDirection: TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });
}
