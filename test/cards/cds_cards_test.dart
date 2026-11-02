import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _frame(Widget child, {double width = 360}) => SizedBox(width: width, child: SingleChildScrollView(child: child));

const _art = CdsRemoteImage(width: double.infinity, height: double.infinity, shape: CdsShape.rectangle);

List<Widget> _all({VoidCallback? onPress, VoidCallback? onDismiss}) => [
      CdsDataCard(title: 'Savings goal', subtitle: r'$450 of $1,000', thumbnail: const CdsCellMedia.icon(CdsIconName.wallet), onPress: onPress, child: const CdsProgressCircle(progress: 0.45)),
      CdsDataCard(title: 'Savings goal', layout: CdsDataCardLayout.horizontal, titleAccessory: const CdsIcon(CdsIconName.info, size: CdsIconSize.s), onPress: onPress, child: const CdsProgressCircle(progress: 0.45)),
      CdsNudgeCard(title: 'Add a backup', description: 'Save your recovery phrase.', action: 'Back up now', onActionPress: () {}, onDismissPress: onDismiss, onPress: onPress, media: const CdsIcon(CdsIconName.shield, size: CdsIconSize.l)),
      const CdsNudgeCard(title: 'Left media', mediaPosition: CdsNudgeCardMediaPosition.left, media: CdsIcon(CdsIconName.shield, size: CdsIconSize.l)),
      CdsUpsellCard(title: 'Earn rewards', description: 'Sample data', action: 'Start earning', onActionPress: () {}, onDismissPress: onDismiss, onPress: onPress, media: const SizedBox(width: 80, height: 80)),
      CdsMediaCard(thumbnail: const CdsAvatar(name: 'Ethereum'), subtitle: 'ETH', title: 'Ethereum', description: 'Sample data', media: _art, onPress: onPress),
      const CdsMediaCard(thumbnail: CdsAvatar(name: 'Ethereum'), title: 'Start media', mediaPlacement: CdsMediaCardMediaPlacement.start, media: _art),
      CdsContainedAssetCard(header: const CdsAvatar(name: 'Bitcoin'), subtitle: 'BTC', title: r'$64,201.10', description: '+2.4%', onPress: onPress),
      const CdsContainedAssetCard(header: CdsAvatar(name: 'Bitcoin'), title: 'Large', size: CdsAssetCardSize.l, child: _art),
      CdsFloatingAssetCard(media: _art, subtitle: 'Collection', title: 'Genesis drop', description: 'Sample data', onPress: onPress),
      const CdsFloatingAssetCard(media: _art, title: 'Large', size: CdsAssetCardSize.l),
    ];

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('every card renders in ${brightness.name}', (tester) async {
      await pumpCds(tester, _frame(Column(children: _all(onPress: () {}, onDismiss: () {}))), brightness: brightness);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('every card renders at text scale 2 without overflow', (tester) async {
    await pumpCds(tester, _frame(Column(children: _all(onPress: () {}, onDismiss: () {}))), textScale: 2);
    expect(tester.takeException(), isNull);
  });

  group('CdsDataCard', () {
    testWidgets('fires onPress and reads as one button', (tester) async {
      final handle = tester.ensureSemantics();
      var opens = 0;
      await pumpCds(tester, _frame(CdsDataCard(title: 'Goal', subtitle: 'Sample', onPress: () => opens++)));
      await tester.tap(find.text('Goal'));
      expect(opens, 1);
      expect(tester.getSemantics(find.bySemanticsLabel('Sample, Goal')), containsSemantics(isButton: true));
      handle.dispose();
    });
  });

  group('CdsNudgeCard', () {
    testWidgets('action, dismiss and card press fire separately', (tester) async {
      var actions = 0;
      var dismissals = 0;
      var opens = 0;
      await pumpCds(tester, _frame(CdsNudgeCard(
        title: 'Backup',
        action: 'Back up now',
        onActionPress: () => actions++,
        onDismissPress: () => dismissals++,
        onPress: () => opens++,
      )));
      await tester.tap(find.text('Back up now'));
      await tester.tap(find.bySemanticsLabel('Dismiss the Backup card'));
      expect((actions, dismissals, opens), (1, 1, 0));
      await tester.tap(find.text('Backup'));
      expect(opens, 1);
    });

    testWidgets('limits lines with maxLines', (tester) async {
      await pumpCds(tester, _frame(const CdsNudgeCard(title: 'Title', maxLines: 1)));
      expect(tester.widget<Text>(find.text('Title')).maxLines, 1);
    });
  });

  group('CdsUpsellCard', () {
    testWidgets('defaults to 327px wide and 158px tall on bgPrimaryWash', (tester) async {
      await pumpCds(tester, const SizedBox(width: 400, child: Align(child: CdsUpsellCard(title: 'Earn'))));
      expect(tester.getSize(find.byType(CdsUpsellCard)), const Size(327, 158));
    });

    testWidgets('action and dismiss fire', (tester) async {
      var actions = 0;
      var dismissals = 0;
      await pumpCds(tester, _frame(CdsUpsellCard(title: 'Earn', action: 'Start earning', onActionPress: () => actions++, onDismissPress: () => dismissals++)));
      await tester.tap(find.text('Start earning'));
      await tester.tap(find.bySemanticsLabel('Dismiss the Earn card'));
      expect((actions, dismissals), (1, 1));
    });
  });

  group('CdsMediaCard', () {
    testWidgets('media takes half the card', (tester) async {
      await pumpCds(tester, _frame(const CdsMediaCard(thumbnail: CdsAvatar(name: 'E'), title: 'Ethereum', media: _art)));
      expect(tester.getSize(find.byType(CdsRemoteImage).last).width, 180);
    });
  });

  group('asset cards', () {
    testWidgets('contained small card is 156px wide and at least 156px tall', (tester) async {
      await pumpCds(tester, const Align(child: CdsContainedAssetCard(header: CdsAvatar(name: 'B'), title: 'BTC')));
      final size = tester.getSize(find.byType(CdsContainedAssetCard));
      expect(size.width, 156);
      expect(size.height, greaterThanOrEqualTo(156));
    });

    testWidgets('floating card media tile is 156px tall', (tester) async {
      await pumpCds(tester, const Align(child: CdsFloatingAssetCard(media: _art, title: 'Drop')));
      expect(tester.getSize(find.byType(CdsRemoteImage)).height, lessThanOrEqualTo(156));
      expect(tester.getSize(find.byType(CdsFloatingAssetCard)).width, 156);
    });

    testWidgets('fire onPress', (tester) async {
      var opens = 0;
      await pumpCds(tester, Column(mainAxisSize: MainAxisSize.min, children: [
        CdsContainedAssetCard(header: const CdsAvatar(name: 'B'), title: 'Contained', onPress: () => opens++),
        CdsFloatingAssetCard(media: _art, title: 'Floating', onPress: () => opens++),
      ]));
      await tester.tap(find.text('Contained'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Floating'));
      expect(opens, 2);
    });
  });
}
