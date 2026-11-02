import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _page({EdgeInsets padding = EdgeInsets.zero, double keyboard = 0, bool header = true, bool scrollable = true}) =>
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(padding: padding, viewPadding: padding, viewInsets: EdgeInsets.only(bottom: keyboard)),
        child: CdsScaffold(
          header: header ? const SizedBox(height: 56, child: Center(child: CdsText('Header'))) : null,
          scrollable: scrollable,
          body: scrollable
              ? Column(children: [for (var i = 0; i < 40; i++) SizedBox(height: 48, child: CdsText('Row $i'))])
              : ListView(children: [for (var i = 0; i < 40; i++) SizedBox(height: 48, child: CdsText('Row $i'))]),
          footer: CdsStickyFooter(child: CdsButton(label: 'Continue', block: true, onPress: () {})),
        ),
      ),
    );

double _dividerOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.ancestor(of: find.byType(CdsDivider), matching: find.byType(AnimatedOpacity)))
    .opacity;

void main() {
  testWidgets('renders in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, _page(), brightness: b, center: false);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('header clears the top safe area, footer pins to the bottom', (tester) async {
    await pumpCds(tester, _page(padding: const EdgeInsets.only(top: 47, bottom: 34)), center: false);
    expect(tester.getTopLeft(find.text('Header')).dy, greaterThanOrEqualTo(47));
    final footer = tester.getRect(find.byType(CdsStickyFooter));
    expect(footer.bottom, tester.getRect(find.byType(CdsScaffold)).bottom);
    final padding = tester
        .widget<Padding>(find.descendant(of: find.byType(CdsStickyFooter), matching: find.byType(Padding)).first)
        .padding as EdgeInsetsDirectional;
    expect(padding.bottom, 34);
  });

  testWidgets('keyboard lifts the footer without counting the safe area twice', (tester) async {
    await pumpCds(tester, _page(padding: const EdgeInsets.only(bottom: 34), keyboard: 300), center: false);
    final footer = tester.getRect(find.byType(CdsStickyFooter));
    expect(footer.bottom, tester.getRect(find.byType(CdsScaffold)).bottom - 300);
    final padding = tester
        .widget<Padding>(find.descendant(of: find.byType(CdsStickyFooter), matching: find.byType(Padding)).first)
        .padding as EdgeInsetsDirectional;
    expect(padding.bottom, 16);
  });

  testWidgets('body scrolls and the header divider fades in', (tester) async {
    await pumpCds(tester, _page(), center: false);
    expect(_dividerOpacity(tester), 0);
    final before = tester.getTopLeft(find.text('Row 0')).dy;
    await tester.drag(find.text('Row 3'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Row 0')).dy, lessThan(before - 200));
    expect(_dividerOpacity(tester), 1);
  });

  testWidgets('non-scrollable mode hosts its own ListView', (tester) async {
    await pumpCds(tester, _page(scrollable: false), center: false);
    await tester.fling(find.text('Row 3'), const Offset(0, -500), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Row 0'), findsNothing);
    expect(_dividerOpacity(tester), 1);
  });

  testWidgets('reduced motion, RTL and text scale 2 render without errors', (tester) async {
    await pumpCds(tester, _page(header: false), center: false, disableAnimations: true, textDirection: TextDirection.rtl, textScale: 2);
    await tester.drag(find.text('Row 3'), const Offset(0, -200));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
  });
}
