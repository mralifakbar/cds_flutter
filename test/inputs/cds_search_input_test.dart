import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _padded(Widget child) => Padding(padding: const EdgeInsets.all(16), child: child);

class _Host extends StatefulWidget {
  const _Host({this.onSearch, this.onClear});

  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String query = '';

  @override
  Widget build(BuildContext context) => CdsSearchInput(
        value: query,
        onChange: (v) => setState(() => query = v),
        onSearch: widget.onSearch,
        onClear: widget.onClear,
      );
}

bool _hasIcon(WidgetTester tester, CdsIconName name) =>
    find.byWidgetPredicate((w) => w is CdsIcon && w.name == name).evaluate().isNotEmpty;

void main() {
  group('CdsSearchInput', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _padded(const Column(
            mainAxisSize: MainAxisSize.min,
            children: [CdsSearchInput(value: 'BTC'), CdsSearchInput(disabled: true), CdsSearchInput(compact: true)],
          )),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('uses the secondary variant and a pill radius', (tester) async {
      await pumpCds(tester, _padded(const CdsSearchInput()));
      final input = tester.widget<CdsTextInput>(find.byType(CdsTextInput));
      expect(input.variant, CdsInputVariant.secondary);
      expect(input.borderRadius, 1000);
      expect(tester.widget<TextField>(find.byType(TextField)).textInputAction, TextInputAction.search);
    });

    testWidgets('start icon turns into a back arrow while focused; back blurs', (tester) async {
      var back = 0;
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpCds(tester, _padded(CdsSearchInput(focusNode: node, onBack: () => back++)));
      expect(_hasIcon(tester, CdsIconName.search), isTrue);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(_hasIcon(tester, CdsIconName.backArrow), isTrue);
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(back, 1);
      expect(node.hasFocus, isFalse);
      expect(_hasIcon(tester, CdsIconName.search), isTrue);
    });

    testWidgets('disableBackArrow keeps the search icon', (tester) async {
      await pumpCds(tester, _padded(const CdsSearchInput(disableBackArrow: true)));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(_hasIcon(tester, CdsIconName.backArrow), isFalse);
    });

    testWidgets('hideStartIcon removes the start icon', (tester) async {
      await pumpCds(tester, _padded(const CdsSearchInput(hideStartIcon: true)));
      expect(_hasIcon(tester, CdsIconName.search), isFalse);
    });

    testWidgets('clear button appears with text and clears, refocuses, reports empty search', (tester) async {
      final searches = <String>[];
      var cleared = 0;
      await pumpCds(tester, _padded(_Host(onSearch: searches.add, onClear: () => cleared++)));
      expect(find.bySemanticsLabel('Clear text'), findsNothing);
      await tester.enterText(find.byType(TextField), 'eth');
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Clear text'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Clear text'));
      await tester.pumpAndSettle();
      expect(cleared, 1);
      expect(searches, ['']);
      expect(find.text('eth'), findsNothing);
      expect(find.bySemanticsLabel('Clear text'), findsNothing);
      expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus, isTrue);
    });

    testWidgets('hideEndIcon hides the clear button', (tester) async {
      await pumpCds(tester, _padded(const CdsSearchInput(value: 'x', hideEndIcon: true)));
      expect(find.bySemanticsLabel('Clear text'), findsNothing);
    });

    testWidgets('submitting calls onSearch with the query', (tester) async {
      final searches = <String>[];
      await pumpCds(tester, _padded(_Host(onSearch: searches.add)));
      await tester.enterText(find.byType(TextField), 'sol');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(searches, ['sol']);
    });

    testWidgets('field is labeled by its placeholder for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _padded(const CdsSearchInput(placeholder: 'Search assets')));
      final node = tester.getSemantics(find.byType(TextField));
      expect(node.label, contains('Search assets'));
      expect(node.flagsCollection.isTextField, isTrue);
      handle.dispose();
    });

    testWidgets('keyboard: Tab reaches the field', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpCds(tester, _padded(CdsSearchInput(focusNode: node, hideStartIcon: true)));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, _padded(const CdsSearchInput(value: 'Bitcoin')), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
