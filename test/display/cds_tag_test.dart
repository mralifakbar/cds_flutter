import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  group('CdsTag', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every intent, emphasis and color in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Wrap(children: [
            for (final intent in CdsTagIntent.values)
              for (final emphasis in CdsTagEmphasis.values)
                for (final scheme in CdsTagColorScheme.values)
                  CdsTag('Tag', intent: intent, emphasis: emphasis, colorScheme: scheme, startIcon: CdsIconName.info, endIcon: CdsIconName.caretRight),
          ]),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('uses tagEmphasisColorMap spectrum steps', (tester) async {
      await pumpCds(tester, const CdsTag('Pending', colorScheme: CdsTagColorScheme.yellow));
      final spectrum = CdsThemeData.light.spectrum;
      final box = tester.widget<DecoratedBox>(find.descendant(of: find.byType(CdsTag), matching: find.byType(DecoratedBox)).first);
      expect((box.decoration as BoxDecoration).color, spectrum.of(CdsHue.yellow, 0));
      expect(tester.widget<Text>(find.text('Pending')).style!.color, spectrum.of(CdsHue.yellow, 70));
    });

    testWidgets('promotional defaults to high emphasis, uppercase caption and a pill', (tester) async {
      await pumpCds(tester, const CdsTag('New', intent: CdsTagIntent.promotional));
      expect(find.text('NEW'), findsOneWidget);
      final box = tester.widget<DecoratedBox>(find.descendant(of: find.byType(CdsTag), matching: find.byType(DecoratedBox)).first);
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.color, CdsThemeData.light.spectrum.of(CdsHue.blue, 60));
      expect(decoration.borderRadius, BorderRadius.circular(100000));
    });

    testWidgets('screen readers hear the original text', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const CdsTag('New', intent: CdsTagIntent.promotional));
      expect(find.bySemanticsLabel('New'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('truncates past maxWidth', (tester) async {
      await pumpCds(tester, const CdsTag('A very long tag label that will not fit', maxWidth: 80));
      expect(tester.getSize(find.byType(CdsTag)).width, lessThanOrEqualTo(80));
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(tester, const CdsTag('Verified', startIcon: CdsIconName.circleCheckmark), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
