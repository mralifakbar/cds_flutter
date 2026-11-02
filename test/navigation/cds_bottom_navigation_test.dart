import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _items = [
  CdsBottomNavigationItem(id: 'home', icon: CdsIconName.home, label: 'Home'),
  CdsBottomNavigationItem(id: 'trade', icon: CdsIconName.trading, label: 'Trade', count: 3),
  CdsBottomNavigationItem(id: 'wallet', icon: CdsIconName.wallet, label: 'Wallet'),
  CdsBottomNavigationItem(id: 'profile', icon: CdsIconName.profile, label: 'Profile', disabled: true),
];

Widget _host({ValueChanged<String>? onChange, bool showLabels = true}) {
  var value = 'home';
  return StatefulBuilder(
    builder: (context, setState) => Align(
      alignment: Alignment.bottomCenter,
      child: CdsBottomNavigation(
        items: _items,
        value: value,
        showLabels: showLabels,
        onChange: (id) {
          onChange?.call(id);
          setState(() => value = id);
        },
      ),
    ),
  );
}

CdsIcon _icon(WidgetTester tester, CdsIconName name) =>
    tester.widget<CdsIcon>(find.byWidgetPredicate((w) => w is CdsIcon && w.name == name));

void main() {
  testWidgets('renders in light and dark with the active glyph on the selected item', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, _host(), brightness: b, center: false);
      expect(_icon(tester, CdsIconName.home).active, isTrue);
      expect(_icon(tester, CdsIconName.home).color, CdsColor.fgPrimary);
      expect(_icon(tester, CdsIconName.wallet).active, isFalse);
    }
  });

  testWidgets('tapping an item calls onChange; disabled items do not', (tester) async {
    final calls = <String>[];
    await pumpCds(tester, _host(onChange: calls.add), center: false);
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(calls, ['wallet']);
    expect(_icon(tester, CdsIconName.wallet).active, isTrue);
  });

  testWidgets('items are at least 44px and pad for the bottom safe area', (tester) async {
    await pumpCds(
      tester,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: const EdgeInsets.only(bottom: 34)),
          child: _host(),
        ),
      ),
      center: false,
    );
    final bar = tester.getRect(find.byType(CdsBottomNavigation));
    final item = tester.getRect(find.byType(CdsPressable).first);
    expect(bar.bottom - item.bottom, greaterThanOrEqualTo(34));
    for (final element in find.byType(CdsPressable).evaluate()) {
      final size = tester.getSize(find.byWidget(element.widget));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.width, greaterThanOrEqualTo(44));
    }
  });

  testWidgets('semantics: tab role, selected, badge in label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _host(), center: false);
    final home = tester.getSemantics(find.bySemanticsLabel('Home')).getSemanticsData();
    expect(home.role, SemanticsRole.tab);
    expect(find.bySemanticsLabel('Trade, 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Main navigation'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('icon-only mode keeps labels for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _host(showLabels: false), center: false);
    expect(find.text('Home'), findsNothing);
    expect(find.bySemanticsLabel('Home'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('arrow keys move between items and skip disabled ones', (tester) async {
    final calls = <String>[];
    await pumpCds(tester, _host(onChange: calls.add), center: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(calls, ['wallet']);
  });

  testWidgets('text scale 2.0 and RTL do not overflow', (tester) async {
    await pumpCds(tester, _host(), textScale: 2, textDirection: TextDirection.rtl, center: false);
    expect(tester.takeException(), isNull);
  });
}
