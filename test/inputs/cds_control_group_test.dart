import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _options = [
  CdsControlOption(value: 'email', label: 'Email'),
  CdsControlOption(value: 'push', label: 'Push'),
  CdsControlOption(value: 'sms', label: 'SMS', disabled: true),
];

void main() {
  group('CdsControlGroup', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every kind in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CdsControlGroup<String>.radio(label: 'Radio', options: _options, value: 'push', onChange: (_) {}),
              CdsControlGroup<String>.checkbox(label: 'Checkbox', options: _options, value: const {'email'}, onChange: (_) {}),
              CdsControlGroup<String>.switches(label: 'Switches', options: _options, value: const {'push'}, onChange: (_) {}),
              CdsControlGroup<String>.checkbox(
                label: 'Horizontal',
                options: _options,
                value: const {},
                direction: Axis.horizontal,
                onChange: (_) {},
              ),
            ]),
          ),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('radio: onChange receives the tapped value', (tester) async {
      String? selected;
      await pumpCds(tester, CdsControlGroup<String>.radio(options: _options, value: null, onChange: (v) => selected = v));
      await tester.tap(find.text('Push'));
      expect(selected, 'push');
    });

    testWidgets('checkbox: onChange receives the full next set', (tester) async {
      final changes = <Set<String>>[];
      await pumpCds(
        tester,
        CdsControlGroup<String>.checkbox(options: _options, value: const {'email'}, onChange: changes.add),
      );
      await tester.tap(find.text('Push'));
      await tester.tap(find.text('Email'));
      await tester.tap(find.text('SMS'));
      expect(changes, [
        {'email', 'push'},
        <String>{},
      ]);
    });

    testWidgets('switches: toggles membership', (tester) async {
      Set<String>? next;
      await pumpCds(
        tester,
        CdsControlGroup<String>.switches(options: _options, value: const {'push'}, onChange: (v) => next = v),
      );
      await tester.tap(find.text('Push'));
      expect(next, <String>{});
    });

    testWidgets('disabled group fires nothing', (tester) async {
      var calls = 0;
      await pumpCds(
        tester,
        CdsControlGroup<String>.checkbox(options: _options, value: const {}, disabled: true, onChange: (_) => calls++),
      );
      await tester.tap(find.text('Email'));
      expect(calls, 0);
    });

    testWidgets('semantics: group container is labelled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        CdsControlGroup<String>.checkbox(label: 'Notifications', options: _options, value: const {}, onChange: (_) {}),
      );
      expect(tester.getSemantics(find.byType(CdsControlGroup<String>)).label, 'Notifications');
      expect(find.bySemanticsLabel('Email'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('checkbox group: every option is a tab stop', (tester) async {
      await pumpCds(
        tester,
        CdsControlGroup<String>.checkbox(options: _options, value: const {}, onChange: (_) {}),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(Focus.of(tester.element(find.text('Push'))).hasFocus, isTrue);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(
        tester,
        SizedBox(
          width: 320,
          child: CdsControlGroup<String>.switches(label: 'Alerts', options: _options, value: const {}, onChange: (_) {}),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
