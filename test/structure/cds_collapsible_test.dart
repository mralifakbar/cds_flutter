import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _toggle({required bool collapsed, Axis direction = Axis.vertical, double? maxHeight}) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CdsCollapsible(
          collapsed: collapsed,
          direction: direction,
          maxHeight: maxHeight,
          child: const SizedBox(key: Key('content'), width: 200, height: 120, child: CdsText('Details')),
        ),
      ],
    );

double _visibleHeight(WidgetTester tester) => tester.getSize(find.byType(CdsCollapsible)).height;

void main() {
  testWidgets('renders in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, _toggle(collapsed: false), brightness: b);
      expect(tester.takeException(), isNull);
      expect(_visibleHeight(tester), 120);
    }
  });

  testWidgets('starts expanded without animating', (tester) async {
    await pumpCds(tester, _toggle(collapsed: false), settle: false);
    expect(_visibleHeight(tester), 120);
  });

  testWidgets('collapses to zero and hides content from semantics', (tester) async {
    await pumpCds(tester, _toggle(collapsed: false));
    await pumpCds(tester, _toggle(collapsed: true));
    expect(_visibleHeight(tester), 0);
    expect(find.bySemanticsLabel('Details'), findsNothing);
  });

  testWidgets('reverses mid-flight from the current height', (tester) async {
    await pumpCds(tester, _toggle(collapsed: true));
    await pumpCds(tester, _toggle(collapsed: false), settle: false);
    await tester.pump(const Duration(milliseconds: 175));
    final mid = _visibleHeight(tester);
    expect(mid, greaterThan(0));
    expect(mid, lessThan(120));
    await pumpCds(tester, _toggle(collapsed: true), settle: false);
    await tester.pump(const Duration(milliseconds: 16));
    final afterReverse = _visibleHeight(tester);
    expect((afterReverse - mid).abs(), lessThan(20));
    await tester.pumpAndSettle();
    expect(_visibleHeight(tester), 0);
  });

  testWidgets('reduced motion changes instantly', (tester) async {
    await pumpCds(tester, _toggle(collapsed: true), disableAnimations: true);
    await pumpCds(tester, _toggle(collapsed: false), disableAnimations: true, settle: false);
    await tester.pump();
    expect(_visibleHeight(tester), 120);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('maxHeight caps the expanded size', (tester) async {
    await pumpCds(tester, _toggle(collapsed: false, maxHeight: 50));
    expect(_visibleHeight(tester), 50);
  });

  testWidgets('horizontal direction animates width', (tester) async {
    await pumpCds(tester, _toggle(collapsed: false, direction: Axis.horizontal));
    expect(tester.getSize(find.byType(CdsCollapsible)).width, 200);
    await pumpCds(tester, _toggle(collapsed: true, direction: Axis.horizontal));
    expect(tester.getSize(find.byType(CdsCollapsible)).width, 0);
  });

  testWidgets('text scale 2.0 does not overflow', (tester) async {
    await pumpCds(tester, const CdsCollapsible(collapsed: false, padding: 2, child: CdsText('Network fees vary.')), textScale: 2);
    expect(tester.takeException(), isNull);
  });
}
