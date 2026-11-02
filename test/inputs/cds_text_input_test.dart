import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _padded(Widget child) => Padding(padding: const EdgeInsets.all(16), child: child);

class _Controlled extends StatefulWidget {
  const _Controlled({this.onChange});

  final ValueChanged<String>? onChange;

  @override
  State<_Controlled> createState() => _ControlledState();
}

class _ControlledState extends State<_Controlled> {
  String value = 'abc';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CdsTextInput(
          label: 'Name',
          value: value,
          onChange: (v) {
            setState(() => value = v);
            widget.onChange?.call(v);
          },
        ),
        CdsButton(label: 'Reset', onPress: () => setState(() => value = 'reset')),
      ],
    );
  }
}

void main() {
  group('CdsTextInput', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every variant in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _padded(SingleChildScrollView(
            child: Column(
              children: [
                for (final v in CdsInputVariant.values)
                  CdsTextInput(label: v.name, helperText: 'Helper', variant: v, placeholder: 'Type'),
                const CdsTextInput(label: 'Disabled', disabled: true),
                const CdsTextInput(label: 'Read only', readOnly: true, value: 'Fixed'),
                const CdsTextInput(label: 'Compact', compact: true),
                const CdsTextInput(label: 'Inside', labelVariant: CdsInputLabelVariant.inside),
                const CdsTextInput(label: 'Inside m', labelVariant: CdsInputLabelVariant.inside, size: CdsTextInputSize.m),
                const CdsTextInput(label: 'Amount', prefix: r'$', suffix: 'USD', start: CdsInputIcon(CdsIconName.search)),
              ],
            ),
          )),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('value + onChange: typing reports text, external value replaces it', (tester) async {
      final changes = <String>[];
      await pumpCds(tester, _padded(_Controlled(onChange: changes.add)));
      expect(find.text('abc'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(changes.last, 'hello');
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('reset'), findsOneWidget);
    });

    testWidgets('controller mode uses the given controller', (tester) async {
      final controller = TextEditingController(text: 'start');
      addTearDown(controller.dispose);
      String? last;
      await pumpCds(tester, _padded(CdsTextInput(label: 'C', controller: controller, onChange: (v) => last = v)));
      expect(find.text('start'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'next');
      expect(controller.text, 'next');
      expect(last, 'next');
    });

    testWidgets('focus fades in the focus border and fires onFocus/onBlur', (tester) async {
      var focused = 0;
      var blurred = 0;
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpCds(
        tester,
        _padded(CdsTextInput(label: 'F', focusNode: node, onFocus: () => focused++, onBlur: () => blurred++)),
      );
      final fade = find.descendant(of: find.byType(CdsInputStack), matching: find.byType(FadeTransition));
      expect(tester.widget<FadeTransition>(fade.first).opacity.value, 0);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(focused, 1);
      expect(tester.widget<FadeTransition>(fade.first).opacity.value, 1);
      node.unfocus();
      await tester.pumpAndSettle();
      expect(blurred, 1);
      expect(tester.widget<FadeTransition>(fade.first).opacity.value, 0);
    });

    testWidgets('tapping the label focuses the field', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpCds(tester, _padded(CdsTextInput(label: 'Label tap', focusNode: node)));
      await tester.tap(find.text('Label tap'));
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('disabled field cannot be edited', (tester) async {
      await pumpCds(tester, _padded(const CdsTextInput(label: 'D', disabled: true)));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('negative variant shows the error icon and announces as a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        _padded(const CdsTextInput(label: 'Email', helperText: 'Enter a valid email', variant: CdsInputVariant.negative)),
      );
      expect(find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.info), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Enter a valid email')),
        containsSemantics(isLiveRegion: true, label: 'error\nEnter a valid email'),
      );
      handle.dispose();
    });

    testWidgets('semantics: text field with label and helper hint', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _padded(const CdsTextInput(label: 'Email', helperText: 'Work address')));
      final node = tester.getSemantics(find.byType(TextField));
      expect(node.label, contains('Email'));
      expect(node.hint, 'Work address');
      expect(node.flagsCollection.isTextField, isTrue);
      handle.dispose();
    });

    testWidgets('inputFormatters and maxLength are applied', (tester) async {
      String? last;
      await pumpCds(
        tester,
        _padded(CdsTextInput(
          label: 'Digits',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 4,
          onChange: (v) => last = v,
        )),
      );
      await tester.enterText(find.byType(TextField), '12ab345');
      expect(last, '1234');
    });

    testWidgets('onSubmitEditing fires with the text', (tester) async {
      String? submitted;
      await pumpCds(tester, _padded(CdsTextInput(label: 'S', value: 'go', onSubmitEditing: (v) => submitted = v)));
      await tester.tap(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, 'go');
    });

    testWidgets('works without MaterialApp localizations', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: CdsTheme(
              data: CdsThemeData.light,
              child: Overlay(
                initialEntries: [
                  OverlayEntry(builder: (_) => const Center(child: SizedBox(width: 300, child: CdsTextInput(label: 'Bare')))),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(
        tester,
        _padded(const CdsTextInput(label: 'Large label', helperText: 'Helper text', prefix: r'$', suffix: 'USD')),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion snaps the focus border', (tester) async {
      await pumpCds(tester, _padded(const CdsTextInput(label: 'R')), disableAnimations: true);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      final fade = find.descendant(of: find.byType(CdsInputStack), matching: find.byType(FadeTransition));
      expect(tester.widget<FadeTransition>(fade.first).opacity.value, 1);
    });
  });
}
