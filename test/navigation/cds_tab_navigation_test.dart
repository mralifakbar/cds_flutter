import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

final _tabs = [
  const CdsTabValue(id: 'foryou', label: 'For you'),
  const CdsTabValue(id: 'portfolio', label: 'Portfolio', count: 2),
  const CdsTabValue(id: 'explore', label: 'Explore'),
  const CdsTabValue(id: 'earn', label: 'Earn'),
  const CdsTabValue(id: 'learn', label: 'Learn'),
];

Widget _host({
  String? initial,
  CdsTabLabelVariant variant = CdsTabLabelVariant.primary,
  CdsTabNavigationRole role = CdsTabNavigationRole.tablist,
  ValueChanged<String>? onChange,
}) {
  var active = initial;
  return StatefulBuilder(
    builder: (context, setState) => SizedBox(
      width: 320,
      child: CdsTabNavigation(
        accessibilityLabel: 'Home sections',
        tabs: _tabs,
        value: active,
        variant: variant,
        role: role,
        onChange: (id) {
          onChange?.call(id);
          setState(() => active = id);
        },
      ),
    ),
  );
}

void main() {
  testWidgets('renders primary with an indicator in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, _host(), brightness: b);
      expect(find.byType(CdsTabIndicator), findsOneWidget);
      expect(find.byType(CdsTabLabel), findsNWidgets(5));
    }
  });

  testWidgets('secondary variant has no indicator', (tester) async {
    await pumpCds(tester, _host(variant: CdsTabLabelVariant.secondary));
    expect(find.byType(CdsTabIndicator), findsNothing);
  });

  testWidgets('first tab is active by default and taps call onChange', (tester) async {
    final calls = <String>[];
    await pumpCds(tester, _host(onChange: calls.add));
    expect(tester.widget<CdsTabLabel>(find.byType(CdsTabLabel).first).active, isTrue);
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(calls, ['explore']);
  });

  testWidgets('shows the count badge', (tester) async {
    await pumpCds(tester, _host());
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('keyboard End scrolls the last tab into view', (tester) async {
    await pumpCds(tester, _host());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.widget<CdsTabLabel>(find.byType(CdsTabLabel).last).active, isTrue);
  });

  testWidgets('radiogroup role exposes checked state', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _host(role: CdsTabNavigationRole.radiogroup));
    final data = tester.getSemantics(find.text('For you')).getSemanticsData();
    expect(data.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    handle.dispose();
  });

  testWidgets('tablist role exposes tab role', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _host());
    expect(tester.getSemantics(find.text('Explore')).getSemanticsData().role, SemanticsRole.tab);
    handle.dispose();
  });

  testWidgets('text scale 2.0 and RTL do not overflow', (tester) async {
    await pumpCds(tester, _host(), textScale: 2, textDirection: TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });
}
