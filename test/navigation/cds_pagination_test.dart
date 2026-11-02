import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

String _render(List<CdsPaginationItem> items) => items.join(' ');

class _Host extends StatefulWidget {
  const _Host({this.total = 10, this.initial = 1, this.disabled = false, this.firstLast = false, this.onChange});

  final int total;
  final int initial;
  final bool disabled;
  final bool firstLast;
  final ValueChanged<int>? onChange;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late int page = widget.initial;

  @override
  Widget build(BuildContext context) => CdsPagination(
        totalPages: widget.total,
        activePage: page,
        disabled: widget.disabled,
        showFirstLastButtons: widget.firstLast,
        onChange: (p) {
          widget.onChange?.call(p);
          setState(() => page = p);
        },
      );
}

void main() {
  group('cdsPaginationItems', () {
    test('matches the CDS algorithm', () {
      expect(_render(cdsPaginationItems(activePage: 1, totalPages: 1)), '[1]');
      expect(_render(cdsPaginationItems(activePage: 2, totalPages: 3)), '1 [2] 3');
      expect(_render(cdsPaginationItems(activePage: 1, totalPages: 7)), '[1] 2 3 4 5 6 7');
      expect(_render(cdsPaginationItems(activePage: 1, totalPages: 10)), '[1] 2 3 4 5 ... 10');
      expect(_render(cdsPaginationItems(activePage: 5, totalPages: 10)), '1 ... 4 [5] 6 ... 10');
      expect(_render(cdsPaginationItems(activePage: 10, totalPages: 10)), '1 ... 6 7 8 9 [10]');
      expect(
        _render(cdsPaginationItems(activePage: 10, totalPages: 20, siblingCount: 2, boundaryCount: 2)),
        '1 2 ... 8 9 [10] 11 12 ... 19 20',
      );
    });

    test('treats zero pages as one', () {
      expect(_render(cdsPaginationItems(activePage: 1, totalPages: 0)), '[1]');
    });
  });

  testWidgets('renders in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, const _Host(), brightness: b);
      expect(tester.takeException(), isNull);
      expect(find.text('10'), findsOneWidget);
    }
  });

  testWidgets('page, next and previous call onChange', (tester) async {
    final calls = <int>[];
    await pumpCds(tester, _Host(initial: 5, onChange: calls.add));
    await tester.tap(find.bySemanticsLabel('Page 6'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.bySemanticsLabel('Next page'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.bySemanticsLabel('Previous page'));
    await tester.pumpAndSettle();
    expect(calls, [6, 7, 6]);
  });

  testWidgets('previous is disabled on the first page and nothing fires when disabled', (tester) async {
    final calls = <int>[];
    await pumpCds(tester, _Host(onChange: calls.add));
    await tester.tap(find.bySemanticsLabel('Previous page'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);

    await pumpCds(tester, _Host(initial: 3, disabled: true, onChange: calls.add));
    await tester.tap(find.bySemanticsLabel('Page 4'));
    await tester.tap(find.bySemanticsLabel('Next page'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);
  });

  testWidgets('first and last buttons', (tester) async {
    final calls = <int>[];
    await pumpCds(tester, _Host(initial: 5, firstLast: true, onChange: calls.add));
    await tester.tap(find.text('Last'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('First'));
    await tester.pumpAndSettle();
    expect(calls, [10, 1]);
  });

  testWidgets('current page is selected in semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const _Host(initial: 2));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Page 2')),
      containsSemantics(label: 'Page 2', isButton: true, isSelected: true),
    );
    expect(find.bySemanticsLabel('...'), findsNothing);
    handle.dispose();
  });

  testWidgets('arrow keys move focus between pages and Enter activates', (tester) async {
    final calls = <int>[];
    await pumpCds(tester, _Host(total: 5, onChange: calls.add));
    Focus.of(tester.element(find.text('1'))).requestFocus();
    await tester.pump();
    expect(Focus.of(tester.element(find.text('1'))).hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(Focus.of(tester.element(find.text('2'))).hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(calls, [2]);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(Focus.of(tester.element(find.text('1'))).hasFocus, isTrue);
  });

  testWidgets('RTL, text scale 2 and reduced motion render without errors', (tester) async {
    await pumpCds(tester, const _Host(initial: 5, firstLast: true),
        textDirection: TextDirection.rtl, textScale: 2, disableAnimations: true);
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
    final arrows = tester.widgetList<CdsIconButton>(find.byType(CdsIconButton)).map((b) => b.name).toList();
    expect(arrows, [CdsIconName.caretRight, CdsIconName.caretLeft]);
  });
}
