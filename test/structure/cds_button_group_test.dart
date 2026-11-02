import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('horizontal group keeps natural widths with an 8px gap', (tester) async {
    await pumpCds(
      tester,
      CdsButtonGroup(children: [
        CdsButton(label: 'Sell', onPress: () {}),
        CdsButton(label: 'Buy', onPress: () {}),
      ]),
    );
    final sell = tester.getRect(find.byType(CdsButton).first);
    final buy = tester.getRect(find.byType(CdsButton).last);
    expect(buy.left - sell.right, 8);
  });

  testWidgets('block shares the width equally and stretches buttons', (tester) async {
    var bought = 0;
    await pumpCds(
      tester,
      SizedBox(
        width: 300,
        child: CdsButtonGroup(block: true, children: [
          CdsButton(label: 'Sell', variant: CdsButtonVariant.secondary, onPress: () {}),
          CdsButton(label: 'Buy', onPress: () => bought++),
        ]),
      ),
    );
    expect(tester.getSize(find.byType(CdsPressable).first).width, 146);
    await tester.tap(find.text('Buy'));
    expect(bought, 1);
  });

  testWidgets('vertical group stretches every button', (tester) async {
    await pumpCds(
      tester,
      SizedBox(
        width: 300,
        child: CdsButtonGroup(direction: Axis.vertical, accessibilityLabel: 'Order actions', children: [
          CdsButton(label: 'Sell', onPress: () {}),
          const SizedBox(key: Key('other'), height: 10),
        ]),
      ),
    );
    expect(tester.getSize(find.byType(CdsPressable)).width, 300);
    expect(tester.getSize(find.byKey(const Key('other'))).width, 300);
    expect(find.bySemanticsLabel('Order actions'), findsOneWidget);
  });

  testWidgets('dark theme and text scale 2.0', (tester) async {
    await pumpCds(
      tester,
      SizedBox(
        width: 300,
        child: CdsButtonGroup(block: true, children: [
          CdsButton(label: 'Sell', onPress: () {}),
          CdsButton(label: 'Buy', onPress: () {}),
        ]),
      ),
      brightness: Brightness.dark,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
