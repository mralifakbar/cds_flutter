@Tags(['golden'])
library;

import 'dart:ui' show Tristate;

import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  group('CdsButton', () {
    testWidgets('renders the label and fires onPress', (tester) async {
      var pressed = 0;
      await pumpCds(tester, CdsButton(label: 'Buy Bitcoin', onPress: () => pressed++));
      await tester.tap(find.text('Buy Bitcoin'));
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });

    testWidgets('l size is 56px tall with pill radius', (tester) async {
      await pumpCds(tester, CdsButton(label: 'Send', onPress: () {}));
      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect(tester.getSize(find.byType(AnimatedContainer)).height, 56);
      expect((container.decoration! as BoxDecoration).borderRadius, BorderRadius.circular(56));
    });

    testWidgets('variant colors come from CDS button tokens', (tester) async {
      await pumpCds(tester, CdsButton(label: 'Remove', variant: CdsButtonVariant.negative, onPress: () {}));
      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration! as BoxDecoration).color, CdsThemeConfig.standard.lightColor.bgNegative);
      expect(tester.widget<Text>(find.text('Remove')).style!.color, CdsThemeConfig.standard.lightColor.fgInverse);
    });

    testWidgets('transparent buttons have no background until pressed', (tester) async {
      await pumpCds(tester, CdsButton(label: 'Skip', transparent: true, onPress: () {}));
      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration! as BoxDecoration).color!.a, 0);
    });

    testWidgets('null onPress renders disabled and is announced as disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsButton(label: 'Continue'));
      final node = tester.getSemantics(find.byType(CdsPressable));
      expect(node.flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('loading keeps width, shows a spinner and blocks presses', (tester) async {
      var pressed = 0;
      Widget build(bool loading) => CdsButton(label: 'Submit order', loading: loading, onPress: () => pressed++);
      await pumpCds(tester, build(false));
      final width = tester.getSize(find.byType(CdsButton)).width;
      await pumpCds(tester, build(true), settle: false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getSize(find.byType(CdsButton)).width, width);
      expect(find.byType(CdsProgressCircle), findsOneWidget);
      await tester.tap(find.byType(CdsButton));
      await tester.pump(const Duration(milliseconds: 100));
      expect(pressed, 0);
      expect(find.bySemanticsLabel(RegExp('loading')), findsOneWidget);
    });

    testWidgets('block stretches to the parent width', (tester) async {
      await pumpCds(tester, SizedBox(width: 300, child: CdsButton(label: 'Continue', block: true, onPress: () {})));
      expect(tester.getSize(find.byType(CdsButton)).width, 300);
    });

    testWidgets('start and end icons render', (tester) async {
      await pumpCds(tester, CdsButton(label: 'Receive', startIcon: CdsIconName.arrowDown, endIcon: CdsIconName.caretRight, onPress: () {}));
      expect(find.byType(CdsIcon), findsNWidgets(2));
    });

    testWidgets('long labels at 2x text scale do not overflow', (tester) async {
      await pumpCds(tester, SizedBox(width: 200, child: CdsButton(label: 'Convert all remaining balance', onPress: () {})), textScale: 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('flush start shifts by its horizontal padding', (tester) async {
      await pumpCds(tester, Align(alignment: Alignment.centerLeft, child: CdsButton(label: 'Edit', flush: CdsFlush.start, transparent: true, size: CdsButtonSize.s, onPress: () {})), center: false);
      final container = tester.getTopLeft(find.byType(AnimatedContainer));
      expect(container.dx, lessThan(0));
    });
  });

  group('CdsIconButton', () {
    testWidgets('requires and exposes a semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, CdsIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () {}));
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('visual circle is 40px, hit area is 44px', (tester) async {
      var pressed = 0;
      await pumpCds(tester, CdsIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () => pressed++));
      expect(tester.getSize(find.byType(AnimatedContainer)), const Size(40, 40));
      expect(tester.getSize(find.byType(CdsIconButton)), const Size(44, 44));
      final corner = tester.getTopLeft(find.byType(CdsIconButton)) + const Offset(1, 1);
      await tester.tapAt(corner);
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });

    testWidgets('active shows the filled glyph', (tester) async {
      await pumpCds(tester, CdsIconButton(CdsIconName.star, semanticLabel: 'Favourite', active: true, onPress: () {}));
      expect(tester.widget<CdsIcon>(find.byType(CdsIcon)).active, isTrue);
    });
  });

  group('CdsProgressCircle', () {
    testWidgets('determinate exposes its percentage', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsProgressCircle(progress: 0.42, semanticLabel: 'Upload'));
      expect(tester.getSemantics(find.byType(CdsProgressCircle)), matchesSemantics(label: 'Upload', value: '42%'));
      handle.dispose();
    });

    testWidgets('indeterminate spins only while shown and holds still under reduced motion', (tester) async {
      await pumpCds(tester, const CdsProgressCircle.indeterminate(), settle: false);
      expect(find.byType(RotationTransition), findsOneWidget);
      await pumpCds(tester, const CdsProgressCircle.indeterminate(), disableAnimations: true, settle: false);
      await tester.pump();
      expect(find.byType(RotationTransition), findsNothing);
      await tester.pumpAndSettle();
    });
  });

  testWidgets('golden: buttons light and dark', (tester) async {
    await tester.binding.setSurfaceSize(const Size(760, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(goldenPair(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        for (final v in CdsButtonVariant.values) CdsButton(label: v.name, variant: v, size: CdsButtonSize.m, onPress: () {}),
        const CdsButton(label: 'Disabled', size: CdsButtonSize.m),
        Row(spacing: 8, children: [
          CdsIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () {}),
          CdsIconButton(CdsIconName.star, semanticLabel: 'Star', variant: CdsButtonVariant.primary, active: true, onPress: () {}),
          CdsButton(label: 'Receive', startIcon: CdsIconName.arrowDown, size: CdsButtonSize.s, onPress: () {}),
        ]),
      ],
    )));
    await expectLater(find.byType(Row).first, matchesGoldenFile('../goldens/buttons.png'));
  });
}
