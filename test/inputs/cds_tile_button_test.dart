import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _media = CdsIcon(CdsIconName.paperAirplane, size: CdsIconSize.l);

void main() {
  group('CdsTileButton', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Row(mainAxisSize: MainAxisSize.min, children: [
            CdsTileButton(title: 'Send', onPress: () {}, child: _media),
            CdsTileButton(title: 'Inbox', count: 3, onPress: () {}, child: _media),
            const CdsTileButton(title: 'Off', disabled: true, child: _media),
          ]),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('is tileSize square', (tester) async {
      await pumpCds(tester, CdsTileButton(title: 'Send', onPress: () {}, child: _media));
      expect(tester.getSize(find.byType(CdsTileButton)), const Size(106, 106));
    });

    testWidgets('onPress fires; disabled does not', (tester) async {
      var taps = 0;
      await pumpCds(tester, Row(mainAxisSize: MainAxisSize.min, children: [
        CdsTileButton(title: 'Send', onPress: () => taps++, child: _media),
        CdsTileButton(title: 'Off', disabled: true, onPress: () => taps++, child: _media),
      ]));
      await tester.tap(find.text('Send'));
      await tester.tap(find.text('Off'));
      expect(taps, 1);
    });

    testWidgets('count badge shows and caps at maxCount', (tester) async {
      await pumpCds(tester, Row(mainAxisSize: MainAxisSize.min, children: [
        CdsTileButton(title: 'A', count: 5, onPress: () {}, child: _media),
        CdsTileButton(title: 'B', count: 120, onPress: () {}, child: _media),
        CdsTileButton(title: 'C', count: 0, onPress: () {}, child: _media),
      ]));
      expect(find.text('5'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('title truncates unless showOverflow', (tester) async {
      await pumpCds(tester, Row(mainAxisSize: MainAxisSize.min, children: [
        CdsTileButton(title: 'Recurring purchases', onPress: () {}, child: _media),
        CdsTileButton(title: 'Recurring purchases too', showOverflow: true, onPress: () {}, child: _media),
      ]));
      expect(tester.widget<CdsText>(find.byWidgetPredicate((w) => w is CdsText && w.data == 'Recurring purchases')).maxLines, 1);
      expect(tester.widget<CdsText>(find.byWidgetPredicate((w) => w is CdsText && w.data == 'Recurring purchases too')).maxLines, isNull);
    });

    testWidgets('semantics: button labeled with title and count', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, CdsTileButton(title: 'Inbox', count: 3, onPress: () {}, child: _media));
      expect(tester.getSemantics(find.byType(CdsPressable)), containsSemantics(label: 'Inbox, 3', isButton: true));
      handle.dispose();
    });

    testWidgets('keyboard: Enter activates', (tester) async {
      var taps = 0;
      await pumpCds(tester, CdsTileButton(title: 'Send', onPress: () => taps++, child: _media));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
    });

    testWidgets('does not scale on press', (tester) async {
      await pumpCds(tester, CdsTileButton(title: 'Send', onPress: () {}, child: _media));
      final gesture = await tester.startGesture(tester.getCenter(find.byType(CdsTileButton)));
      await tester.pumpAndSettle();
      final scale = tester.widget<Transform>(find.descendant(of: find.byType(CdsPressable), matching: find.byType(Transform)).first);
      expect(scale.transform.getMaxScaleOnAxis(), 1);
      await gesture.up();
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, CdsTileButton(title: 'Send', count: 4, onPress: () {}, child: _media), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
