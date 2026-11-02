import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('small and large sizes, labeled Loading', (tester) async {
    await pumpCds(tester, const CdsSpinner(), settle: false);
    expect(tester.getSize(find.byType(CdsSpinner)), const Size(20, 20));
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    await pumpCds(tester, const CdsSpinner(size: CdsSpinnerSize.large), settle: false);
    expect(tester.getSize(find.byType(CdsSpinner)), const Size(36, 36));
  });

  testWidgets('spins only while shown; static under reduced motion', (tester) async {
    await pumpCds(tester, const CdsSpinner(), settle: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await pumpCds(tester, const CdsSpinner(key: ValueKey(1)), disableAnimations: true, settle: false);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('animating false keeps space without a spinner', (tester) async {
    await pumpCds(tester, const CdsSpinner(animating: false));
    expect(find.byType(CdsProgressCircle), findsNothing);
    expect(tester.getSize(find.byType(CdsSpinner)), const Size(20, 20));
  });
}
