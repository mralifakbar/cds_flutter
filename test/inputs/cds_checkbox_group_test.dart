import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _options = [
  CdsControlOption(value: 'btc', label: 'Bitcoin'),
  CdsControlOption(value: 'eth', label: 'Ethereum'),
  CdsControlOption(value: 'sol', label: 'Solana', readOnly: true),
];

class _Group extends StatefulWidget {
  const _Group();

  @override
  State<_Group> createState() => _GroupState();
}

class _GroupState extends State<_Group> {
  Set<String> values = {'btc'};

  @override
  Widget build(BuildContext context) => CdsCheckboxGroup<String>(
        label: 'Assets',
        options: _options,
        selectedValues: values,
        onChange: (next) => setState(() => values = next),
      );
}

void main() {
  group('CdsCheckboxGroup', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(tester, const _Group(), brightness: brightness);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('toggling updates the controlled set', (tester) async {
      await pumpCds(tester, const _Group());
      await tester.tap(find.text('Ethereum'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bitcoin'));
      await tester.pumpAndSettle();
      expect(tester.state<_GroupState>(find.byType(_Group)).values, {'eth'});
    });

    testWidgets('read-only option is announced and does not toggle', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const _Group());
      await tester.tap(find.text('Solana'));
      await tester.pumpAndSettle();
      expect(tester.state<_GroupState>(find.byType(_Group)).values, {'btc'});
      expect(tester.getSemantics(find.text('Solana')), containsSemantics(isReadOnly: true, hasTapAction: false));
      handle.dispose();
    });

    testWidgets('checked state is exposed per option', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, const _Group());
      expect(tester.getSemantics(find.text('Bitcoin')), containsSemantics(isChecked: true));
      expect(tester.getSemantics(find.text('Ethereum')), containsSemantics(isChecked: false));
      handle.dispose();
    });

    testWidgets('text scale 2.0 and reduced motion', (tester) async {
      await pumpCds(tester, const _Group(), textScale: 2, disableAnimations: true);
      await tester.tap(find.text('Ethereum'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
