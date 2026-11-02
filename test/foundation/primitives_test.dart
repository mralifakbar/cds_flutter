import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  group('CdsText', () {
    testWidgets('applies the ramp style and token color', (tester) async {
      await pumpCds(tester, const CdsText('Portfolio', font: CdsFont.title1, color: CdsColor.fgMuted));
      final text = tester.widget<Text>(find.text('Portfolio'));
      expect(text.style!.fontSize, 28);
      expect(text.style!.fontWeight, FontWeight.w600);
      expect(text.style!.color, CdsThemeConfig.standard.lightColor.fgMuted);
    });

    testWidgets('caption is uppercased but read as written', (tester) async {
      await pumpCds(tester, const CdsText.caption('Total balance'));
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
      expect(find.bySemanticsLabel('Total balance'), findsOneWidget);
    });

    testWidgets('maxLines truncates with ellipsis by default', (tester) async {
      await pumpCds(tester, const SizedBox(width: 60, child: CdsText('A very long asset name', maxLines: 1)));
      expect(tester.widget<Text>(find.byType(Text)).overflow, TextOverflow.ellipsis);
    });

    testWidgets('follows dark mode', (tester) async {
      await pumpCds(tester, const CdsText('Hi'), brightness: Brightness.dark);
      expect(tester.widget<Text>(find.text('Hi')).style!.color, CdsThemeConfig.standard.darkColor.fg);
    });

    testWidgets('rich text inherits the ramp style', (tester) async {
      await pumpCds(tester, const CdsText.rich(TextSpan(children: [TextSpan(text: 'a'), TextSpan(text: 'b')])));
      expect(find.byType(RichText), findsOneWidget);
    });
  });

  group('CdsIcon', () {
    test('picks the closest source glyph size', () {
      expect(CdsIconGlyph.sourceSizeFor(12), 12);
      expect(CdsIconGlyph.sourceSizeFor(16), 16);
      expect(CdsIconGlyph.sourceSizeFor(24), 24);
      expect(CdsIconGlyph.sourceSizeFor(32), 24);
    });

    test('active and inactive glyphs differ', () {
      final a = CdsIconName.home.codePoint(pixelSize: 24, active: true);
      final i = CdsIconName.home.codePoint(pixelSize: 24);
      expect(a, isNot(i));
      expect(a, greaterThan(0xF0000));
    });

    test('byCdsName finds icons by their CDS web name', () {
      expect(CdsIconGlyph.byCdsName('arrowLeft'), CdsIconName.arrowLeft);
      expect(CdsIconGlyph.byCdsName('factory'), CdsIconName.factoryIcon);
      expect(CdsIconGlyph.byCdsName('coinbase'), isNull, reason: 'brand marks are not shipped');
      expect(CdsIconGlyph.byCdsName('nope'), isNull);
    });

    testWidgets('is decorative unless labelled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const Row(mainAxisSize: MainAxisSize.min, children: [
        CdsIcon(CdsIconName.add),
        CdsIcon(CdsIconName.warning, semanticLabel: 'Warning'),
      ]));
      expect(find.bySemanticsLabel('Warning'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('sizes come from the theme', (tester) async {
      await pumpCds(tester, const CdsIcon(CdsIconName.add, size: CdsIconSize.l));
      expect(tester.getSize(find.byType(CdsIcon)), const Size(32, 32));
    });
  });

  group('CdsBox and stacks', () {
    testWidgets('resolves space tokens and radius', (tester) async {
      await pumpCds(tester, const CdsBox(padding: 2, paddingX: 3, background: CdsColor.bgSecondary, borderRadius: 400, child: SizedBox(width: 10, height: 10)));
      expect(tester.getSize(find.byType(CdsBox)), const Size(10 + 48, 10 + 32));
      final deco = tester.widget<DecoratedBox>(find.descendant(of: find.byType(CdsBox), matching: find.byType(DecoratedBox))).decoration as BoxDecoration;
      expect(deco.borderRadius, BorderRadius.circular(16));
      expect(deco.color, CdsThemeConfig.standard.lightColor.bgSecondary);
    });

    testWidgets('elevation adds shadow and the elevation surface', (tester) async {
      await pumpCds(tester, const CdsBox(elevation: CdsElevation.level2, child: SizedBox(width: 10, height: 10)), brightness: Brightness.dark);
      final deco = tester.widget<DecoratedBox>(find.descendant(of: find.byType(CdsBox), matching: find.byType(DecoratedBox))).decoration as BoxDecoration;
      expect(deco.boxShadow, isNotEmpty);
      expect(deco.color, CdsThemeConfig.standard.darkColor.bgElevation2);
    });

    testWidgets('stack gaps use the space scale', (tester) async {
      await pumpCds(tester, const CdsVStack(gap: 2, mainAxisSize: MainAxisSize.min, alignItems: CrossAxisAlignment.start, children: [
        SizedBox(key: Key('a'), width: 10, height: 10),
        SizedBox(key: Key('b'), width: 10, height: 10),
      ]));
      final a = tester.getBottomLeft(find.byKey(const Key('a')));
      final b = tester.getTopLeft(find.byKey(const Key('b')));
      expect(b.dy - a.dy, 16);
    });

    testWidgets('wrap mode flows onto new lines', (tester) async {
      await pumpCds(tester, SizedBox(
        width: 100,
        child: CdsHStack(wrap: true, gap: 1, children: List.generate(4, (i) => const SizedBox(width: 40, height: 10))),
      ));
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('directional padding flips in RTL', (tester) async {
      await pumpCds(tester, const CdsBox(paddingStart: 2, child: SizedBox(key: Key('c'), width: 10, height: 10)),
          textDirection: TextDirection.rtl);
      final box = tester.getRect(find.byType(CdsBox));
      final child = tester.getRect(find.byKey(const Key('c')));
      expect(box.right - child.right, 16);
    });
  });
}
