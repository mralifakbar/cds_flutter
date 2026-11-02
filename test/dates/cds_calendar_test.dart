import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

final _today = DateTime(2026, 11, 2);

Finder _day(String label) => find.bySemanticsLabel(label);

Future<void> _tabIntoGrid(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    if (FocusManager.instance.primaryFocus?.debugLabel?.contains('day') ?? false) return;
  }
}

class _Host extends StatefulWidget {
  const _Host({this.initial, this.minDate, this.maxDate, this.disabledDates = const [], this.onPress});

  final DateTime? initial;
  final DateTime? minDate;
  final DateTime? maxDate;
  final List<DateTime> disabledDates;
  final ValueChanged<DateTime>? onPress;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late DateTime? selected = widget.initial;

  @override
  Widget build(BuildContext context) => CdsCalendar(
        currentDate: _today,
        selectedDate: selected,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        disabledDates: widget.disabledDates,
        onPressDate: (d) {
          setState(() => selected = d);
          widget.onPress?.call(d);
        },
      );
}

void main() {
  group('CdsCalendar', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          CdsCalendar(
            currentDate: _today,
            selectedDate: DateTime(2026, 11, 10),
            highlightedDates: [DateTime(2026, 11, 12)],
            disabledDateRanges: [DateTimeRange(start: DateTime(2026, 11, 20), end: DateTime(2026, 11, 22))],
            onPressDate: (_) {},
          ),
          brightness: brightness,
        );
        expect(find.text('November 2026'), findsOneWidget);
        expect(find.text('30'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('pressing a day calls onPressDate with midnight', (tester) async {
      DateTime? pressed;
      await pumpCds(tester, _Host(onPress: (d) => pressed = d));
      await tester.tap(find.text('15'));
      await tester.pump();
      expect(pressed, DateTime(2026, 11, 15));
    });

    testWidgets('days outside min/max and disabled days are not selectable', (tester) async {
      DateTime? pressed;
      await pumpCds(
        tester,
        _Host(
          minDate: DateTime(2026, 11, 5),
          maxDate: DateTime(2026, 11, 25),
          disabledDates: [DateTime(2026, 11, 10)],
          onPress: (d) => pressed = d,
        ),
      );
      for (final label in ['3', '10', '28']) {
        await tester.tap(find.text(label));
        await tester.pump();
      }
      expect(pressed, isNull);
      await tester.tap(find.text('11'));
      await tester.pump();
      expect(pressed, DateTime(2026, 11, 11));
    });

    testWidgets('month navigation clamps to min and max', (tester) async {
      await pumpCds(tester, _Host(minDate: DateTime(2026, 10, 15), maxDate: DateTime(2026, 12, 3)));
      await tester.tap(find.bySemanticsLabel('Go to next month'));
      await tester.pumpAndSettle();
      expect(find.text('December 2026'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Go to next month'));
      await tester.pumpAndSettle();
      expect(find.text('December 2026'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Go to previous month'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Go to previous month'));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Go to previous month'));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
    });

    testWidgets('opens on maxDate month when maxDate is in the past', (tester) async {
      await pumpCds(tester, CdsCalendar(currentDate: _today, maxDate: DateTime(2026, 3, 9)));
      expect(find.text('March 2026'), findsOneWidget);
    });

    testWidgets('semantics: label, selected, today hint, disabled hint', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        CdsCalendar(
          currentDate: _today,
          selectedDate: DateTime(2026, 11, 3),
          disabledDates: [DateTime(2026, 11, 4)],
          onPressDate: (_) {},
        ),
      );
      expect(
        tester.getSemantics(_day('Tuesday 3 November 2026')),
        containsSemantics(label: 'Tuesday 3 November 2026', isSelected: true, isButton: true),
      );
      expect(tester.getSemantics(_day('Monday 2 November 2026')), containsSemantics(hint: 'Today'));
      expect(
        tester.getSemantics(_day('Wednesday 4 November 2026')),
        containsSemantics(hint: 'Date unavailable', isEnabled: false),
      );
      handle.dispose();
    });

    testWidgets('keyboard: arrows move by day and week, crossing into the next month', (tester) async {
      DateTime? pressed;
      await pumpCds(tester, _Host(initial: DateTime(2026, 11, 27), onPress: (d) => pressed = d));
      await _tabIntoGrid(tester);
      final primary = FocusManager.instance.primaryFocus;
      expect(primary?.debugLabel, contains('day 27'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('day 28'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('December 2026'), findsOneWidget);
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('day 5'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(find.text('November 2026'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('day 22'));
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('day 28'));
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(find.text('December 2026'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(pressed, DateTime(2026, 12, 28));
    });

    testWidgets('keyboard skips disabled days and stops at maxDate', (tester) async {
      await pumpCds(
        tester,
        _Host(
          initial: DateTime(2026, 11, 9),
          disabledDates: [DateTime(2026, 11, 10), DateTime(2026, 11, 11)],
          maxDate: DateTime(2026, 11, 13),
        ),
      );
      await _tabIntoGrid(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('day 12'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('day 12'));
    });

    testWidgets('disabled calendar ignores taps', (tester) async {
      DateTime? pressed;
      await pumpCds(tester, CdsCalendar(currentDate: _today, disabled: true, onPressDate: (d) => pressed = d));
      await tester.tap(find.text('15'));
      await tester.pump();
      expect(pressed, isNull);
    });

    testWidgets('hideControls removes the arrows', (tester) async {
      await pumpCds(tester, CdsCalendar(currentDate: _today, hideControls: true));
      expect(find.bySemanticsLabel('Go to next month'), findsNothing);
    });

    testWidgets('reduced motion: month change leaves no running animation', (tester) async {
      await pumpCds(tester, CdsCalendar(currentDate: _today), disableAnimations: true);
      await tester.tap(find.bySemanticsLabel('Go to next month'));
      await tester.pump();
      await tester.pump();
      expect(find.text('December 2026'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('text scale 2.0 does not overflow', (tester) async {
      await pumpCds(tester, CdsCalendar(currentDate: _today, onPressDate: (_) {}), textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });
}
