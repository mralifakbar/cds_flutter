import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Finder _inNumber(Type type) => find.descendant(of: find.byType(CdsRollingNumber), matching: find.byType(type));

List<double> _offsets(WidgetTester tester) =>
    tester.widgetList<FractionalTranslation>(_inNumber(FractionalTranslation)).map((w) => w.translation.dy).toList();

Color? _textColor(WidgetTester tester) => tester.widget<Text>(_inNumber(Text).first).style!.color;

Future<void> _pump(WidgetTester tester, Widget child, {bool disableAnimations = false, Brightness brightness = Brightness.light}) =>
    pumpCds(tester, child, disableAnimations: disableAnimations, brightness: brightness, settle: false);

void main() {
  group('CdsRollingNumber', () {
    testWidgets('renders in light and dark with theme colors', (tester) async {
      await _pump(tester, const CdsRollingNumber(value: 42));
      expect(_textColor(tester), CdsThemeData.light.color.fg);
      await _pump(tester, const CdsRollingNumber(value: 42), brightness: Brightness.dark);
      await tester.pumpAndSettle();
      expect(_textColor(tester), CdsThemeData.dark.color.fg);
      expect(tester.takeException(), isNull);
    });

    testWidgets('digits roll through intermediate positions and settle on the new value', (tester) async {
      await _pump(tester, const CdsRollingNumber(value: 1));
      expect(_offsets(tester), [closeTo(-0.1, 1e-9)]);

      await _pump(tester, const CdsRollingNumber(value: 9));
      await tester.pump(const Duration(milliseconds: 40));
      final mid = _offsets(tester).single;
      expect(mid, lessThan(-0.1));
      expect(mid, greaterThan(-0.9));

      await tester.pump(const Duration(milliseconds: 40));
      expect(_offsets(tester).single, isNot(mid));

      await tester.pumpAndSettle();
      expect(_offsets(tester).single, closeTo(-0.9, 1e-3));
    });

    testWidgets('a new integer column rolls in from zero', (tester) async {
      await _pump(tester, const CdsRollingNumber(value: 999));
      await tester.pump();
      await _pump(tester, const CdsRollingNumber(value: 1000));
      await tester.pump();
      expect(_offsets(tester).first, closeTo(0, 1e-9));
      await tester.pumpAndSettle();
      expect(_offsets(tester).map((o) => o.abs()).toList(),
          [closeTo(0.1, 1e-3), closeTo(0, 1e-3), closeTo(0, 1e-3), closeTo(0, 1e-3)]);
    });

    testWidgets('single variant slides the new digit in from below when the value grows', (tester) async {
      const variant = CdsDigitTransitionVariant.single;
      await _pump(tester, const CdsRollingNumber(value: 1, digitTransitionVariant: variant));
      expect(_offsets(tester), [0]);

      await _pump(tester, const CdsRollingNumber(value: 9, digitTransitionVariant: variant));
      await tester.pump(const Duration(milliseconds: 30));
      final offsets = _offsets(tester);
      expect(offsets, hasLength(2));
      expect(offsets.first, lessThan(0), reason: 'old digit exits upward');
      expect(offsets.last, greaterThan(0), reason: 'new digit enters from below');

      await tester.pumpAndSettle();
      expect(_offsets(tester), [closeTo(0, 1e-3)]);

      await _pump(tester, const CdsRollingNumber(value: 2, digitTransitionVariant: variant));
      await tester.pump(const Duration(milliseconds: 30));
      expect(_offsets(tester).last, lessThan(0), reason: 'decrease enters from above');
      await tester.pumpAndSettle();
    });

    testWidgets('formats currency and percent and announces the final value', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, const CdsRollingNumber(value: 1234.56, format: CdsNumberFormat.currency()));
      expect(
        tester.getSemantics(find.byType(CdsRollingNumber)),
        matchesSemantics(label: r'$1,234.56', isLiveRegion: true),
      );

      await _pump(tester, const CdsRollingNumber(value: 0.4567, format: CdsNumberFormat.percent(maximumFractionDigits: 1)));
      await tester.pump(const Duration(milliseconds: 20));
      // Mid-roll, the label is already the final value; digit glyphs are hidden.
      expect(find.bySemanticsLabel('45.7%'), findsOneWidget);
      expect(find.bySemanticsLabel('7'), findsNothing);
      await tester.pumpAndSettle();
      semantics.dispose();
    });

    testWidgets('prefix, suffix and label affixes join the announced value', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(
        tester,
        const CdsRollingNumber(
          value: 1.5,
          prefix: '+',
          suffix: ' BTC',
          semanticLabelPrefix: 'up',
          liveRegion: false,
        ),
      );
      expect(
        tester.getSemantics(find.byType(CdsRollingNumber)),
        matchesSemantics(label: 'up +1.5 BTC'),
      );
      expect(find.text('+'), findsOneWidget);
      expect(find.text(' BTC'), findsOneWidget);

      await _pump(tester, const CdsRollingNumber(value: 1.5, semanticLabel: 'one and a half'));
      expect(find.bySemanticsLabel('one and a half'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('formattedValue renders as given and keeps value for deltas', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, const CdsRollingNumber(value: 98765.43, formattedValue: '¥98,765.43 BTC'));
      expect(find.bySemanticsLabel('¥98,765.43 BTC'), findsOneWidget);
      expect(find.text('¥'), findsOneWidget);
      expect(find.text(' BTC'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('subscript notation shows the zero count', (tester) async {
      await _pump(
        tester,
        const CdsRollingNumber(
          value: 0.00009,
          enableSubscriptNotation: true,
          format: CdsNumberFormat(maximumFractionDigits: 8),
        ),
      );
      expect(find.text('₄'), findsOneWidget);
    });

    testWidgets('color pulses positive on increase and negative on decrease', (tester) async {
      final light = CdsThemeData.light.color;
      await _pump(tester, const CdsRollingNumber(value: 10, colorPulseOnUpdate: true));
      expect(_textColor(tester), light.fg);

      await _pump(tester, const CdsRollingNumber(value: 11, colorPulseOnUpdate: true));
      expect(_textColor(tester), light.fgPositive);
      await tester.pump(const Duration(milliseconds: 500));
      final midway = _textColor(tester);
      expect(midway, isNot(light.fgPositive));
      expect(midway, isNot(light.fg));
      await tester.pumpAndSettle();
      expect(_textColor(tester), light.fg);

      await _pump(tester, const CdsRollingNumber(value: 5, colorPulseOnUpdate: true));
      expect(_textColor(tester), light.fgNegative);
      await tester.pumpAndSettle();
      expect(_textColor(tester), light.fg);
    });

    testWidgets('custom pulse colors and base color', (tester) async {
      final light = CdsThemeData.light.color;
      const a = CdsRollingNumber(value: 1, colorPulseOnUpdate: true, color: CdsColor.fgPrimary, positivePulseColor: CdsColor.fgWarning);
      const b = CdsRollingNumber(value: 2, colorPulseOnUpdate: true, color: CdsColor.fgPrimary, positivePulseColor: CdsColor.fgWarning);
      await _pump(tester, a);
      expect(_textColor(tester), light.fgPrimary);
      await _pump(tester, b);
      expect(_textColor(tester), light.fgWarning);
      await tester.pumpAndSettle();
      expect(_textColor(tester), light.fgPrimary);
    });

    testWidgets('no pulse when the displayed text does not change or pulse is off', (tester) async {
      final light = CdsThemeData.light.color;
      const compact = CdsNumberFormat(notation: CdsNumberNotation.compact);
      await _pump(tester, const CdsRollingNumber(value: 125000, format: compact, colorPulseOnUpdate: true));
      await _pump(tester, const CdsRollingNumber(value: 125001, format: compact, colorPulseOnUpdate: true));
      expect(_textColor(tester), light.fg);

      await _pump(tester, const CdsRollingNumber(value: 1));
      await _pump(tester, const CdsRollingNumber(value: 2));
      expect(_textColor(tester), light.fg);
      await tester.pumpAndSettle();
    });

    testWidgets('reduced motion changes instantly with no running tickers', (tester) async {
      await _pump(tester, const CdsRollingNumber(value: 1, colorPulseOnUpdate: true), disableAnimations: true);
      await tester.pump();
      await _pump(tester, const CdsRollingNumber(value: 1009, colorPulseOnUpdate: true), disableAnimations: true);
      expect(_offsets(tester).map((o) => o.abs()).toList(),
          [closeTo(0.1, 1e-9), closeTo(0, 1e-9), closeTo(0, 1e-9), closeTo(0.9, 1e-9)]);
      expect(_textColor(tester), CdsThemeData.light.color.fg);
      expect(tester.binding.hasScheduledFrame, isFalse);

      const single = CdsDigitTransitionVariant.single;
      await _pump(tester, const CdsRollingNumber(value: 3, digitTransitionVariant: single), disableAnimations: true);
      await _pump(tester, const CdsRollingNumber(value: 4, digitTransitionVariant: single), disableAnimations: true);
      expect(_offsets(tester), [0]);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('timed y transition is honored', (tester) async {
      const transition = CdsRollingNumberTransition(yDuration: Duration(milliseconds: 300), yCurve: Curves.linear);
      await _pump(tester, const CdsRollingNumber(value: 0, transition: transition));
      await _pump(tester, const CdsRollingNumber(value: 6, transition: transition));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(_offsets(tester).single, closeTo(-0.3, 0.02));
      await tester.pump(const Duration(milliseconds: 150));
      expect(_offsets(tester).single, closeTo(-0.6, 1e-3));
    });

    testWidgets('uses tabular figures by default', (tester) async {
      await _pump(tester, const CdsRollingNumber(value: 1));
      final features = tester.widget<Text>(_inNumber(Text).first).style!.fontFeatures;
      expect(features, contains(const FontFeature.tabularFigures()));

      await _pump(tester, const CdsRollingNumber(value: 1, tabularNumbers: false));
      expect(tester.widget<Text>(_inNumber(Text).first).style!.fontFeatures, isNull);
    });

    testWidgets('digit cells match the font line height and scale with text', (tester) async {
      await _pump(tester, const CdsRollingNumber(value: 7, font: CdsFont.title1));
      final base = tester.getSize(find.byType(CdsRollingNumber)).height;
      expect(base, CdsThemeData.light.typography[CdsFont.title1].lineHeight);

      await pumpCds(tester, const CdsRollingNumber(value: 1234567.89, font: CdsFont.title1), textScale: 2);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(CdsRollingNumber)).height, closeTo(base * 2, 0.5));
    });

    testWidgets('start and end slots render around the number', (tester) async {
      await _pump(
        tester,
        const CdsRollingNumber(
          value: 3,
          start: SizedBox(key: Key('start'), width: 8, height: 8),
          end: SizedBox(key: Key('end'), width: 8, height: 8),
        ),
      );
      final start = tester.getTopLeft(find.byKey(const Key('start'))).dx;
      final end = tester.getTopLeft(find.byKey(const Key('end'))).dx;
      expect(start, lessThan(end));
    });

    testWidgets('NaN does not throw', (tester) async {
      await _pump(tester, const CdsRollingNumber(value: double.nan));
      await _pump(tester, const CdsRollingNumber(value: 3, colorPulseOnUpdate: true));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('scales down instead of overflowing when wider than its space', (tester) async {
    await pumpCds(
      tester,
      const SizedBox(
        width: 120,
        child: CdsRollingNumber(value: 98765432.1, format: CdsNumberFormat.currency(), font: CdsFont.display3),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(CdsRollingNumber)).width, lessThanOrEqualTo(120));
  });
}
