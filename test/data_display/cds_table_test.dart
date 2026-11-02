import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _assets = [('Bitcoin', 'BTC', r'$64,201.10'), ('Ethereum', 'ETH', r'$3,081.01'), ('Solana', 'SOL', r'$142.55')];

CdsTable _table({
  CdsTableVariant variant = CdsTableVariant.standard,
  bool compact = false,
  bool bordered = false,
  CdsTableLayout layout = CdsTableLayout.auto,
  void Function(String)? onRow,
  CdsTableSortDirection? sort,
  VoidCallback? onSort,
}) {
  return CdsTable(
    variant: variant,
    compact: compact,
    bordered: bordered,
    tableLayout: layout,
    semanticLabel: 'Holdings',
    children: [
      const CdsTableFooter(children: [
        CdsTableRow(children: [CdsTableCell(title: 'Total'), CdsTableCell(title: r'$67,424.66')]),
      ]),
      CdsTableBody(children: [
        for (final (name, symbol, price) in _assets)
          CdsTableRow(
            onPress: onRow == null ? null : () => onRow(name),
            semanticLabel: onRow == null ? null : 'Open $name',
            children: [
              CdsTableCell(title: name, subtitle: symbol, start: const CdsCellMedia.icon(CdsIconName.wallet)),
              CdsTableCell(title: price, alignItems: CrossAxisAlignment.end),
            ],
          ),
      ]),
      CdsTableHeader(children: [
        CdsTableRow(children: [
          const CdsTableCell(title: 'Asset'),
          CdsTableCell(title: 'Price', sortDirection: sort, onPress: onSort, alignItems: CrossAxisAlignment.end),
        ]),
      ]),
      const CdsTableCaption('Holdings'),
    ],
  );
}

Widget _frame(Widget child, {double width = 390}) => SizedBox(width: width, child: child);

void main() {
  group('CdsTable', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders every variant in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          _frame(SingleChildScrollView(
            child: Column(children: [
              for (final v in CdsTableVariant.values) _table(variant: v),
              _table(compact: true, bordered: true),
              _table(layout: CdsTableLayout.fixed),
            ]),
          )),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('renders sections in table order whatever the child order', (tester) async {
      await pumpCds(tester, _frame(_table()));
      final caption = tester.getTopLeft(find.text('Holdings')).dy;
      final header = tester.getTopLeft(find.text('Asset')).dy;
      final body = tester.getTopLeft(find.text('Bitcoin')).dy;
      final footer = tester.getTopLeft(find.text('Total')).dy;
      expect(caption < header && header < body && body < footer, isTrue);
    });

    testWidgets('uses 16px cell padding, or 8px when compact', (tester) async {
      await pumpCds(tester, _frame(_table()), center: false);
      expect(tester.getTopLeft(find.text('Asset')).dx, 16);
      await pumpCds(tester, _frame(_table(compact: true)), center: false);
      expect(tester.getTopLeft(find.text('Asset')).dx, 8);
    });

    testWidgets('header text is muted headline, body text is body', (tester) async {
      await pumpCds(tester, _frame(_table()));
      const theme = CdsThemeData.light;
      final header = tester.widget<Text>(find.text('Asset')).style!;
      final body = tester.widget<Text>(find.text('Bitcoin')).style!;
      expect(header.color, theme.color.fgMuted);
      expect(header.fontWeight, theme.typography[CdsFont.headline].fontWeight);
      expect(body.color, theme.color.fg);
      expect(body.fontSize, theme.typography[CdsFont.body].fontSize);
    });

    testWidgets('scrolls horizontally when wider than the screen', (tester) async {
      await pumpCds(
        tester,
        _frame(
          CdsTable(children: [
            CdsTableBody(children: [
              CdsTableRow(children: [for (var i = 0; i < 8; i++) CdsTableCell(title: 'Column number $i')]),
            ]),
          ]),
          width: 300,
        ),
      );
      expect(tester.takeException(), isNull);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
      await tester.drag(find.text('Column number 0'), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, greaterThan(0));
    });

    testWidgets('fills the width when narrower than the screen', (tester) async {
      await pumpCds(tester, _frame(_table()));
      expect(tester.getSize(find.byType(Table)).width, 390);
    });

    testWidgets('pressable rows fire onPress from a tap on any cell', (tester) async {
      final pressed = <String>[];
      await pumpCds(tester, _frame(_table(onRow: pressed.add)));
      await tester.tap(find.text('Ethereum'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text(r'$142.55'));
      expect(pressed, ['Ethereum', 'Solana']);
    });

    testWidgets('pressable rows tint on pointer-down', (tester) async {
      await pumpCds(tester, _frame(_table(onRow: (_) {})));
      final gesture = await tester.startGesture(tester.getCenter(find.text('Bitcoin')));
      await tester.pump();
      final table = tester.widget<Table>(find.byType(Table));
      expect(table.children.any((row) => row.decoration != null), isTrue);
      await gesture.up();
      await tester.pump();
      expect(tester.widget<Table>(find.byType(Table)).children.every((row) => row.decoration == null), isTrue);
    });

    testWidgets('pressable rows are buttons reachable by keyboard', (tester) async {
      final handle = tester.ensureSemantics();
      final pressed = <String>[];
      await pumpCds(tester, _frame(_table(onRow: pressed.add)));
      expect(find.bySemanticsLabel(RegExp('Open Bitcoin')), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(pressed, ['Bitcoin']);
      handle.dispose();
    });

    testWidgets('sortable header cells show state and fire onPress', (tester) async {
      final handle = tester.ensureSemantics();
      var sorts = 0;
      await pumpCds(tester, _frame(_table(sort: CdsTableSortDirection.descending, onSort: () => sorts++)));
      expect(find.byType(CdsTableCellSortIcon), findsOneWidget);
      expect(tester.widget<Text>(find.text('Price')).style!.color, CdsThemeData.light.color.fgPrimary);
      expect(tester.getSemantics(find.text('Price')), containsSemantics(value: 'Sorted descending', isHeader: true, isButton: true));
      await tester.tap(find.text('Price'));
      expect(sorts, 1);
      handle.dispose();
    });

    testWidgets('fixed column widths come from cells', (tester) async {
      await pumpCds(tester, _frame(const CdsTable(children: [
        CdsTableBody(children: [
          CdsTableRow(children: [CdsTableCell(title: 'A', width: 120), CdsTableCell(title: 'B')]),
          CdsTableRow(children: [CdsTableCell(title: 'C')]),
        ]),
      ])));
      expect(tester.getSize(find.text('A')).width, lessThanOrEqualTo(120));
      expect(tester.getTopLeft(find.text('B')).dx - tester.getTopLeft(find.text('A')).dx, 120);
      expect(tester.takeException(), isNull);
    });

    testWidgets('loading rows render placeholders without animating', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        _frame(CdsTable(children: [
          CdsTableBody(children: [
            for (var i = 0; i < 3; i++)
              CdsTableRow(children: [
                CdsTableCellFallback(title: true, subtitle: true, start: CdsCellMediaType.asset, rectWidthVariant: i),
                CdsTableCellFallback(title: true, end: CdsCellMediaType.image, rectWidthVariant: i),
              ]),
          ]),
        ])),
        settle: false,
      );
      // Only the scrollbar's one-off fade-in may run; the placeholders are still.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.bySemanticsLabel('Loading cell'), findsNWidgets(6));
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('sections used outside a table explain the mistake', (tester) async {
      await pumpCds(tester, const CdsTableRow(children: [CdsTableCell(title: 'x')]));
      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('scrolls vertically past maxHeight', (tester) async {
      await pumpCds(tester, _frame(CdsTable(maxHeight: 120, children: [
        CdsTableBody(children: [for (var i = 0; i < 10; i++) CdsTableRow(children: [CdsTableCell(title: 'Row $i')])]),
      ])));
      expect(tester.getSize(find.byType(CdsTable)).height, 120);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at text scale 2', (tester) async {
      await pumpCds(
        tester,
        _frame(SingleChildScrollView(child: _table(onRow: (_) {}, sort: CdsTableSortDirection.none, onSort: () {}))),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out right to left', (tester) async {
      await pumpCds(tester, _frame(_table()), textDirection: TextDirection.rtl);
      expect(tester.getCenter(find.text('Asset')).dx, greaterThan(tester.getCenter(find.text('Price')).dx));
    });
  });
}
