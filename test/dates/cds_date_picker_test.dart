import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

final _today = DateTime(2026, 11, 2);

class _Host extends StatefulWidget {
  // Not const, so call sites cannot turn the log into an unmodifiable const list.
  // ignore: prefer_const_constructors_in_immutables
  _Host({required this.log, this.top = true});

  final List<String> log;
  final bool top;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  DateTime? date;
  CdsDateInputValidationError? error;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: widget.top ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            CdsDatePicker(
              label: 'Start date',
              date: date,
              error: error,
              currentDate: _today,
              seedDate: _today,
              onOpen: () => widget.log.add('open'),
              onClose: () => widget.log.add('close'),
              onConfirm: () => widget.log.add('confirm'),
              onCancel: () => widget.log.add('cancel'),
              onChangeDate: (d) {
                widget.log.add('date:${d?.day}');
                setState(() => date = d);
              },
              onErrorDate: (e) {
                widget.log.add('error:${e?.type.name}');
                setState(() => error = e);
              },
            ),
            const CdsText('Outside'),
          ],
        ),
      );
}

Finder get _openButton => find.bySemanticsLabel('Open calendar');

void main() {
  group('CdsDatePicker', () {
    for (final brightness in Brightness.values) {
      testWidgets('opens in ${brightness.name}', (tester) async {
        await pumpCds(tester, _Host(log: []), brightness: brightness, center: false);
        await tester.tap(_openButton);
        await tester.pumpAndSettle();
        expect(find.text('November 2026'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('picking a day sets the date, closes, and fires events in order', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log), center: false);
      await tester.tap(_openButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('18'));
      await tester.pumpAndSettle();
      expect(log, ['open', 'confirm', 'date:18', 'close']);
      expect(find.text('November 2026'), findsNothing);
      expect(find.text('11/18/2026'), findsOneWidget);
    });

    testWidgets('picking clears a previous validation error', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log), center: false);
      await tester.enterText(find.byType(TextField), '02/30/2026');
      await tester.pump();
      expect(log.last, 'error:invalid');
      await tester.tap(_openButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();
      expect(log.sublist(log.length - 4), ['confirm', 'date:4', 'error:null', 'close']);
    });

    testWidgets('Escape closes without picking and restores focus to the button', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log), center: false);
      await tester.tap(_openButton);
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('day 2'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(log, ['open', 'cancel', 'close']);
      expect(find.text('November 2026'), findsNothing);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'CdsDatePicker calendar button');
    });

    testWidgets('tapping outside closes', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log), center: false);
      await tester.tap(_openButton);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(780, 580));
      await tester.pumpAndSettle();
      expect(log, ['open', 'cancel', 'close']);
    });

    testWidgets('opens above the field when there is no room below', (tester) async {
      await pumpCds(tester, _Host(log: [], top: false), center: false);
      await tester.tap(_openButton);
      await tester.pumpAndSettle();
      final fieldTop = tester.getTopLeft(find.byType(TextField)).dy;
      expect(tester.getBottomLeft(find.text('November 2026')).dy, lessThan(fieldTop));
    });

    testWidgets('disabled picker does not open', (tester) async {
      await pumpCds(
        tester,
        CdsDatePicker(date: null, onChangeDate: (_) {}, disabled: true, label: 'D'),
        center: false,
      );
      await tester.tap(_openButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(CdsCalendar), findsNothing);
    });

    testWidgets('reduced motion opens and closes without animating', (tester) async {
      await pumpCds(tester, _Host(log: []), disableAnimations: true, center: false);
      await tester.tap(_openButton);
      await tester.pump();
      await tester.pump();
      expect(find.text('November 2026'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump();
      expect(find.text('November 2026'), findsNothing);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, _Host(log: []), textScale: 2, center: false);
      await tester.tap(_openButton);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
