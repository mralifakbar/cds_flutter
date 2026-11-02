// The indicator painter is private; tests read its geometry dynamically.
// ignore_for_file: avoid_dynamic_calls

import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Color _textColor(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!.color!;

void main() {
  group('CdsTabLabel', () {
    testWidgets('primary colors follow active state', (tester) async {
      await pumpCds(tester, const Column(children: [CdsTabLabel('On', active: true), CdsTabLabel('Off')]));
      final c = CdsThemeData.light.color;
      expect(_textColor(tester, 'On'), c.fgPrimary);
      expect(_textColor(tester, 'Off'), c.fg);
    });

    testWidgets('secondary uses title fonts and keeps width stable', (tester) async {
      await pumpCds(tester, const CdsTabLabel('Assets', variant: CdsTabLabelVariant.secondary));
      final inactive = tester.getSize(find.byType(CdsTabLabel)).width;
      await pumpCds(tester, const CdsTabLabel('Assets', variant: CdsTabLabelVariant.secondary, active: true));
      final active = tester.getSize(find.byType(CdsTabLabel)).width;
      expect(inactive, closeTo(active, 0.5));
      expect(tester.widget<CdsText>(find.byType(CdsText).first).font, CdsFont.title3);
    });

    testWidgets('count badge animates in and out', (tester) async {
      await pumpCds(tester, const CdsTabLabel('Inbox'));
      final base = tester.getSize(find.byType(CdsTabLabel)).width;
      await pumpCds(tester, const CdsTabLabel('Inbox', count: 4), settle: false);
      await tester.pump(const Duration(milliseconds: 50));
      final mid = tester.getSize(find.byType(CdsTabLabel)).width;
      await tester.pumpAndSettle();
      final full = tester.getSize(find.byType(CdsTabLabel)).width;
      expect(mid, greaterThan(base));
      expect(full, greaterThan(mid));
      expect(find.text('4'), findsOneWidget);

      await pumpCds(tester, const CdsTabLabel('Inbox'));
      expect(find.text('4'), findsNothing);
      expect(tester.getSize(find.byType(CdsTabLabel)).width, closeTo(base, 0.5));
    });

    testWidgets('dark mode and text scale 2.0 render', (tester) async {
      await pumpCds(tester, const CdsTabLabel('Portfolio', count: 120), brightness: Brightness.dark, textScale: 2);
      expect(find.text('99+'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('CdsTabIndicator', () {
    double barX(WidgetTester tester) {
      final paint = tester.widget<CustomPaint>(
        find.descendant(of: find.byType(CdsTabIndicator), matching: find.byType(CustomPaint)).first,
      );
      return (paint.painter! as dynamic).x as double;
    }

    testWidgets('springs from its current position', (tester) async {
      await pumpCds(tester, const SizedBox(width: 300, child: CdsTabIndicator(x: 0, width: 60)));
      expect(barX(tester), 0);
      await pumpCds(tester, const SizedBox(width: 300, child: CdsTabIndicator(x: 200, width: 60)), settle: false);
      await tester.pump(const Duration(milliseconds: 40));
      final first = barX(tester);
      expect(first, greaterThan(0));
      expect(first, lessThan(200));
      // Retarget mid-flight: no jump back to 0.
      await pumpCds(tester, const SizedBox(width: 300, child: CdsTabIndicator(x: 100, width: 60)), settle: false);
      await tester.pump(const Duration(milliseconds: 16));
      expect(barX(tester), greaterThan(first * 0.9));
      await tester.pumpAndSettle();
      expect(barX(tester), closeTo(100, 0.5));
    });

    testWidgets('animate: false jumps', (tester) async {
      await pumpCds(tester, const SizedBox(width: 300, child: CdsTabIndicator(x: 0, width: 60)));
      await pumpCds(tester, const SizedBox(width: 300, child: CdsTabIndicator(x: 120, width: 60, animate: false)), settle: false);
      expect(barX(tester), 120);
    });

    testWidgets('reduced motion jumps', (tester) async {
      await pumpCds(tester, const SizedBox(width: 300, child: CdsTabIndicator(x: 0, width: 60)), disableAnimations: true);
      await pumpCds(tester, const SizedBox(width: 300, child: CdsTabIndicator(x: 90, width: 60)), disableAnimations: true, settle: false);
      expect(barX(tester), 90);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
