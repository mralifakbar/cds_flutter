import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('renders title, subtitle and end in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(
        tester,
        CdsNavigationBar(
          title: 'Bitcoin',
          subtitle: 'BTC',
          onBack: () {},
          end: CdsNavBarIconButton(CdsIconName.star, semanticLabel: 'Add to watchlist', onPress: () {}),
        ),
        brightness: b,
        center: false,
      );
      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('BTC'), findsOneWidget);
    }
  });

  testWidgets('back button calls onBack and sits before the title', (tester) async {
    var backs = 0;
    await pumpCds(tester, CdsNavigationBar(title: 'Send', onBack: () => backs++), center: false);
    final back = tester.getRect(find.bySemanticsLabel('Back'));
    expect(back.right, lessThanOrEqualTo(tester.getTopLeft(find.text('Send')).dx));
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(backs, 1);
  });

  testWidgets('back button activates with Enter', (tester) async {
    var backs = 0;
    await pumpCds(tester, CdsNavigationBar(title: 'Send', onBack: () => backs++), center: false);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(backs, 1);
  });

  testWidgets('no onBack means no back button', (tester) async {
    await pumpCds(tester, const CdsNavigationBar(title: 'Settings'), center: false);
    expect(find.byType(CdsNavBarIconButton), findsNothing);
  });

  testWidgets('RTL mirrors the back arrow and puts it on the right', (tester) async {
    await pumpCds(tester, CdsNavigationBar(title: 'Send', onBack: () {}), textDirection: TextDirection.rtl, center: false);
    final button = tester.widget<CdsNavBarIconButton>(find.byType(CdsNavBarIconButton));
    expect(button.name, CdsIconName.arrowRight);
    expect(tester.getCenter(find.bySemanticsLabel('Back')).dx, greaterThan(tester.getCenter(find.text('Send')).dx));
  });

  testWidgets('draws a bottom border by default', (tester) async {
    await pumpCds(tester, const CdsNavigationBar(title: 'Settings'), center: false);
    final box = tester.widget<DecoratedBox>(
      find.descendant(of: find.byType(CdsNavigationBar), matching: find.byType(DecoratedBox)).first,
    );
    expect((box.decoration as BoxDecoration).border, isNotNull);
  });

  testWidgets('text scale 2.0 with a long title does not overflow', (tester) async {
    await pumpCds(
      tester,
      CdsNavigationBar(title: 'Transaction details for your most recent transfer', subtitle: 'Sample data', onBack: () {}),
      textScale: 2,
      center: false,
    );
    expect(tester.takeException(), isNull);
  });
}
