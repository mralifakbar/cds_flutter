import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _crumbs({int? maxItems, ValueChanged<String>? onPress}) => SizedBox(
      width: 360,
      child: CdsBreadcrumb(
        maxItems: maxItems,
        items: [
          for (final label in ['Home', 'Assets', 'Bitcoin', 'Wallets'])
            CdsBreadcrumbItem(label: label, onPress: () => onPress?.call(label)),
          const CdsBreadcrumbItem(label: 'Transactions'),
        ],
      ),
    );

void main() {
  testWidgets('renders in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, _crumbs(), brightness: b);
      expect(tester.takeException(), isNull);
      expect(find.byType(CdsIcon), findsNWidgets(4));
    }
  });

  testWidgets('earlier items call onPress, the current page is not pressable', (tester) async {
    final pressed = <String>[];
    await pumpCds(tester, _crumbs(onPress: pressed.add));
    await tester.tap(find.text('Assets'));
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(pressed, ['Assets']);
  });

  testWidgets('semantics: group label, links are buttons, current page is selected', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, _crumbs());
    expect(find.bySemanticsLabel('Breadcrumb'), findsOneWidget);
    expect(tester.getSemantics(find.text('Assets')), containsSemantics(label: 'Assets', isButton: true));
    expect(tester.getSemantics(find.text('Transactions')), containsSemantics(label: 'Transactions', isSelected: true, isButton: false));
    handle.dispose();
  });

  testWidgets('maxItems collapses the middle and expands on press', (tester) async {
    await pumpCds(tester, _crumbs(maxItems: 3));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Assets'), findsNothing);
    expect(find.text('Bitcoin'), findsNothing);
    expect(find.text('Wallets'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    await tester.tap(find.text('...'));
    await tester.pumpAndSettle();
    expect(find.text('Assets'), findsOneWidget);
  });

  testWidgets('separators mirror in RTL', (tester) async {
    await pumpCds(tester, _crumbs(), textDirection: TextDirection.rtl);
    expect(tester.widget<CdsIcon>(find.byType(CdsIcon).first).name, CdsIconName.caretLeft);
  });

  testWidgets('wraps at text scale 2 without overflow and has 44px targets', (tester) async {
    await pumpCds(tester, _crumbs(), textScale: 2);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(CdsPressable).first).height, greaterThanOrEqualTo(44));
  });
}
