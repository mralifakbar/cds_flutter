import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

final _close = CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () {});
final _help = CdsNavBarIconButton(CdsIconName.info, semanticLabel: 'Help', onPress: () {});

void main() {
  testWidgets('renders a title1 header in light and dark', (tester) async {
    final handle = tester.ensureSemantics();
    for (final b in Brightness.values) {
      await pumpCds(tester, const CdsPageHeader(title: 'Verify your identity'), brightness: b);
      expect(tester.widget<CdsText>(find.byType(CdsText)).font, CdsFont.title1);
      expect(tester.getSemantics(find.text('Verify your identity')).getSemanticsData().flagsCollection.isHeader, isTrue);
    }
    handle.dispose();
  });

  testWidgets('single row is 72px tall with start and title side by side', (tester) async {
    await pumpCds(tester, CdsPageHeader(start: _close, title: 'Review'));
    expect(tester.getSize(find.byType(CdsPageHeader)).height, 72);
    expect(tester.getCenter(find.text('Review')).dy, closeTo(tester.getCenter(find.bySemanticsLabel('Close')).dy, 1));
  });

  testWidgets('start, title and end move the title to a second row', (tester) async {
    await pumpCds(tester, CdsPageHeader(start: _close, title: 'Review', end: _help));
    expect(tester.getTopLeft(find.text('Review')).dy, greaterThan(tester.getBottomLeft(find.bySemanticsLabel('Close')).dy));
  });

  testWidgets('titleWidget overrides title', (tester) async {
    await pumpCds(tester, const CdsPageHeader(title: 'Ignored', titleWidget: Text('Custom')));
    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Ignored'), findsNothing);
  });

  testWidgets('text scale 2.0 and RTL do not overflow', (tester) async {
    await pumpCds(
      tester,
      CdsPageHeader(start: _close, title: 'Verify your identity to continue', end: _help),
      textScale: 2,
      textDirection: TextDirection.rtl,

    );
    expect(tester.takeException(), isNull);
  });
}
