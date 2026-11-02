import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _padded(Widget child) => Padding(padding: const EdgeInsets.all(16), child: child);

class _Host extends StatefulWidget {
  const _Host({this.onComplete, this.length = 6});

  final ValueChanged<String>? onComplete;
  final int length;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String code = '';

  @override
  Widget build(BuildContext context) => CdsOtpInput(
        label: 'Verification code',
        length: widget.length,
        value: code,
        onChange: (v) => setState(() => code = v),
        onComplete: widget.onComplete,
      );
}

List<String> _cellTexts(WidgetTester tester) => tester
    .widgetList<CdsText>(find.descendant(of: find.byType(CdsInputStack), matching: find.byType(CdsText)))
    .map((t) => t.data!)
    .toList();

void main() {
  group('CdsOtpInput', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _padded(const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CdsOtpInput(label: 'Code', value: '123'),
              CdsOtpInput(value: '12', variant: CdsInputVariant.negative, helperText: 'Wrong code'),
              CdsOtpInput(disabled: true, length: 4),
            ],
          )),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('renders one cell per character', (tester) async {
      await pumpCds(tester, _padded(const CdsOtpInput(length: 4, value: '12')));
      expect(find.byType(CdsInputStack), findsNWidgets(4));
      expect(_cellTexts(tester), ['1', '2']);
    });

    testWidgets('typing fills cells in order and fires onComplete once', (tester) async {
      final completed = <String>[];
      await pumpCds(tester, _padded(_Host(onComplete: completed.add, length: 4)));
      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      expect(_cellTexts(tester), ['1', '2']);
      expect(completed, isEmpty);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();
      expect(_cellTexts(tester), ['1', '2', '3', '4']);
      expect(completed, ['1234']);
    });

    testWidgets('pasting a longer code keeps digits only and truncates to length', (tester) async {
      await pumpCds(tester, _padded(const _Host()));
      await tester.enterText(find.byType(TextField), '123-456-789');
      await tester.pump();
      expect(_cellTexts(tester), ['1', '2', '3', '4', '5', '6']);
    });

    testWidgets('backspace removes the last character and moves the active cell back', (tester) async {
      await pumpCds(tester, _padded(const _Host(length: 4)));
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();
      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      expect(_cellTexts(tester), ['1', '2']);
      final stacks = tester.widgetList<CdsInputStack>(find.byType(CdsInputStack)).toList();
      expect(stacks[2].focused, isTrue);
      expect(stacks[1].focused, isFalse);
    });

    testWidgets('caret is kept after the last character', (tester) async {
      final controller = TextEditingController(text: '123');
      addTearDown(controller.dispose);
      await pumpCds(tester, _padded(CdsOtpInput(controller: controller)));
      controller.selection = const TextSelection.collapsed(offset: 0);
      await tester.pump();
      expect(controller.selection, const TextSelection.collapsed(offset: 3));
    });

    testWidgets('obscureText shows dots', (tester) async {
      await pumpCds(tester, _padded(const CdsOtpInput(value: '12', obscureText: true)));
      expect(_cellTexts(tester), ['•', '•']);
    });

    testWidgets('custom formatter allows letters', (tester) async {
      String? last;
      await pumpCds(
        tester,
        _padded(CdsOtpInput(
          length: 4,
          keyboardType: TextInputType.text,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Z0-9]'))],
          onChange: (v) => last = v,
        )),
      );
      await tester.enterText(find.byType(TextField), 'AB12');
      expect(last, 'AB12');
    });

    testWidgets('disabled cannot be edited', (tester) async {
      await pumpCds(tester, _padded(const CdsOtpInput(disabled: true)));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('semantics: one labeled text field with position hint', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _padded(const CdsOtpInput(label: 'SMS code', value: '1')));
      final node = tester.getSemantics(find.byType(TextField));
      expect(node.label, contains('SMS code'));
      expect(node.hint, contains('Digit 2 of 6'));
      expect(node.flagsCollection.isTextField, isTrue);
      handle.dispose();
    });

    testWidgets('negative helper text is a live region with the error icon', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        _padded(const CdsOtpInput(variant: CdsInputVariant.negative, helperText: 'Code expired')),
      );
      expect(tester.getSemantics(find.text('Code expired')), containsSemantics(isLiveRegion: true));
      expect(find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.info), findsOneWidget);
      handle.dispose();
    });

    testWidgets('keyboard: Tab focuses the field and highlights the active cell', (tester) async {
      await pumpCds(tester, _padded(const CdsOtpInput(length: 4)));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final stacks = tester.widgetList<CdsInputStack>(find.byType(CdsInputStack)).toList();
      expect(stacks.first.focused, isTrue);
    });

    testWidgets('reduced motion and text scale 2.0 render without errors', (tester) async {
      await pumpCds(
        tester,
        _padded(const CdsOtpInput(label: 'Verification code', value: '12', helperText: 'Sent to your phone')),
        textScale: 2,
        disableAnimations: true,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
