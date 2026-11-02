import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _Harness extends StatefulWidget {
  const _Harness({this.disableClose = false});

  final bool disableClose;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  String? value = 'USD';

  @override
  Widget build(BuildContext context) {
    return CdsDropdown<String>(
      value: value,
      disableCloseOnOptionChange: widget.disableClose,
      onChange: (v) => setState(() => value = v),
      builder: (context, c) => CdsButton(label: 'Currency: $value', onPress: c.toggle),
      content: const [
        CdsMenuItem(value: 'USD', label: 'US Dollar'),
        CdsMenuItem(value: 'EUR', label: 'Euro'),
        CdsMenuItem(value: 'GBP', label: 'British Pound'),
        CdsMenuItem(value: 'JPY', label: 'Japanese Yen', disabled: true),
      ],
    );
  }
}

void main() {
  testWidgets('choosing an option calls onChange and closes', (tester) async {
    await pumpCds(tester, const _Harness());
    await tester.tap(find.text('Currency: USD'));
    await tester.pumpAndSettle();
    expect(find.text('Euro'), findsOneWidget);
    await tester.tap(find.text('Euro'));
    await tester.pumpAndSettle();
    expect(find.text('Currency: EUR'), findsOneWidget);
    expect(find.text('British Pound'), findsNothing);
  });

  testWidgets('selected option is marked selected with a check mark', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const _Harness());
    await tester.tap(find.text('Currency: USD'));
    await tester.pumpAndSettle();
    expect(tester.getSemantics(find.text('US Dollar')), containsSemantics(isSelected: true));
    expect(find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.checkmark), findsOneWidget);
    handle.dispose();
  });

  testWidgets('disabled options ignore taps; disableCloseOnOptionChange keeps it open', (tester) async {
    await pumpCds(tester, const _Harness(disableClose: true));
    await tester.tap(find.text('Currency: USD'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Japanese Yen'));
    await tester.pumpAndSettle();
    expect(find.text('Currency: USD'), findsOneWidget);
    await tester.tap(find.text('Euro'));
    await tester.pumpAndSettle();
    expect(find.text('Currency: EUR'), findsOneWidget);
    expect(find.text('British Pound'), findsOneWidget);
  });

  testWidgets('arrow keys move, Enter selects, Escape closes and restores focus', (tester) async {
    await pumpCds(tester, const _Harness());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final trigger = FocusManager.instance.primaryFocus;
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Currency: EUR'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus, trigger);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('British Pound'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('British Pound'), findsNothing);
    expect(FocusManager.instance.primaryFocus, trigger);
  });

  testWidgets('typeahead jumps to a matching label', (tester) async {
    await pumpCds(tester, const _Harness());
    await tester.tap(find.text('Currency: USD'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Currency: GBP'), findsOneWidget);
  });

  testWidgets('menu rows meet the 44px target at text scale 2.0', (tester) async {
    await pumpCds(tester, const _Harness(), textScale: 2);
    await tester.tap(find.text('Currency: USD'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final row = find.ancestor(of: find.text('Euro'), matching: find.byType(CdsPressable));
    expect(tester.getSize(row).height, greaterThanOrEqualTo(44));
  });
}
