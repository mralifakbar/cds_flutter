import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

final _tabs = [
  for (final label in ['All', 'Top gainers', 'Top losers', 'New listings', 'Trending', 'Watchlist'])
    CdsTabValue(id: label.toLowerCase(), label: label),
];

Widget _host({String? initial, ValueChanged<String>? onChange}) {
  var active = initial;
  return StatefulBuilder(
    builder: (context, setState) => SizedBox(
      width: 300,
      child: CdsTabbedChips(
        accessibilityLabel: 'Filters',
        tabs: _tabs,
        value: active,
        onChange: (id) {
          onChange?.call(id);
          setState(() => active = id);
        },
      ),
    ),
  );
}

Color _chipColor(WidgetTester tester, String label) {
  final pressable = find.ancestor(of: find.text(label), matching: find.byType(CdsPressable));
  final container = tester.widget<AnimatedContainer>(find.descendant(of: pressable, matching: find.byType(AnimatedContainer)));
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  testWidgets('defaults to the first chip and inverts the active chip', (tester) async {
    await pumpCds(tester, _host());
    const light = CdsThemeData.light;
    expect(_chipColor(tester, 'All'), CdsThemeData.dark.color.bgSecondary);
    expect(_chipColor(tester, 'Trending'), light.color.bgSecondary);
  });

  testWidgets('renders in dark mode', (tester) async {
    await pumpCds(tester, _host(), brightness: Brightness.dark);
    expect(_chipColor(tester, 'All'), CdsThemeData.light.color.bgSecondary);
  });

  testWidgets('tapping a chip calls onChange', (tester) async {
    final calls = <String>[];
    await pumpCds(tester, _host(onChange: calls.add));
    await tester.tap(find.text('Top gainers'));
    await tester.pumpAndSettle();
    expect(calls, ['top gainers']);
  });

  testWidgets('selecting an offscreen chip scrolls it into view', (tester) async {
    await pumpCds(tester, _host());
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
  });

  testWidgets('keyboard focus stays on the chip after selection changes', (tester) async {
    await pumpCds(tester, _host());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_chipColor(tester, 'Top losers'), CdsThemeData.dark.color.bgSecondary);
  });

  testWidgets('chip targets are at least 44px tall', (tester) async {
    await pumpCds(tester, _host());
    expect(tester.getSize(find.byType(CdsPressable).first).height, greaterThanOrEqualTo(44));
  });

  testWidgets('selected semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _host());
    expect(tester.getSemantics(find.text('All')).getSemanticsData().role, SemanticsRole.tab);
    handle.dispose();
  });

  testWidgets('text scale 2.0 does not overflow', (tester) async {
    await pumpCds(tester, _host(), textScale: 2);
    expect(tester.takeException(), isNull);
  });
}
