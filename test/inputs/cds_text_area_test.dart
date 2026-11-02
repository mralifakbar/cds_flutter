import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _padded(Widget child) => Padding(padding: const EdgeInsets.all(16), child: child);

void main() {
  group('CdsTextArea', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _padded(const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CdsTextArea(label: 'Message', helperText: 'Optional', maxLength: 100),
              CdsTextArea(label: 'Error', helperText: 'Required', variant: CdsInputVariant.negative),
              CdsTextArea(label: 'Disabled', disabled: true),
            ],
          )),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('is multiline and respects minLines/maxLines', (tester) async {
      await pumpCds(tester, _padded(const CdsTextArea(label: 'M', minLines: 2, maxLines: 4)));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.minLines, 2);
      expect(field.maxLines, 4);
      expect(field.keyboardType, TextInputType.multiline);
    });

    testWidgets('counter tracks typed characters and turns negative at the limit', (tester) async {
      String? last;
      await pumpCds(tester, _padded(CdsTextArea(label: 'Note', maxLength: 5, onChange: (v) => last = v)));
      expect(find.text('0/5'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.text('3/5'), findsOneWidget);
      expect(last, 'abc');
      await tester.enterText(find.byType(TextField), 'abcdefgh');
      await tester.pump();
      expect(find.text('5/5'), findsOneWidget);
      expect(tester.widget<CdsText>(find.widgetWithText(CdsText, '5/5')).color, CdsColor.fgNegative);
    });

    testWidgets('value updates from outside are shown', (tester) async {
      await pumpCds(tester, _padded(const CdsTextArea(label: 'V', value: 'first', maxLength: 10)));
      await pumpCds(tester, _padded(const CdsTextArea(label: 'V', value: 'second', maxLength: 10)));
      expect(find.text('second'), findsOneWidget);
      expect(find.text('6/10'), findsOneWidget);
    });

    testWidgets('controller mode', (tester) async {
      final controller = TextEditingController(text: 'hi');
      addTearDown(controller.dispose);
      await pumpCds(tester, _padded(CdsTextArea(label: 'C', controller: controller, maxLength: 10)));
      expect(find.text('2/10'), findsOneWidget);
      controller.text = 'hello';
      await tester.pump();
      expect(find.text('5/10'), findsOneWidget);
    });

    testWidgets('counter has a readable accessibility label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _padded(const CdsTextArea(label: 'S', value: 'abc', maxLength: 10)));
      expect(find.bySemanticsLabel('3 of 10 characters'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(
        tester,
        _padded(const CdsTextArea(label: 'Message', helperText: 'Tell us what happened', maxLength: 280)),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
