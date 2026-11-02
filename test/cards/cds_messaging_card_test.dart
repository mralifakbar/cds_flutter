import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _frame(Widget child) => SizedBox(width: 360, child: SingleChildScrollView(child: child));

void main() {
  group('CdsMessagingCard', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders both types and placements in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _frame(Column(children: [
            for (final type in CdsMessagingCardType.values)
              for (final placement in CdsMessagingCardMediaPlacement.values)
                CdsMessagingCard(
                  type: type,
                  mediaPlacement: placement,
                  tag: 'New',
                  title: 'Turn on price alerts',
                  description: 'Get notified when Bitcoin moves 5% in a day.',
                  action: 'Set up alerts',
                  onActionButtonPress: () {},
                  onDismissButtonPress: () {},
                  media: const CdsIcon(CdsIconName.bell, size: CdsIconSize.l),
                ),
          ])),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('upsell is bgPrimary with inverse text; nudge is bgAlternate', (tester) async {
      await pumpCds(tester, _frame(const CdsMessagingCard(type: CdsMessagingCardType.upsell, title: 'Upsell')));
      const theme = CdsThemeData.light;
      expect(tester.widget<Text>(find.text('Upsell')).style!.color, theme.color.fgInverse);
      await pumpCds(tester, _frame(const CdsMessagingCard(type: CdsMessagingCardType.nudge, title: 'Nudge')));
      expect(tester.widget<Text>(find.text('Nudge')).style!.color, theme.color.fg);
    });

    testWidgets('action and dismiss fire their callbacks', (tester) async {
      var actions = 0;
      var dismissals = 0;
      await pumpCds(tester, _frame(CdsMessagingCard(
        type: CdsMessagingCardType.nudge,
        title: 'Alerts',
        action: 'Set up alerts',
        onActionButtonPress: () => actions++,
        onDismissButtonPress: () => dismissals++,
      )));
      await tester.tap(find.text('Set up alerts'));
      await tester.tap(find.bySemanticsLabel('Dismiss Alerts'));
      expect(actions, 1);
      expect(dismissals, 1);
    });

    testWidgets('upsell action is a button', (tester) async {
      await pumpCds(tester, _frame(CdsMessagingCard(type: CdsMessagingCardType.upsell, title: 'Earn', action: 'Start earning', onActionButtonPress: () {})));
      expect(find.byType(CdsButton), findsOneWidget);
    });

    testWidgets('dismiss stays reachable on a pressable card', (tester) async {
      final handle = tester.ensureSemantics();
      var opens = 0;
      var dismissals = 0;
      await pumpCds(tester, _frame(CdsMessagingCard(
        type: CdsMessagingCardType.nudge,
        title: 'Alerts',
        description: 'Sample',
        onPress: () => opens++,
        onDismissButtonPress: () => dismissals++,
      )));
      expect(tester.getSemantics(find.bySemanticsLabel('Alerts, Sample')), containsSemantics(isButton: true));
      expect(tester.getSemantics(find.bySemanticsLabel('Dismiss Alerts')), containsSemantics(isButton: true));
      await tester.tap(find.bySemanticsLabel('Dismiss Alerts'));
      expect(dismissals, 1);
      expect(opens, 0);
      handle.dispose();
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(
        tester,
        _frame(CdsMessagingCard(
          type: CdsMessagingCardType.nudge,
          tag: 'New',
          title: 'Turn on price alerts',
          description: 'Get notified when Bitcoin moves.',
          action: 'Set up alerts',
          onActionButtonPress: () {},
          onDismissButtonPress: () {},
          media: const CdsIcon(CdsIconName.bell, size: CdsIconSize.l),
        )),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
