import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Color _bgOf(WidgetTester tester, Finder chip) {
  final box = tester.widgetList<DecoratedBox>(find.descendant(of: chip, matching: find.byType(DecoratedBox))).first;
  return (box.decoration as BoxDecoration).color!;
}

void main() {
  group('CdsChip', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders sizes and states in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Wrap(
            children: [
              const CdsChip(label: 'Static'),
              CdsChip(label: 'Small', onPress: () {}),
              CdsChip(label: 'Xs', size: CdsChipSize.xs, onPress: () {}),
              CdsChip(label: 'Active', active: true, onPress: () {}),
              CdsChip(label: 'Disabled', disabled: true, onPress: () {}),
              CdsChip(
                label: 'Slots',
                start: const CdsIcon(CdsIconName.search, size: CdsIconSize.s),
                end: const CdsIcon(CdsIconName.caretDown, size: CdsIconSize.xs),
                onPress: () {},
              ),
            ],
          ),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('size s uses 16/8 padding and headline, xs 12/6 and label1', (tester) async {
      await pumpCds(tester, const Column(mainAxisSize: MainAxisSize.min, children: [
        CdsChip(label: 'S'),
        CdsChip(label: 'XS', size: CdsChipSize.xs),
      ]));
      final s = tester.widget<Padding>(find.ancestor(of: find.text('S'), matching: find.byType(Padding)).first);
      expect(s.padding, const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8));
      final xs = tester.widget<Padding>(find.ancestor(of: find.text('XS'), matching: find.byType(Padding)).first);
      expect(xs.padding, const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 6));
      expect(tester.widget<CdsText>(find.byWidgetPredicate((w) => w is CdsText && w.data == 'S')).font, CdsFont.headline);
      expect(tester.widget<CdsText>(find.byWidgetPredicate((w) => w is CdsText && w.data == 'XS')).font, CdsFont.label1);
    });

    testWidgets('onPress fires; disabled does not', (tester) async {
      var taps = 0;
      await pumpCds(tester, Column(mainAxisSize: MainAxisSize.min, children: [
        CdsChip(label: 'Go', onPress: () => taps++),
        CdsChip(label: 'Off', disabled: true, onPress: () => taps++),
      ]));
      await tester.tap(find.text('Go'));
      await tester.tap(find.text('Off'));
      expect(taps, 1);
    });

    testWidgets('active inverts the scheme; activeBackground opts out', (tester) async {
      await pumpCds(tester, const Column(mainAxisSize: MainAxisSize.min, children: [
        CdsChip(label: 'Plain'),
        CdsChip(label: 'Inverted', active: true),
        CdsChip(label: 'Custom', active: true, activeBackground: CdsColor.bgPrimary, activeColor: CdsColor.fgInverse),
      ]));
      const light = CdsThemeData.light;
      const dark = CdsThemeData.dark;
      expect(_bgOf(tester, find.widgetWithText(CdsChip, 'Plain')), light.color.bgSecondary);
      expect(_bgOf(tester, find.widgetWithText(CdsChip, 'Inverted')), dark.color.bgSecondary);
      expect(_bgOf(tester, find.widgetWithText(CdsChip, 'Custom')), light.color.bgPrimary);
    });

    testWidgets('long labels truncate at maxWidth', (tester) async {
      await pumpCds(tester, const CdsChip(label: 'A very long chip label that keeps going and going'));
      expect(tester.getSize(find.byType(CdsChip)).width, lessThanOrEqualTo(200));
      expect(tester.takeException(), isNull);
    });

    testWidgets('semantics: pressable chip is a button with selected state when given', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, CdsChip(label: 'Gainers', active: true, selected: true, onPress: () {}));
      expect(tester.getSemantics(find.byType(CdsPressable)),
          containsSemantics(label: 'Gainers', isButton: true, isSelected: true));
      handle.dispose();
    });

    testWidgets('keyboard: Tab focuses, Enter presses', (tester) async {
      var taps = 0;
      await pumpCds(tester, CdsChip(label: 'Key', onPress: () => taps++));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
    });

    testWidgets('pressable chip has a 44px hit area', (tester) async {
      await pumpCds(tester, CdsChip(label: 'Tiny', size: CdsChipSize.xs, onPress: () {}));
      expect(tester.getSize(find.byType(CdsPressable)).height, greaterThanOrEqualTo(44));
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, CdsChip(label: 'Scaled chip', start: const CdsIcon(CdsIconName.search), onPress: () {}), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
