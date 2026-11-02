import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _TourHarness extends StatefulWidget {
  const _TourHarness();

  @override
  State<_TourHarness> createState() => _TourHarnessState();
}

class _TourHarnessState extends State<_TourHarness> {
  String? step;

  CdsTourStepValue _step(String id, String title) => CdsTourStepValue(
        id: id,
        builder: (context, tour) => CdsCoachmark(
          title: title,
          content: 'Sample data: $title',
          action: CdsButton(label: 'Next', size: CdsButtonSize.s, onPress: tour.goNextTourStep),
          onClose: tour.stopTour,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CdsTour(
      activeTourStep: step,
      onChange: (id) => setState(() => step = id),
      steps: [_step('balance', 'Your balance'), _step('send', 'Send crypto')],
      child: Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CdsButton(label: 'Start tour', onPress: () => CdsTour.of(context).startTour()),
            const SizedBox(height: 40),
            const CdsTourStep(id: 'balance', child: CdsText('Balance card')),
            const SizedBox(height: 120),
            const CdsTourStep(id: 'send', child: CdsText('Send button')),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('steps through coachmarks with a spotlight and ends', (tester) async {
    await pumpCds(tester, const _TourHarness());
    await tester.tap(find.text('Start tour'));
    await tester.pumpAndSettle();
    expect(find.text('Your balance'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Your balance')).dy,
      greaterThan(tester.getBottomLeft(find.text('Balance card')).dy),
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your balance'), findsNothing);
    expect(find.text('Send crypto'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Send crypto'), findsNothing);
  });

  testWidgets('the mask blocks taps on the page; close and Escape stop the tour', (tester) async {
    await pumpCds(tester, const _TourHarness());
    await tester.tap(find.text('Start tour'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start tour'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Your balance'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Your balance'), findsNothing);

    await tester.tap(find.text('Start tour'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Your balance'), findsNothing);
  });

  testWidgets('coachmark renders on the inverted scheme and scales text', (tester) async {
    await pumpCds(
      tester,
      CdsCoachmark(title: 'Recurring buys', content: 'Buy a fixed amount every week.', onClose: () {}),
      textScale: 2,
    );
    expect(tester.element(find.text('Recurring buys')).cds.isDark, isTrue);
    expect(tester.takeException(), isNull);
  });
}
