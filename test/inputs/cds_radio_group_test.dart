import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _options = [
  CdsControlOption(value: 'bank', label: 'Bank account'),
  CdsControlOption(value: 'card', label: 'Debit card'),
  CdsControlOption(value: 'gift', label: 'Gift card', disabled: true),
  CdsControlOption(value: 'wire', label: 'Wire transfer'),
];

class _Group extends StatefulWidget {
  const _Group({this.initial, this.direction = Axis.vertical});

  final String? initial;
  final Axis direction;

  @override
  State<_Group> createState() => _GroupState();
}

class _GroupState extends State<_Group> {
  late String? value = widget.initial;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CdsButton(label: 'Before', onPress: () {}),
          CdsRadioGroup<String>(
            label: 'Payment method',
            options: _options,
            value: value,
            direction: widget.direction,
            onChange: (v) => setState(() => value = v),
          ),
          CdsButton(label: 'After', onPress: () {}),
        ],
      );
}

bool _isFocused(WidgetTester tester, String label) {
  final node = Focus.of(tester.element(find.text(label)));
  return node.hasPrimaryFocus || node.hasFocus;
}

String? _value(WidgetTester tester) => tester.state<_GroupState>(find.byType(_Group)).value;

void main() {
  group('CdsRadioGroup', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(tester, const _Group(initial: 'card'), brightness: brightness);
        expect(tester.takeException(), isNull);
        expect(find.text('Payment method'), findsOneWidget);
      });
    }

    testWidgets('tapping an option selects it; disabled options do not', (tester) async {
      await pumpCds(tester, const _Group());
      await tester.tap(find.text('Debit card'));
      await tester.pump();
      expect(_value(tester), 'card');
      await tester.tap(find.text('Gift card'));
      await tester.pump();
      expect(_value(tester), 'card');
    });

    testWidgets('arrow keys move selection, skip disabled options and wrap', (tester) async {
      await pumpCds(tester, const _Group(initial: 'card'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // Before
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // group: selected option
      await tester.pump();
      expect(_isFocused(tester, 'Debit card'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(_value(tester), 'wire');
      expect(_isFocused(tester, 'Wire transfer'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(_value(tester), 'bank');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(_value(tester), 'wire');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(_value(tester), 'card');
    });

    testWidgets('the group is a single tab stop', (tester) async {
      await pumpCds(tester, const _Group(initial: 'bank'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // Before
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // Bank account
      await tester.pump();
      expect(_isFocused(tester, 'Bank account'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // After
      await tester.pump();
      expect(_isFocused(tester, 'After'), isTrue);
    });

    testWidgets('with no selection, Tab lands on the first enabled option', (tester) async {
      await pumpCds(tester, const _Group());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_isFocused(tester, 'Bank account'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(_value(tester), 'bank');
    });

    testWidgets('right-to-left mirrors left and right', (tester) async {
      await pumpCds(tester, const _Group(initial: 'bank', direction: Axis.horizontal),
          textDirection: TextDirection.rtl);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(_value(tester), 'card');
    });

    testWidgets('semantics: radio group role with label and position template', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        CdsRadioGroup<String>(
          label: 'Speed',
          options: const [
            CdsControlOption(value: 'a', label: 'Standard'),
            CdsControlOption(value: 'b', label: 'Instant'),
          ],
          value: 'a',
          onChange: (_) {},
          radioSemanticLabel: '{{number}} of {{total}}',
        ),
      );
      expect(find.bySemanticsLabel('Standard. 1 of 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Instant. 2 of 2'), findsOneWidget);
      final group = tester.getSemantics(find.byType(CdsControlGroup<String>));
      expect(group.label, 'Speed');
      expect(group.getSemanticsData().role, SemanticsRole.radioGroup);
      handle.dispose();
    });

    testWidgets('text scale 2.0 horizontal wraps without overflow', (tester) async {
      await pumpCds(tester, const SizedBox(width: 320, child: _Group(direction: Axis.horizontal)), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
