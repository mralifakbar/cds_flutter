import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _frame(Widget child) => SizedBox(width: 360, child: SingleChildScrollView(child: child));

CdsContentCard _card({VoidCallback? onPress, VoidCallback? onShare, CdsContentCardMediaPlacement placement = CdsContentCardMediaPlacement.top}) {
  return CdsContentCard(
    background: CdsColor.bgAlternate,
    onPress: onPress,
    semanticLabel: onPress == null ? null : 'Read market update',
    children: [
      CdsContentCardHeader(
        thumbnail: const CdsAvatar(name: 'Market'),
        title: 'Market update',
        subtitle: 'News',
        actions: CdsIconButton(CdsIconName.more, semanticLabel: 'More options', transparent: true, onPress: () {}),
      ),
      CdsContentCardBody(
        title: 'Bitcoin trading volume rose this week',
        description: 'Sample data for the test.',
        media: const CdsRemoteImage(width: double.infinity, aspectRatio: 2),
        mediaPlacement: placement,
      ),
      CdsContentCardFooter(children: [
        const CdsText.label2('Sample data'),
        CdsButton(label: 'Share', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: onShare ?? () {}),
      ]),
    ],
  );
}

void main() {
  group('CdsContentCard', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every media placement in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _frame(Column(children: [for (final p in CdsContentCardMediaPlacement.values) _card(placement: p)])),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('start and end media sit in a 96px square', (tester) async {
      await pumpCds(tester, _frame(_card(placement: CdsContentCardMediaPlacement.end)));
      expect(tester.getSize(find.byType(CdsRemoteImage)), const Size(96, 96));
    });

    testWidgets('pressing the card fires onPress; inner buttons fire alone', (tester) async {
      var opens = 0;
      var shares = 0;
      await pumpCds(tester, _frame(_card(onPress: () => opens++, onShare: () => shares++)));
      await tester.tap(find.text('Bitcoin trading volume rose this week'));
      expect(opens, 1);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Share'));
      expect(shares, 1);
      expect(opens, 1);
    });

    testWidgets('pressable card is one button and inner buttons stay separate', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _frame(_card(onPress: () {})));
      expect(tester.getSemantics(find.bySemanticsLabel('Read market update')), containsSemantics(isButton: true, hasTapAction: true));
      expect(tester.getSemantics(find.bySemanticsLabel('More options')), containsSemantics(isButton: true, hasTapAction: true));
      expect(find.bySemanticsLabel('Share'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('scales down on press and springs back', (tester) async {
      await pumpCds(tester, _frame(_card(onPress: () {})));
      final gesture = await tester.startGesture(tester.getCenter(find.text('Sample data for the test.')));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));
      final scaled = tester.widgetList<Transform>(find.ancestor(of: find.text('Market update'), matching: find.byType(Transform)));
      expect(scaled.any((t) => t.transform.storage[0] < 1), isTrue);
      await gesture.up();
      await tester.pumpAndSettle();
      final settled = tester.widgetList<Transform>(find.ancestor(of: find.text('Market update'), matching: find.byType(Transform)));
      expect(settled.every((t) => (t.transform.storage[0] - 1).abs() < 0.001), isTrue);
    });

    testWidgets('does not scale under reduced motion', (tester) async {
      await pumpCds(tester, _frame(_card(onPress: () {})), disableAnimations: true);
      final gesture = await tester.startGesture(tester.getCenter(find.text('Sample data for the test.')));
      await tester.pump(const Duration(milliseconds: 200));
      final transforms = tester.widgetList<Transform>(find.ancestor(of: find.text('Market update'), matching: find.byType(Transform)));
      expect(transforms.every((t) => t.transform.storage[0] == 1), isTrue);
      await gesture.up();
    });

    testWidgets('activates from the keyboard', (tester) async {
      var opens = 0;
      await pumpCds(tester, _frame(CdsContentCard(
        onPress: () => opens++,
        semanticLabel: 'Open',
        children: const [CdsContentCardBody(title: 'Title')],
      )));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(opens, 1);
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(tester, _frame(_card(placement: CdsContentCardMediaPlacement.start)), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
