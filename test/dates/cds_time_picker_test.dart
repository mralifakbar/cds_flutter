import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _Host extends StatefulWidget {
  // Not const, so call sites cannot turn the log into an unmodifiable const list.
  // ignore: prefer_const_constructors_in_immutables
  _Host({
    required this.log,
    this.initial,
    this.use24 = false,
    this.minuteInterval = 1,
    this.minTime,
    this.maxTime,
  });

  final List<String> log;
  final TimeOfDay? initial;
  final bool use24;
  final int minuteInterval;
  final TimeOfDay? minTime;
  final TimeOfDay? maxTime;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late TimeOfDay? value = widget.initial;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CdsTimePicker(
              label: 'Time',
              value: value,
              use24HourFormat: widget.use24,
              minuteInterval: widget.minuteInterval,
              minTime: widget.minTime,
              maxTime: widget.maxTime,
              onError: (e) => widget.log.add('error:$e'),
              onChange: (t) {
                widget.log.add(t == null ? 'null' : '${t.hour}:${t.minute}');
                setState(() => value = t);
              },
            ),
            const CdsText('Outside'),
          ],
        ),
      );
}

String _text(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  group('CdsTimePicker', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(tester, _Host(log: [], initial: const TimeOfDay(hour: 14, minute: 5)),
            brightness: brightness, center: false);
        expect(_text(tester), '02:05');
        expect(find.text('PM'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('typing inserts the colon and reports the time', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log, use24: true), center: false);
      await tester.enterText(find.byType(TextField), '1');
      await tester.enterText(find.byType(TextField), '13');
      await tester.enterText(find.byType(TextField), '134');
      await tester.pump();
      expect(_text(tester), '13:4');
      await tester.enterText(find.byType(TextField), '13:45');
      await tester.pump();
      expect(log.last, '13:45');
    });

    testWidgets('12-hour: AM/PM toggle switches the period', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log, initial: const TimeOfDay(hour: 9, minute: 30)), center: false);
      expect(find.text('AM'), findsOneWidget);
      await tester.tap(find.text('AM'));
      await tester.pump();
      expect(log.last, '21:30');
      expect(find.text('PM'), findsOneWidget);
    });

    testWidgets('invalid time shows an error and reports null', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log), center: false);
      await tester.enterText(find.byType(TextField), '13:00');
      await tester.pump();
      expect(log, ['null', 'error:Please enter a valid time']);
      expect(find.text('Please enter a valid time'), findsOneWidget);
    });

    testWidgets('time outside min/max is unavailable', (tester) async {
      final log = <String>[];
      await pumpCds(
        tester,
        _Host(log: log, use24: true, minTime: const TimeOfDay(hour: 9, minute: 0), maxTime: const TimeOfDay(hour: 17, minute: 0)),
        center: false,
      );
      await tester.enterText(find.byType(TextField), '18:00');
      await tester.pump();
      expect(find.text('Time unavailable'), findsOneWidget);
    });

    testWidgets('blurring an incomplete value shows the invalid error', (tester) async {
      await pumpCds(tester, _Host(log: []), center: false);
      await tester.enterText(find.byType(TextField), '1');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(find.text('Please enter a valid time'), findsOneWidget);
    });

    testWidgets('popover: pick hour and minute, Escape closes and restores focus', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log, use24: true, minuteInterval: 15), center: false);
      await tester.tap(find.bySemanticsLabel('Open time picker'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Minute 45'), findsOneWidget);
      expect(find.bySemanticsLabel('Minute 5'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Hour 2'));
      await tester.pump();
      expect(log.last, '2:0');
      await tester.tap(find.bySemanticsLabel('Minute 30'));
      await tester.pump();
      expect(log.last, '2:30');
      expect(_text(tester), '02:30');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Minute 30'), findsNothing);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'CdsTimePicker clock button');
    });

    testWidgets('popover: selected item exposes selected semantics; Done closes', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(tester, _Host(log: [], initial: const TimeOfDay(hour: 10, minute: 0)), center: false);
      await tester.tap(find.bySemanticsLabel('Open time picker'));
      await tester.pumpAndSettle();
      expect(tester.getSemantics(find.bySemanticsLabel('Hour 10')), containsSemantics(isSelected: true));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsNothing);
      handle.dispose();
    });

    testWidgets('tapping outside closes the popover', (tester) async {
      await pumpCds(tester, _Host(log: []), center: false);
      await tester.tap(find.bySemanticsLabel('Open time picker'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(780, 580));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, _Host(log: [], initial: const TimeOfDay(hour: 8, minute: 0)), textScale: 2, center: false);
      await tester.tap(find.bySemanticsLabel('Open time picker'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
