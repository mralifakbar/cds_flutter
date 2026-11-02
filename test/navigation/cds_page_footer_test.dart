import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('renders the action in light and dark, 80px tall', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(
        tester,
        CdsPageFooter(action: CdsButton(label: 'Continue', block: true, onPress: () {})),
        brightness: b,

      );
      expect(find.text('Continue'), findsOneWidget);
      expect(tester.getSize(find.byType(CdsPageFooter)).height, 80);
    }
  });

  testWidgets('action stays pressable', (tester) async {
    var taps = 0;
    await pumpCds(tester, CdsPageFooter(action: CdsButton(label: 'Continue', onPress: () => taps++)));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('legal text renders under the action', (tester) async {
    await pumpCds(
      tester,
      CdsPageFooter(action: CdsButton(label: 'Continue', onPress: () {}), legalText: 'Prices update every 30 seconds.'),

    );
    final legal = tester.widget<CdsText>(find.widgetWithText(CdsText, 'Prices update every 30 seconds.'));
    expect(legal.font, CdsFont.legal);
    expect(tester.getTopLeft(find.text('Prices update every 30 seconds.')).dy, greaterThan(tester.getBottomLeft(find.text('Continue')).dy));
  });

  testWidgets('labelled region for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, CdsPageFooter(accessibilityLabel: 'Order actions', action: CdsButton(label: 'Buy', onPress: () {})));
    expect(find.bySemanticsLabel('Order actions'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('text scale 2.0 does not overflow', (tester) async {
    await pumpCds(
      tester,
      CdsPageFooter(action: CdsButton(label: 'Continue', block: true, onPress: () {}), legalText: 'Sample data. Not financial advice.'),
      textScale: 2,

    );
    expect(tester.takeException(), isNull);
  });
}
