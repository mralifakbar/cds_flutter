import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('title is a headline header; subtitle is a muted header', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(
      tester,
      const Column(mainAxisSize: MainAxisSize.min, children: [CdsNavigationTitle('Wallet'), CdsNavigationSubtitle('Sample data')]),
    );
    expect(tester.widget<CdsText>(find.byType(CdsText).first).font, CdsFont.headline);
    final sub = tester.widget<CdsText>(find.byType(CdsText).last);
    expect(sub.font, CdsFont.label2);
    expect(sub.color, CdsColor.fgMuted);
    expect(tester.getSemantics(find.text('Wallet')).getSemanticsData().flagsCollection.isHeader, isTrue);
    expect(tester.getSemantics(find.text('Sample data')).getSemanticsData().flagsCollection.isHeader, isTrue);
    handle.dispose();
  });

  testWidgets('renders in dark mode and at text scale 2.0 inside a narrow box', (tester) async {
    await pumpCds(
      tester,
      const SizedBox(width: 120, child: CdsNavigationTitle('A long title that ellipsizes')),
      brightness: Brightness.dark,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
