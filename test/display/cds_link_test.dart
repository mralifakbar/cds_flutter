import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  group('CdsLink', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders standalone and inline in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Column(mainAxisSize: MainAxisSize.min, children: [
            CdsLink('View all', onPress: () {}),
            CdsLink('Fees', font: CdsFont.caption, mono: true, onPress: () {}),
            CdsText.rich(TextSpan(children: [
              const TextSpan(text: 'Read the '),
              WidgetSpan(child: CdsLink('user agreement', inline: true, onPress: () {})),
            ])),
          ]),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('fires onPress and opens to through CdsLinkScope', (tester) async {
      final opened = <String>[];
      var taps = 0;
      await pumpCds(tester, CdsLinkScope(onOpen: opened.add, child: CdsLink('Fees', to: 'https://example.com/fees', onPress: () => taps++)));
      await tester.tap(find.text('Fees'));
      expect(taps, 1);
      expect(opened, ['https://example.com/fees']);
    });

    testWidgets('is a link for screen readers, not a button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, CdsLink('View all', onPress: () {}));
      expect(tester.getSemantics(find.text('View all')), containsSemantics(label: 'View all', isLink: true, isButton: false, hasTapAction: true));
      handle.dispose();
    });

    testWidgets('dims on pointer-down', (tester) async {
      await pumpCds(tester, CdsLink('View all', onPress: () {}));
      final gesture = await tester.startGesture(tester.getCenter(find.text('View all')));
      await tester.pump(const Duration(milliseconds: 150));
      final opacity = tester.widget<AnimatedOpacity>(find.ancestor(of: find.text('View all'), matching: find.byType(AnimatedOpacity)));
      expect(opacity.opacity, lessThan(1));
      await gesture.up();
    });

    testWidgets('inline links are underlined and standalone links are not', (tester) async {
      await pumpCds(tester, Column(mainAxisSize: MainAxisSize.min, children: [
        CdsLink('inline', inline: true, onPress: () {}),
        CdsLink('standalone', onPress: () {}),
      ]));
      expect(tester.widget<Text>(find.text('inline')).style!.decoration, TextDecoration.underline);
      expect(tester.widget<Text>(find.text('standalone')).style!.decoration, isNot(TextDecoration.underline));
    });

    testWidgets('standalone links have a 44px hit area', (tester) async {
      await pumpCds(tester, CdsLink('Go', font: CdsFont.label2, onPress: () {}));
      expect(tester.getSize(find.byType(CdsLink)).height, greaterThanOrEqualTo(44));
    });

    testWidgets('activates from the keyboard', (tester) async {
      var taps = 0;
      await pumpCds(tester, CdsLink('Go', onPress: () => taps++));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(tester, SizedBox(width: 200, child: CdsLink('A fairly long standalone link label', onPress: () {})), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
