import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

class _Host extends StatefulWidget {
  // Not const, so call sites cannot turn the log into an unmodifiable const list.
  // ignore: prefer_const_constructors_in_immutables
  _Host({
    required this.log,
    this.initial,
    this.required = false,
    this.minDate,
    this.disabledDates = const [],
    this.dateOrder = CdsDateOrder.mdy,
  });

  final List<String> log;
  final DateTime? initial;
  final bool required;
  final DateTime? minDate;
  final List<DateTime> disabledDates;
  final CdsDateOrder dateOrder;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late DateTime? date = widget.initial;
  CdsDateInputValidationError? error;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CdsDateInput(
              label: 'Date',
              date: date,
              error: error,
              required: widget.required,
              minDate: widget.minDate,
              disabledDates: widget.disabledDates,
              dateOrder: widget.dateOrder,
              onChange: (t) => widget.log.add('change:$t'),
              onChangeDate: (d) {
                widget.log.add('date:${d == null ? 'null' : '${d.year}-${d.month}-${d.day}'}');
                setState(() => date = d);
              },
              onErrorDate: (e) {
                widget.log.add('error:${e?.type.name ?? 'null'}');
                setState(() => error = e);
              },
            ),
            CdsButton(label: 'Set', onPress: () => setState(() => date = DateTime(2025, 1, 2))),
          ],
        ),
      );
}

Future<void> _type(WidgetTester tester, String chars) async {
  final field = find.byType(TextField);
  for (final c in chars.split('')) {
    final current = tester.widget<TextField>(field).controller!.text;
    await tester.enterText(field, current + c);
    await tester.pump();
  }
}

String _text(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  group('CdsDateInput', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name} with the format as helper text', (tester) async {
        await pumpCds(tester, _Host(log: []), brightness: brightness);
        expect(find.text('mm/dd/yyyy'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('inserts separators while typing digits', (tester) async {
      await pumpCds(tester, _Host(log: []));
      await _type(tester, '123');
      expect(_text(tester), '12/3');
      await _type(tester, '12026');
      expect(_text(tester), '12/31/2026');
    });

    testWidgets('rejects letters and stray separators', (tester) async {
      await pumpCds(tester, _Host(log: []));
      await _type(tester, '1/a');
      expect(_text(tester), '1');
    });

    testWidgets('paste of digits is reformatted', (tester) async {
      await pumpCds(tester, _Host(log: []));
      await tester.enterText(find.byType(TextField), '03152026');
      await tester.pump();
      expect(_text(tester), '03/15/2026');
    });

    testWidgets('event order: typing a full valid date', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log));
      await _type(tester, '03152026');
      expect(log.last, 'date:2026-3-15');
      expect(log.where((e) => e.startsWith('date:')).length, 1);
      expect(log.first, startsWith('change:'));
    });

    testWidgets('editing a complete date clears it first', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log, initial: DateTime(2026, 3, 15)));
      expect(_text(tester), '03/15/2026');
      await tester.enterText(find.byType(TextField), '03/15/202');
      await tester.pump();
      expect(log, ['change:03/15/202', 'date:null']);
    });

    testWidgets('invalid date reports onChangeDate(null) then an invalid error', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log));
      await _type(tester, '02302026');
      expect(log.sublist(log.length - 2), ['date:null', 'error:invalid']);
      expect(find.text('Please enter a valid date'), findsOneWidget);
    });

    testWidgets('disabled and out-of-range dates report a disabled error', (tester) async {
      final log = <String>[];
      await pumpCds(
        tester,
        _Host(log: log, minDate: DateTime(2026, 1, 1), disabledDates: [DateTime(2026, 5, 5)]),
      );
      await _type(tester, '05052026');
      expect(log.last, 'error:disabled');
      expect(find.text('Date unavailable'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(log.last, 'error:null');
      await _type(tester, '12312025');
      expect(log.last, 'error:disabled');
    });

    testWidgets('required: blurring an incomplete value reports required', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log, required: true));
      await _type(tester, '12');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(log.last, 'error:required');
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('external date replaces the text', (tester) async {
      await pumpCds(tester, _Host(log: []));
      await tester.tap(find.text('Set'));
      await tester.pump();
      expect(_text(tester), '01/02/2025');
    });

    testWidgets('dmy order parses day first', (tester) async {
      final log = <String>[];
      await pumpCds(tester, _Host(log: log, dateOrder: CdsDateOrder.dmy));
      expect(find.text('dd/mm/yyyy'), findsOneWidget);
      await _type(tester, '31122026');
      expect(log.last, 'date:2026-12-31');
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, _Host(log: []), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
