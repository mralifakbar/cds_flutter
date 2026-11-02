import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _withSafeArea(double bottom, Widget child) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(padding: EdgeInsets.only(bottom: bottom)),
        child: child,
      ),
    );

EdgeInsetsDirectional _padding(WidgetTester tester) => tester
    .widget<Padding>(find.descendant(of: find.byType(CdsStickyFooter), matching: find.byType(Padding)).first)
    .padding as EdgeInsetsDirectional;

void main() {
  testWidgets('renders in light and dark and fires the child action', (tester) async {
    var taps = 0;
    for (final b in Brightness.values) {
      await pumpCds(tester, CdsStickyFooter(child: CdsButton(label: 'Continue', block: true, onPress: () => taps++)), brightness: b);
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.text('Continue'));
    expect(taps, 1);
  });

  testWidgets('uses CDS padding: 24 top, 16 compact, 24 sides', (tester) async {
    await pumpCds(tester, const CdsStickyFooter(child: SizedBox(height: 10)));
    expect(_padding(tester), const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16));
    await pumpCds(tester, const CdsStickyFooter(compact: true, child: SizedBox(height: 10)));
    expect(_padding(tester).top, 16);
  });

  testWidgets('bottom inset is the larger of padding and safe area', (tester) async {
    await pumpCds(tester, _withSafeArea(34, const CdsStickyFooter(child: SizedBox(height: 10))));
    expect(_padding(tester).bottom, 34);
    await pumpCds(tester, _withSafeArea(34, const CdsStickyFooter(respectSafeArea: false, child: SizedBox(height: 10))));
    expect(_padding(tester).bottom, 16);
  });

  testWidgets('elevated adds the level 1 shadow', (tester) async {
    await pumpCds(tester, const CdsStickyFooter(elevated: true, child: SizedBox(height: 10)));
    final box = tester.widget<DecoratedBox>(find.descendant(of: find.byType(CdsStickyFooter), matching: find.byType(DecoratedBox)).first);
    expect((box.decoration as BoxDecoration).boxShadow, CdsThemeData.light.shadow(CdsElevation.level1));
  });

  testWidgets('labels the footer for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const CdsStickyFooter(child: CdsText('Fee: sample data')));
    expect(find.bySemanticsLabel('footer'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('RTL and text scale 2 do not overflow', (tester) async {
    await pumpCds(
      tester,
      CdsStickyFooter(child: CdsButton(label: 'Buy Bitcoin', block: true, onPress: () {})),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
