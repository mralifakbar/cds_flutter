import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('static by default: no running animation', (tester) async {
    await pumpCds(tester, const CdsFallback(width: 150, height: 24));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
  });

  testWidgets('rectWidthVariant gives a deterministic width within 25%', (tester) async {
    await pumpCds(tester, const CdsFallback(width: 100, height: 20, rectWidthVariant: 3));
    final w = tester.getSize(find.byType(CdsFallback)).width;
    expect(w, inInclusiveRange(75, 125));
    await pumpCds(tester, const CdsFallback(key: ValueKey('b'), width: 100, height: 20, rectWidthVariant: 3));
    expect(tester.getSize(find.byType(CdsFallback)).width, w);
  });

  testWidgets('disableRandomRectWidth keeps the exact width; circle is round', (tester) async {
    await pumpCds(tester, const CdsFallback(width: 120, height: 20, disableRandomRectWidth: true));
    expect(tester.getSize(find.byType(CdsFallback)).width, 120);
    await pumpCds(tester, const CdsFallback(width: 40, height: 40, shape: CdsFallbackShape.circle));
    expect(tester.getSize(find.byType(CdsFallback)), const Size(40, 40));
  });

  testWidgets('shimmer runs a bounded number of sweeps, then stops', (tester) async {
    await pumpCds(tester, const CdsFallback(width: 150, height: 24, shimmer: true), settle: false);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump(const Duration(seconds: 14));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('shimmer is off under reduced motion; works in dark', (tester) async {
    await pumpCds(tester, const CdsFallback(width: 150, height: 24, shimmer: true), disableAnimations: true, brightness: Brightness.dark, settle: false);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
