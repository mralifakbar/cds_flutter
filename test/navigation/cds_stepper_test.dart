import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _steps = [
  CdsStepperStep(id: 'email', label: 'Verify email'),
  CdsStepperStep(id: 'id', label: 'Verify identity', subSteps: [
    CdsStepperStep(id: 'doc', label: 'Upload document'),
    CdsStepperStep(id: 'selfie', label: 'Take a selfie'),
  ]),
  CdsStepperStep(id: 'bank', label: 'Link a bank'),
];

Widget _stepper(CdsStepperDirection direction, String? active, {bool complete = false, bool animate = true}) => SizedBox(
      width: 320,
      child: CdsStepper(direction: direction, steps: _steps, activeStepId: active, complete: complete, animate: animate),
    );

List<double> _barFactors(WidgetTester tester) => tester
    .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
    .map((b) => b.widthFactor ?? 0)
    .toList();

void main() {
  testWidgets('renders both directions in light and dark', (tester) async {
    for (final b in Brightness.values) {
      for (final d in CdsStepperDirection.values) {
        await pumpCds(tester, _stepper(d, 'doc'), brightness: b);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('horizontal header shows position and label', (tester) async {
    await pumpCds(tester, _stepper(CdsStepperDirection.horizontal, 'id'));
    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('VERIFY IDENTITY'), findsOneWidget);
  });

  testWidgets('horizontal root announces label and position', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _stepper(CdsStepperDirection.horizontal, 'bank'));
    expect(find.bySemanticsLabel('Link a bank 5 of 5'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('vertical labels mark completed and active steps', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _stepper(CdsStepperDirection.vertical, 'doc'));
    expect(find.bySemanticsLabel('Verify email (Complete) 1 of 5'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Upload document 3 of 5').first),
      containsSemantics(isSelected: true),
    );
    expect(find.bySemanticsLabel('Link a bank 5 of 5'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('bars cascade one step at a time and the timer stops', (tester) async {
    await pumpCds(tester, _stepper(CdsStepperDirection.horizontal, 'bank'), settle: false);
    await tester.pump();
    // First bar starts filling immediately; the third waits two staggers.
    await tester.pump(CdsDurations.slow2);
    await tester.pumpAndSettle();
    expect(_barFactors(tester).where((f) => f == 1).length, greaterThanOrEqualTo(3));
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('reduced motion fills instantly with no running tickers', (tester) async {
    await pumpCds(tester, _stepper(CdsStepperDirection.vertical, 'bank'), disableAnimations: true, settle: false);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('complete fills every bar and hides the header text', (tester) async {
    await pumpCds(tester, _stepper(CdsStepperDirection.horizontal, 'bank', complete: true, animate: false));
    expect(find.text('5/5'), findsNothing);
    expect(_barFactors(tester).every((f) => f == 1), isTrue);
  });

  testWidgets('changing the active step cross-fades the header', (tester) async {
    await pumpCds(tester, _stepper(CdsStepperDirection.horizontal, 'email'));
    await pumpCds(tester, _stepper(CdsStepperDirection.horizontal, 'bank'));
    expect(find.text('5/5'), findsOneWidget);
    expect(find.text('1/5'), findsNothing);
  });

  testWidgets('RTL and text scale 2 do not overflow', (tester) async {
    for (final d in CdsStepperDirection.values) {
      await pumpCds(tester, _stepper(d, 'selfie'), textDirection: TextDirection.rtl, textScale: 2);
      expect(tester.takeException(), isNull);
    }
  });
}
