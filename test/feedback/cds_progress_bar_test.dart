import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

double _fill(WidgetTester tester) =>
    tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox).first).widthFactor!;

class _Bar extends StatefulWidget {
  const _Bar();

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> {
  double progress = 0.2;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 300, child: CdsProgressBar(progress: progress, accessibilityLabel: 'Upload')),
          CdsButton(label: 'Advance', onPress: () => setState(() => progress = 0.8)),
          CdsButton(label: 'Back', onPress: () => setState(() => progress = 0.4)),
        ],
      );
}

void main() {
  testWidgets('fills from 0 on mount and reports its value', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const SizedBox(width: 300, child: CdsProgressBar(progress: 0.5, accessibilityLabel: 'Upload')), settle: false);
    expect(_fill(tester), 0);
    await tester.pumpAndSettle();
    expect(_fill(tester), closeTo(0.5, 0.001));
    expect(tester.getSemantics(find.byType(CdsProgressBar)).value, '50%');
    handle.dispose();
  });

  testWidgets('value changes animate from the current value, even mid-flight', (tester) async {
    await pumpCds(tester, const _Bar());
    expect(_fill(tester), closeTo(0.2, 0.001));
    await tester.tap(find.text('Advance'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final mid = _fill(tester);
    expect(mid, inExclusiveRange(0.2, 0.8));
    await tester.tap(find.text('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect((_fill(tester) - mid).abs(), lessThan(0.08));
    await tester.pumpAndSettle();
    expect(_fill(tester), closeTo(0.4, 0.001));
  });

  testWidgets('disableAnimateOnMount and reduced motion skip animation', (tester) async {
    await pumpCds(tester, const SizedBox(width: 300, child: CdsProgressBar(progress: 0.6, disableAnimateOnMount: true)), settle: false);
    expect(_fill(tester), closeTo(0.6, 0.001));
    await pumpCds(tester, const SizedBox(width: 300, child: CdsProgressBar(key: ValueKey(2), progress: 0.7)), disableAnimations: true, settle: false);
    await tester.pump();
    expect(_fill(tester), closeTo(0.7, 0.001));
  });

  testWidgets('weight sets the track height', (tester) async {
    await pumpCds(tester, const SizedBox(width: 300, child: CdsProgressBar(progress: 0.5, weight: CdsProgressWeight.heavy)));
    expect(tester.getSize(find.byType(CdsProgressBar)).height, 12);
  });

  testWidgets('fixed labels: beside, above and below', (tester) async {
    for (final placement in CdsProgressLabelPlacement.values) {
      await pumpCds(
        tester,
        SizedBox(
          width: 300,
          child: CdsProgressBarWithFixedLabels(
            progress: 0.3,
            startLabel: const CdsProgressBarLabel(30),
            endLabel: const CdsProgressBarLabel(100),
            labelPlacement: placement,
          ),
        ),
      );
      expect(find.text('30%'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      final barY = tester.getCenter(find.byType(CdsProgressBar)).dy;
      final labelY = tester.getCenter(find.text('30%')).dy;
      switch (placement) {
        case CdsProgressLabelPlacement.above:
          expect(labelY, lessThan(barY));
        case CdsProgressLabelPlacement.below:
          expect(labelY, greaterThan(barY));
        case CdsProgressLabelPlacement.beside:
          expect(tester.getCenter(find.text('30%')).dx, lessThan(tester.getTopLeft(find.byType(CdsProgressBar)).dx));
      }
    }
  });

  testWidgets('float label rides with the fill and uses custom render', (tester) async {
    await pumpCds(
      tester,
      const SizedBox(
        width: 300,
        child: CdsProgressBarWithFloatLabel(progress: 0.9, label: CdsProgressBarLabel(90)),
      ),
    );
    final right = tester.getTopRight(find.text('90%')).dx;
    expect(right, closeTo(tester.getTopLeft(find.byType(CdsProgressBar)).dx + 270, 1));
    await pumpCds(
      tester,
      SizedBox(
        width: 300,
        child: CdsProgressBarWithFloatLabel(
          progress: 0.6,
          label: CdsProgressBarLabel(3, render: (v, disabled) => CdsText('${v.round()} of 5 steps')),
          labelPlacement: CdsProgressLabelPlacement.below,
        ),
      ),
    );
    expect(find.text('3 of 5 steps'), findsOneWidget);
  });

  testWidgets('labels survive text scale 2.0 and dark mode', (tester) async {
    await pumpCds(
      tester,
      const SizedBox(
        width: 300,
        child: CdsProgressBarWithFixedLabels(progress: 0.5, startLabel: CdsProgressBarLabel(50), endLabel: CdsProgressBarLabel(100), disabled: true),
      ),
      textScale: 2,
      brightness: Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });
}
