import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  group('CdsThemeConfig.standard', () {
    const theme = CdsThemeConfig.standard;

    test('semantic colors resolve to the CDS spectrum', () {
      expect(theme.lightColor.bgPrimary, const Color(0xFF0052FF)); // blue60
      expect(theme.darkColor.bgPrimary, theme.darkSpectrum.of(CdsHue.blue, 70));
      expect(theme.lightColor.fg, theme.lightSpectrum.of(CdsHue.gray, 100));
      expect(theme.lightColor.bgLine, const Color(0x335B616E)); // gray60 @ 0.2
    });

    test('every color token resolves in both schemes', () {
      for (final token in CdsColor.values) {
        expect(theme.lightColor.resolve(token), isA<Color>());
        expect(theme.darkColor[token], isA<Color>());
      }
    });

    test('space, radius and border width scales match CDS', () {
      expect(theme.space(0.25), 2);
      expect(theme.space(1.5), 12);
      expect(theme.space(10), 80);
      expect(theme.borderRadius(200), 8);
      expect(theme.borderRadius(1000), 100000);
      expect(theme.borderWidth(100), 1);
      expect(theme.space.tokens, hasLength(15));
    });

    test('invalid tokens fail loudly in debug', () {
      expect(() => theme.space(2.5), throwsAssertionError);
      expect(() => theme.borderRadius(150), throwsAssertionError);
    });

    test('type ramp matches CDS default theme', () {
      final title1 = theme.typography[CdsFont.title1];
      expect(title1.fontSize, 28);
      expect(title1.lineHeight, 36);
      expect(title1.fontWeight, FontWeight.w600);
      expect(theme.typography[CdsFont.caption].textTransform, CdsTextTransform.uppercase);
      final style = theme.typography[CdsFont.body].toTextStyle(tabularNumbers: true, mono: true);
      expect(style.fontFamily, 'packages/cds_flutter/SourceCodePro');
      expect(style.height, 24 / 16);
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    test('spectrum rejects unknown steps', () {
      expect(() => theme.lightSpectrum.of(CdsHue.red, 55), throwsArgumentError);
    });

    test('high contrast theme raises muted text contrast', () {
      final normal = CdsColorUtils.contrastRatio(theme.lightColor.fgMuted, theme.lightColor.bg);
      final high = CdsColorUtils.contrastRatio(
          CdsThemeConfig.highContrast.lightColor.fgMuted, CdsThemeConfig.highContrast.lightColor.bg);
      expect(high, greaterThan(normal));
    });

    test('copyWith overrides individual tokens and keeps equality semantics', () {
      final custom = theme.copyWith(
        id: 'brand',
        lightColor: theme.lightColor.copyWith({CdsColor.bgPrimary: const Color(0xFF6A3DE8)}),
      );
      expect(custom.lightColor.bgPrimary, const Color(0xFF6A3DE8));
      expect(custom.lightColor.fg, theme.lightColor.fg);
      expect(custom == theme, isFalse);
      expect(theme.copyWith() == theme, isTrue);
    });
  });

  group('CdsColorPalette.lerp', () {
    test('interpolates every token', () {
      final mid = CdsColorPalette.lerp(
          CdsThemeConfig.standard.lightColor, CdsThemeConfig.standard.darkColor, 0.5);
      expect(mid.bg, Color.lerp(const Color(0xFFFFFFFF), const Color(0xFF0A0B0D), 0.5));
    });
  });

  group('CdsThemeProvider', () {
    Widget app(CdsColorSchemePreference pref, {Brightness platform = Brightness.light, bool highContrast = false}) {
      return MediaQuery(
        data: MediaQueryData(platformBrightness: platform, highContrast: highContrast),
        child: CdsThemeProvider(
          colorScheme: pref,
          child: Builder(builder: (context) => Text(
                '${context.cds.brightness.name}:${context.cds.config.id}',
                textDirection: TextDirection.ltr,
              )),
        ),
      );
    }

    testWidgets('follows the platform brightness for system preference', (tester) async {
      await tester.pumpWidget(app(CdsColorSchemePreference.system, platform: Brightness.dark));
      await tester.pumpAndSettle();
      expect(find.text('dark:cds-default'), findsOneWidget);
    });

    testWidgets('explicit preference wins over platform', (tester) async {
      await tester.pumpWidget(app(CdsColorSchemePreference.light, platform: Brightness.dark));
      await tester.pumpAndSettle();
      expect(find.text('light:cds-default'), findsOneWidget);
    });

    testWidgets('switches to the high contrast config when the platform asks', (tester) async {
      await tester.pumpWidget(app(CdsColorSchemePreference.light, highContrast: true));
      await tester.pumpAndSettle();
      expect(find.text('light:cds-default-high-contrast'), findsOneWidget);
    });

    testWidgets('cross-fades colors when the scheme changes', (tester) async {
      Color? bg;
      Widget probe(CdsColorSchemePreference pref) => MediaQuery(
            data: const MediaQueryData(),
            child: CdsThemeProvider(
              colorScheme: pref,
              child: Builder(builder: (context) {
                bg = context.cds.color.bg;
                return const SizedBox();
              }),
            ),
          );
      await tester.pumpWidget(probe(CdsColorSchemePreference.light));
      await tester.pumpWidget(probe(CdsColorSchemePreference.dark));
      await tester.pump(const Duration(milliseconds: 150));
      expect(bg, isNot(CdsThemeConfig.standard.lightColor.bg));
      expect(bg, isNot(CdsThemeConfig.standard.darkColor.bg));
      await tester.pumpAndSettle();
      expect(bg, CdsThemeConfig.standard.darkColor.bg);
    });

    testWidgets('switches instantly under reduced motion', (tester) async {
      Color? bg;
      Widget probe(CdsColorSchemePreference pref) => MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: CdsThemeProvider(
              colorScheme: pref,
              child: Builder(builder: (context) {
                bg = context.cds.color.bg;
                return const SizedBox();
              }),
            ),
          );
      await tester.pumpWidget(probe(CdsColorSchemePreference.light));
      await tester.pumpWidget(probe(CdsColorSchemePreference.dark));
      await tester.pump();
      expect(bg, CdsThemeConfig.standard.darkColor.bg);
    });
  });

  testWidgets('CdsTheme.of falls back to the default light theme', (tester) async {
    late CdsThemeData data;
    await tester.pumpWidget(Builder(builder: (context) {
      data = context.cds;
      return const SizedBox();
    }));
    expect(data, CdsThemeData.light);
  });

  testWidgets('cdsMaterialTheme maps core colors', (tester) async {
    final material = cdsMaterialTheme(CdsThemeData.dark);
    expect(material.colorScheme.primary, CdsThemeConfig.standard.darkColor.bgPrimary);
    expect(material.scaffoldBackgroundColor, CdsThemeConfig.standard.darkColor.bg);
    expect(material.brightness, Brightness.dark);
    await pumpCds(tester, const Text('ok'));
    expect(find.text('ok'), findsOneWidget);
  });
}
