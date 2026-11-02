import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import '../media/test_images.dart';

Widget _frame(Widget child) => SizedBox(width: 390, child: SingleChildScrollView(child: child));

void main() {
  group('CdsListCell', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every variant in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _frame(Column(mainAxisSize: MainAxisSize.min, children: [
            for (final v in CdsCellSpacingVariant.values)
              CdsListCell(
                spacingVariant: v,
                title: 'Bitcoin',
                subtitle: 'Sample data',
                description: 'BTC',
                detail: r'$64,201.10',
                subdetail: '+2.4%',
                variant: CdsCellDetailVariant.positive,
                media: CdsCellMedia.asset(source: transparentImage()),
                accessory: CdsCellAccessoryType.arrow,
                helperText: const CdsCellHelperText('Sample helper'),
                onPress: () {},
              ),
            for (final a in CdsCellAccessoryType.values) CdsListCell(title: a.name, accessory: a),
          ])),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('keeps the CDS minimum heights', (tester) async {
      await pumpCds(tester, _frame(const CdsListCell(title: 'Normal')));
      expect(tester.getSize(find.byType(CdsListCell)).height, 80);
      // Compact keeps a 40px minimum, but its 16px vertical padding already
      // makes a one-line cell taller.
      await pumpCds(tester, _frame(const CdsListCell(title: 'Compact', spacingVariant: CdsCellSpacingVariant.compact)));
      expect(tester.getSize(find.byType(CdsListCell)).height, 56);
      await pumpCds(tester, _frame(const CdsListCell(title: 'Condensed', spacingVariant: CdsCellSpacingVariant.condensed)));
      // 8px padding above and below a 24px headline line.
      expect(tester.getSize(find.byType(CdsListCell)).height, 40);
    });

    testWidgets('aligns content with the 24px gutter', (tester) async {
      await pumpCds(tester, _frame(CdsListCell(title: 'Gutter', onPress: () {})), center: false);
      expect(tester.getTopLeft(find.text('Gutter')).dx, 24);
      await pumpCds(tester, _frame(const CdsListCell(title: 'Gutter')), center: false);
      expect(tester.getTopLeft(find.text('Gutter')).dx, 24);
    });

    testWidgets('fires onPress and not when disabled', (tester) async {
      var taps = 0;
      await pumpCds(tester, _frame(CdsListCell(title: 'Tap me', onPress: () => taps++)));
      await tester.tap(find.text('Tap me'));
      expect(taps, 1);
      await pumpCds(tester, _frame(CdsListCell(title: 'Disabled', disabled: true, onPress: () => taps++)));
      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      expect(taps, 1);
    });

    testWidgets('activates with the keyboard', (tester) async {
      var taps = 0;
      await pumpCds(tester, _frame(CdsListCell(title: 'Keys', onPress: () => taps++)));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('selected shows a checkmark and the selected state', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _frame(CdsListCell(title: 'USD', selected: true, onPress: () {})));
      expect(find.byType(CdsCellAccessory), findsOneWidget);
      expect(tester.widget<CdsCellAccessory>(find.byType(CdsCellAccessory)).type, CdsCellAccessoryType.selected);
      expect(tester.getSemantics(find.text('USD')), containsSemantics(isSelected: true, isButton: true, label: 'USD'));
      handle.dispose();
    });

    testWidgets('disableSelectionAccessory keeps the given accessory', (tester) async {
      await pumpCds(tester, _frame(const CdsListCell(title: 'USD', selected: true, disableSelectionAccessory: true, accessory: CdsCellAccessoryType.more)));
      expect(tester.widget<CdsCellAccessory>(find.byType(CdsCellAccessory)).type, CdsCellAccessoryType.more);
    });

    testWidgets('merges its text into one button label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _frame(CdsListCell(title: 'Bitcoin', description: 'BTC', detail: r'$10', onPress: () {})));
      final label = tester.getSemantics(find.text('Bitcoin')).getSemanticsData().label;
      expect(label, contains('Bitcoin'));
      expect(label, contains('BTC'));
      expect(label, contains(r'$10'));
      handle.dispose();
    });

    testWidgets('helper text announces its tone, not only its color', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _frame(const CdsListCell(
        title: 'Card',
        helperText: CdsCellHelperText('Card expired', variant: CdsCellHelperTextVariant.error),
      )));
      expect(find.bySemanticsLabel(RegExp('Error: Card expired')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('end priority keeps the detail whole while the title truncates', (tester) async {
      await pumpCds(tester, _frame(const CdsListCell(
        title: 'A very long asset name that will not fit next to the balance',
        detail: r'$1,234,567.89',
        priority: {CdsCellPriority.end},
        disableMultilineTitle: true,
      )));
      final detail = tester.renderObject<RenderBox>(find.text(r'$1,234,567.89'));
      final painter = TextPainter(
        text: TextSpan(text: r'$1,234,567.89', style: tester.widget<Text>(find.text(r'$1,234,567.89')).style),
        textDirection: TextDirection.ltr,
      )..layout();
      expect(detail.size.width, greaterThanOrEqualTo(painter.width - 0.5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('mirrors in right-to-left', (tester) async {
      await pumpCds(tester, _frame(const CdsListCell(title: 'Start', detail: 'End')), textDirection: TextDirection.rtl);
      expect(tester.getCenter(find.text('Start')).dx, greaterThan(tester.getCenter(find.text('End')).dx));
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(
        tester,
        _frame(CdsListCell(
          spacingVariant: CdsCellSpacingVariant.condensed,
          title: 'Ethereum staking rewards',
          description: 'Sample data',
          detail: r'$4,201.10',
          subdetail: '+2.4%',
          media: const CdsCellMedia.icon(CdsIconName.wallet),
          accessory: CdsCellAccessoryType.arrow,
          helperText: const CdsCellHelperText('Rewards paid weekly'),
          onPress: () {},
        )),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('CdsListCellFallback', () {
    testWidgets('renders placeholders with one Loading label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _frame(Column(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < 3; i++)
          CdsListCellFallback(title: true, subtitle: true, description: true, detail: true, subdetail: true, helperText: true, media: CdsCellMediaType.values[i], rectWidthVariant: i),
      ])));
      expect(find.bySemanticsLabel('Loading'), findsNWidgets(3));
      expect(find.byType(CdsMediaFallback), findsNWidgets(3));
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('has no running animations', (tester) async {
      await pumpCds(tester, _frame(const CdsListCellFallback(title: true)), settle: false);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('matches the loaded cell height', (tester) async {
      await pumpCds(tester, _frame(const CdsListCellFallback(title: true, description: true, spacingVariant: CdsCellSpacingVariant.condensed)));
      final placeholder = tester.getSize(find.byType(CdsListCellFallback)).height;
      await pumpCds(tester, _frame(const CdsListCell(title: 'Title', description: 'Description', spacingVariant: CdsCellSpacingVariant.condensed)));
      expect(tester.getSize(find.byType(CdsListCell)).height, placeholder);
    });
  });

  group('CdsCellSpacing', () {
    test('padding resets both axes', () {
      final merged = CdsCellSpacing.defaultInner.merge(const CdsCellSpacing(padding: 3));
      expect(merged.paddingX, 3);
      expect(merged.paddingY, 3);
      expect(merged.marginX, -2);
    });
  });
}
