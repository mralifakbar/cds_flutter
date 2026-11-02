import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _items = [
  CdsAccordionItem(itemKey: 'fees', title: 'Fees', subtitle: 'Per trade', child: CdsText('Fees body')),
  CdsAccordionItem(itemKey: 'limits', title: 'Limits', child: CdsText('Limits body')),
  CdsAccordionItem(itemKey: 'tax', title: 'Taxes', child: CdsText('Taxes body')),
];

double _panelHeight(WidgetTester tester, int index) =>
    tester.getSize(find.byType(CdsCollapsible).at(index)).height;

void main() {
  testWidgets('renders in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, const CdsAccordion(children: _items), brightness: b);
      expect(tester.takeException(), isNull);
      expect(find.text('Fees'), findsOneWidget);
    }
  });

  testWidgets('uncontrolled: opens defaultActiveKey and toggles on tap, one at a time', (tester) async {
    await pumpCds(tester, const CdsAccordion(defaultActiveKey: 'fees', children: _items));
    expect(_panelHeight(tester, 0), greaterThan(0));
    expect(_panelHeight(tester, 1), 0);

    await tester.tap(find.text('Limits'));
    await tester.pumpAndSettle();
    expect(_panelHeight(tester, 0), 0);
    expect(_panelHeight(tester, 1), greaterThan(0));

    await tester.tap(find.text('Limits'));
    await tester.pumpAndSettle();
    expect(_panelHeight(tester, 1), 0);
  });

  testWidgets('controlled: reports next key and reflects activeKey', (tester) async {
    String? reported = 'unset';
    final pressed = <String>[];
    await pumpCds(
      tester,
      CdsAccordion(
        activeKey: 'limits',
        onChange: (k) => reported = k,
        children: [
          CdsAccordionItem(itemKey: 'fees', title: 'Fees', onPress: pressed.add, child: const CdsText('a')),
          const CdsAccordionItem(itemKey: 'limits', title: 'Limits', child: CdsText('b')),
        ],
      ),
    );
    expect(_panelHeight(tester, 1), greaterThan(0));
    await tester.tap(find.text('Fees'));
    await tester.pumpAndSettle();
    expect(reported, 'fees');
    expect(pressed, ['fees']);
    // Still controlled by activeKey, so nothing moved.
    expect(_panelHeight(tester, 0), 0);

    await tester.tap(find.text('Limits'));
    expect(reported, isNull);
  });

  testWidgets('header exposes button, expanded state and joined label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const CdsAccordion(defaultActiveKey: 'fees', children: _items));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Fees, Per trade')),
      matchesSemantics(
        label: 'Fees, Per trade',
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasFocusAction: true,
        hasExpandedState: true,
        isExpanded: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Limits')),
      matchesSemantics(
        label: 'Limits',
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasFocusAction: true,
        hasExpandedState: true,
        isExpanded: false,
      ),
    );
    expect(find.bySemanticsLabel('Limits body'), findsNothing);
    handle.dispose();
  });

  testWidgets('keyboard: Enter toggles, arrows move between headers', (tester) async {
    await pumpCds(tester, const CdsAccordion(children: _items));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_panelHeight(tester, 0), greaterThan(0));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(_panelHeight(tester, 1), greaterThan(0));

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_panelHeight(tester, 2), greaterThan(0));

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    // Up from the first header wraps to the last, which closes it.
    expect(_panelHeight(tester, 2), 0);
  });

  testWidgets('caret rotates between collapsed and expanded', (tester) async {
    await pumpCds(tester, const CdsAccordion(children: _items));
    final rotation = find.byType(AnimatedRotation).first;
    expect(tester.widget<AnimatedRotation>(rotation).turns, -0.5);
    await tester.tap(find.text('Fees'));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedRotation>(rotation).turns, 0);
  });

  testWidgets('reduced motion: no running animations after toggling', (tester) async {
    await pumpCds(tester, const CdsAccordion(children: _items), disableAnimations: true);
    await tester.tap(find.text('Fees'));
    await tester.pump();
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(_panelHeight(tester, 0), greaterThan(0));
  });

  testWidgets('text scale 2.0, RTL, media and header border render', (tester) async {
    await pumpCds(
      tester,
      const CdsAccordion(
        defaultActiveKey: 'a',
        borderRadius: 400,
        children: [
          CdsAccordionItem(
            itemKey: 'a',
            title: 'Staking rewards and how they are calculated',
            subtitle: 'Paid weekly',
            tertiaryTitle: 'Variable rate',
            media: CdsIcon(CdsIconName.info),
            showHeaderBorder: true,
            borderRadius: 400,
            child: CdsText('Rewards depend on network conditions.'),
          ),
        ],
      ),
      textScale: 2,
      textDirection: TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });
}
