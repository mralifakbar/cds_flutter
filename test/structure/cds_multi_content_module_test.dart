import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('renders title, description, content, action and end in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(
        tester,
        CdsMultiContentModule(
          pictogram: const CdsIcon(CdsIconName.wallet, size: CdsIconSize.l),
          title: 'Earn on your crypto',
          description: 'Stake eligible assets and receive rewards.',
          action: 'Start staking',
          onActionPress: () {},
          end: const CdsText('Sample data', font: CdsFont.legal),
          bordered: true,
          child: const CdsText('Rewards summary'),
        ),
        brightness: b,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Rewards summary'), findsOneWidget);
    }
  });

  testWidgets('title is a header and the action fires', (tester) async {
    final handle = tester.ensureSemantics();
    var pressed = 0;
    await pumpCds(
      tester,
      CdsMultiContentModule(title: 'Earn', action: 'Start staking', onActionPress: () => pressed++),
    );
    expect(tester.getSemantics(find.text('Earn')), matchesSemantics(label: 'Earn', isHeader: true));
    await tester.tap(find.text('Start staking'));
    expect(pressed, 1);
    handle.dispose();
  });

  testWidgets('description is limited to three lines and survives text scale 2.0', (tester) async {
    await pumpCds(
      tester,
      SizedBox(
        width: 320,
        child: CdsMultiContentModule(
          title: 'Earn',
          description: 'Long description ' * 30,
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.textContaining('Long description'));
    expect(text.maxLines, 3);
  });
}
