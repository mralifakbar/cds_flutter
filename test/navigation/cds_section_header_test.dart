import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('renders title, balance, description and icon in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(
        tester,
        const CdsSectionHeader(title: 'Your assets', balance: r'$1,204.18', description: 'Sample data', icon: CdsIconName.info),
        brightness: b,
      );
      expect(find.text('Your assets'), findsOneWidget);
      expect(find.text(r'$1,204.18'), findsOneWidget);
      expect(tester.widget<CdsIcon>(find.byType(CdsIcon)).size, CdsIconSize.xs);
    }
  });

  testWidgets('title is a header', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const CdsSectionHeader(title: 'Watchlist'));
    expect(tester.getSemantics(find.text('Watchlist')).getSemanticsData().flagsCollection.isHeader, isTrue);
    handle.dispose();
  });

  testWidgets('end action is pressable and sits at the end edge', (tester) async {
    var taps = 0;
    await pumpCds(
      tester,
      CdsSectionHeader(title: 'Watchlist', end: CdsButton(label: 'See all', size: CdsButtonSize.s, onPress: () => taps++)),
      center: false,
    );
    expect(tester.getCenter(find.text('See all')).dx, greaterThan(tester.getCenter(find.text('Watchlist')).dx));
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('description clamps to two lines', (tester) async {
    await pumpCds(tester, const CdsSectionHeader(title: 'News', description: 'Long description'));
    expect(tester.widget<CdsText>(find.widgetWithText(CdsText, 'Long description')).maxLines, 2);
  });

  testWidgets('text scale 2.0 wraps the end slot instead of overflowing', (tester) async {
    await pumpCds(
      tester,
      CdsSectionHeader(
        title: 'Recently viewed assets',
        description: 'Assets you opened in the last 24 hours. Sample data.',
        end: CdsButton(label: 'Clear history', size: CdsButtonSize.s, onPress: () {}),
      ),
      textScale: 2,
      textDirection: TextDirection.rtl,
      center: false,
    );
    expect(tester.takeException(), isNull);
  });
}
