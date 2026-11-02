import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _AmountHost extends StatefulWidget {
  const _AmountHost();

  @override
  State<_AmountHost> createState() => _AmountHostState();
}

class _AmountHostState extends State<_AmountHost> {
  String amount = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: CdsNumpad(
        accessory: CdsText(amount.isEmpty ? 'empty' : 'amount $amount'),
        onPress: (key) => setState(() => amount = CdsNumpad.apply(amount, key, maxDecimals: 2)),
        onClear: () => setState(() => amount = ''),
      ),
    );
  }
}

Finder _key(String label) => find.bySemanticsLabel(label);

void main() {
  group('CdsNumpad.apply', () {
    test('amount entry rules', () {
      expect(CdsNumpad.apply('', const CdsNumpadKey.digit(1)), '1');
      expect(CdsNumpad.apply('0', const CdsNumpadKey.digit(5)), '5');
      expect(CdsNumpad.apply('0', const CdsNumpadKey.digit(0)), '0');
      expect(CdsNumpad.apply('', CdsNumpadKey.separator), '0.');
      expect(CdsNumpad.apply('12', CdsNumpadKey.separator), '12.');
      expect(CdsNumpad.apply('1.2', CdsNumpadKey.separator), '1.2');
      expect(CdsNumpad.apply('1.25', const CdsNumpadKey.digit(1), maxDecimals: 2), '1.25');
      expect(CdsNumpad.apply('12', CdsNumpadKey.separator, maxDecimals: 0), '12');
      expect(CdsNumpad.apply('123', const CdsNumpadKey.digit(4), maxLength: 3), '123');
      expect(CdsNumpad.apply('12', CdsNumpadKey.delete), '1');
      expect(CdsNumpad.apply('', CdsNumpadKey.delete), '');
      expect(CdsNumpad.apply('1', CdsNumpadKey.separator, separator: ','), '1,');
      expect(CdsNumpad.apply('1', CdsNumpadKey.separator, separator: ''), '1');
    });

    test('keys compare by value and switch exhaustively', () {
      expect(const CdsNumpadKey.digit(3), const CdsNumpadDigit(3));
      expect(CdsNumpadKey.delete, const CdsNumpadDelete());
      String describe(CdsNumpadKey k) => switch (k) {
            CdsNumpadDigit(:final value) => '$value',
            CdsNumpadSeparator() => 'sep',
            CdsNumpadDelete() => 'del',
          };
      expect(describe(CdsNumpadKey.separator), 'sep');
    });
  });

  group('CdsNumpad', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(tester, const _AmountHost(), brightness: brightness);
        expect(tester.takeException(), isNull);
        for (var i = 0; i <= 9; i++) {
          expect(find.text('$i'), findsOneWidget);
        }
        expect(find.text('.'), findsOneWidget);
      });
    }

    testWidgets('pressing keys builds an amount', (tester) async {
      await pumpCds(tester, const _AmountHost());
      for (final label in ['1', '2', 'period', '5']) {
        await tester.tap(_key(label));
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(find.text('amount 12.5'), findsOneWidget);
      await tester.tap(_key('delete'));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('amount 12.'), findsOneWidget);
    });

    testWidgets('long-press on delete clears', (tester) async {
      await pumpCds(tester, const _AmountHost());
      for (final label in ['7', '8', '9']) {
        await tester.tap(_key(label));
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(find.text('amount 789'), findsOneWidget);
      await tester.longPress(_key('delete'));
      await tester.pumpAndSettle();
      expect(find.text('empty'), findsOneWidget);
    });

    testWidgets('onLongPress receives the key', (tester) async {
      final long = <CdsNumpadKey>[];
      await pumpCds(tester, SizedBox(width: 360, child: CdsNumpad(onPress: (_) {}, onLongPress: long.add)));
      await tester.longPress(_key('4'));
      expect(long, [const CdsNumpadKey.digit(4)]);
    });

    testWidgets('fires a light haptic on press by default', (tester) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments as String);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await pumpCds(tester, SizedBox(width: 360, child: CdsNumpad(onPress: (_) {})));
      await tester.tap(_key('1'));
      expect(calls, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('disabled blocks presses', (tester) async {
      final keys = <CdsNumpadKey>[];
      await pumpCds(tester, SizedBox(width: 360, child: CdsNumpad(onPress: keys.add, disabled: true)));
      await tester.tap(find.text('1'));
      expect(keys, isEmpty);
    });

    testWidgets('hideSeparator keeps the slot but removes the key', (tester) async {
      final handle = tester.ensureSemantics();
      final keys = <CdsNumpadKey>[];
      await pumpCds(tester, SizedBox(width: 360, child: CdsNumpad(onPress: keys.add, hideSeparator: true)));
      expect(find.bySemanticsLabel('period'), findsNothing);
      await tester.tap(find.text('.'), warnIfMissed: false);
      expect(keys, isEmpty);
      handle.dispose();
    });

    testWidgets('semantics: keys are buttons with labels', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        SizedBox(width: 360, child: CdsNumpad(onPress: (_) {}, deleteSemanticLabel: 'Backspace', separatorSemanticLabel: 'Decimal')),
      );
      expect(tester.getSemantics(_key('Backspace')), containsSemantics(isButton: true, label: 'Backspace'));
      expect(tester.getSemantics(_key('Decimal')), containsSemantics(isButton: true));
      expect(tester.getSemantics(_key('5')), containsSemantics(isButton: true, label: '5'));
      handle.dispose();
    });

    testWidgets('keyboard: Enter activates a focused key, hardware digits type', (tester) async {
      final keys = <CdsNumpadKey>[];
      await pumpCds(tester, SizedBox(width: 360, child: CdsNumpad(onPress: keys.add)));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 150));
      expect(keys, [const CdsNumpadKey.digit(1)]);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
      await tester.sendKeyEvent(LogicalKeyboardKey.period);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      expect(keys.skip(1), [const CdsNumpadKey.digit(7), CdsNumpadKey.separator, CdsNumpadKey.delete]);
    });

    testWidgets('accessory and action render', (tester) async {
      await pumpCds(
        tester,
        SizedBox(
          width: 360,
          child: CdsNumpad(
            onPress: (_) {},
            accessory: const CdsText('Balance'),
            action: CdsButton(label: 'Review order', onPress: () {}),
          ),
        ),
      );
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('Review order'), findsOneWidget);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, const SingleChildScrollView(child: _AmountHost()), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
