import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CdsColorUtils', () {
    test('luminance spans 0 to 1', () {
      expect(CdsColorUtils.luminance(const Color(0xFF000000)), 0);
      expect(CdsColorUtils.luminance(const Color(0xFFFFFFFF)), closeTo(1, 1e-9));
    });

    test('contrast ratio matches WCAG reference values', () {
      expect(CdsColorUtils.contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21, 1e-6));
      expect(CdsColorUtils.contrastRatio(const Color(0xFF777777), const Color(0xFFFFFFFF)), closeTo(4.48, 0.01));
      expect(CdsColorUtils.isAccessible(const Color(0xFF777777), const Color(0xFFFFFFFF)), isFalse);
      expect(CdsColorUtils.isAccessible(const Color(0xFF777777), const Color(0xFFFFFFFF), largeText: true), isTrue);
    });

    test('blend composites with alpha', () {
      final c = CdsColorUtils.blend(const Color(0xFFFFFFFF), const Color(0x80000000));
      expect((c.r * 255).round(), inInclusiveRange(126, 128));
    });

    test('near-black overlays in light mode blend toward white (high contrast path)', () {
      const ink = Color(0xFF0A0B0D);
      final pressed = CdsColorUtils.blendedColor(overlay: ink, blendOpacity: 0.82, brightness: Brightness.light);
      expect(CdsColorUtils.luminance(pressed), greaterThan(CdsColorUtils.luminance(ink)));
    });

    test('CDS blue (luminance above 0.11) in light mode darkens, as CDS does', () {
      const blue = Color(0xFF0052FF);
      final pressed = CdsColorUtils.blendedColor(overlay: blue, blendOpacity: 0.82, brightness: Brightness.light);
      expect(pressed, isNot(blue));
      expect(CdsColorUtils.luminance(pressed), lessThan(CdsColorUtils.luminance(blue)));
    });

    test('disabled tint skips contrast optimisation and lightens toward the scheme background', () {
      const blue = Color(0xFF0052FF);
      final disabled = CdsColorUtils.blendedColor(
          overlay: blue, blendOpacity: 0.5, brightness: Brightness.light, skipContrastOptimization: true);
      expect(CdsColorUtils.luminance(disabled), greaterThan(CdsColorUtils.luminance(blue)));
    });

    test('light gray in light mode blends toward black so the change stays visible', () {
      const gray = Color(0xFFEEF0F3);
      final pressed = CdsColorUtils.blendedColor(overlay: gray, blendOpacity: 0.82, brightness: Brightness.light);
      expect(CdsColorUtils.luminance(pressed), lessThan(CdsColorUtils.luminance(gray)));
    });

    test('transparent colors pass through untouched', () {
      const clear = Color(0x00FFFFFF);
      expect(CdsColorUtils.blendedColor(overlay: clear, blendOpacity: 0.82, brightness: Brightness.dark), clear);
    });

    test('semi-transparent overlays keep their alpha', () {
      const line = Color(0x335B616E);
      final out = CdsColorUtils.blendedColor(overlay: line, blendOpacity: 0.82, brightness: Brightness.light);
      expect(out.a, closeTo(line.a, 1e-6));
    });
  });

  group('CDS default palette contrast', () {
    for (final scheme in ['light', 'dark']) {
      test('$scheme: text tokens meet AA on bg', () {
        final p = scheme == 'light' ? CdsThemeConfig.standard.lightColor : CdsThemeConfig.standard.darkColor;
        for (final fg in [p.fg, p.fgMuted, p.fgPrimary, p.fgNegative]) {
          expect(CdsColorUtils.contrastRatio(fg, p.bg), greaterThanOrEqualTo(4.5));
        }
        expect(CdsColorUtils.contrastRatio(p.fgInverse, p.bgPrimary), greaterThanOrEqualTo(4.5));
      });
    }
  });
}
