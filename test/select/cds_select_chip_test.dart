import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _Chip extends StatefulWidget {
  const _Chip();

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
  String? value;

  @override
  Widget build(BuildContext context) => CdsSelectChip<String>(
        placeholder: 'All assets',
        presentation: CdsSelectPresentation.dropdown,
        value: value,
        onChange: (v) => setState(() => value = v),
        options: const [
          CdsSelectOption(value: 'gainers', label: 'Top gainers'),
          CdsSelectOption(value: 'losers', label: 'Top losers'),
        ],
      );
}

void main() {
  testWidgets('shows the placeholder, then the picked label on an inverted chip', (tester) async {
    await pumpCds(tester, const _Chip());
    expect(find.text('All assets'), findsOneWidget);
    expect(tester.element(find.text('All assets')).cds.isDark, isFalse);
    await tester.tap(find.text('All assets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Top gainers'));
    await tester.pumpAndSettle();
    expect(find.text('Top gainers'), findsOneWidget);
    expect(tester.element(find.text('Top gainers')).cds.isDark, isTrue);
  });

  testWidgets('chip hit target is at least 44px and labeled', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const _Chip());
    expect(tester.getSize(find.byType(CdsPressable).first).height, greaterThanOrEqualTo(44));
    expect(find.bySemanticsLabel('All assets'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('multi chip summarizes picks', (tester) async {
    var value = <String>['a', 'b', 'c'];
    await pumpCds(
      tester,
      StatefulBuilder(
        builder: (context, setState) => CdsSelectChip<String>.multi(
          placeholder: 'Assets',
          value: value,
          onChange: (v) => setState(() => value = v),
          options: const [
            CdsSelectOption(value: 'a', label: 'Bitcoin'),
            CdsSelectOption(value: 'b', label: 'Ether'),
            CdsSelectOption(value: 'c', label: 'Solana'),
          ],
        ),
      ),
    );
    expect(find.text('Bitcoin, Ether +1 more'), findsOneWidget);
  });
}
