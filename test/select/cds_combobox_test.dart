import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _countries = [
  CdsSelectOption(value: 'us', label: 'United States'),
  CdsSelectOption(value: 'gb', label: 'United Kingdom'),
  CdsSelectOption(value: 'de', label: 'Germany'),
  CdsSelectOption(value: 'fr', label: 'France'),
];

class _Combo extends StatefulWidget {
  const _Combo({this.presentation = CdsSelectPresentation.dropdown, this.filter});

  final CdsSelectPresentation presentation;
  final CdsComboboxFilter<String>? filter;

  @override
  State<_Combo> createState() => _ComboState();
}

class _ComboState extends State<_Combo> {
  String? value;
  String search = '';

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 320,
        child: CdsCombobox<String>(
          label: 'Country',
          placeholder: 'Choose a country',
          presentation: widget.presentation,
          filterFunction: widget.filter,
          onSearch: (s) => search = s,
          value: value,
          onChange: (v) => setState(() => value = v),
          options: _countries,
        ),
      );
}

void main() {
  testWidgets('typing filters the options and a pick closes', (tester) async {
    await pumpCds(tester, const _Combo());
    await tester.tap(find.text('Choose a country'));
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'united');
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsNothing);
    expect(find.text('United Kingdom'), findsOneWidget);
    await tester.tap(find.text('United Kingdom'));
    await tester.pumpAndSettle();
    expect(find.text('United Kingdom'), findsOneWidget);
    expect(find.byType(EditableText), findsNothing);
    expect(tester.state<State<_Combo>>(find.byType(_Combo)), isA<_ComboState>());
  });

  testWidgets('no matches shows the empty label; clear restores', (tester) async {
    await pumpCds(tester, const _Combo());
    await tester.tap(find.text('Choose a country'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No options available'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('France'), findsOneWidget);
  });

  testWidgets('custom filter and tray presentation', (tester) async {
    await pumpCds(
      tester,
      _Combo(
        presentation: CdsSelectPresentation.tray,
        filter: (options, q) => [for (final o in options) if (o.value.startsWith(q)) o],
      ),
    );
    await tester.tap(find.text('Choose a country'));
    await tester.pumpAndSettle();
    expect(find.byType(CdsTray), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'f');
    await tester.pumpAndSettle();
    expect(find.text('France'), findsOneWidget);
    expect(find.text('Germany'), findsNothing);
  });

  test('default filter matches label and description, ignoring case', () {
    const opts = [CdsSelectOption(value: 1, label: 'Bitcoin', description: 'BTC'), CdsSelectOption(value: 2, label: 'Ether')];
    expect(cdsDefaultComboboxFilter(opts, 'btc').single.value, 1);
    expect(cdsDefaultComboboxFilter(opts, 'ETH').single.value, 2);
    expect(cdsDefaultComboboxFilter(opts, ''), opts);
  });
}
