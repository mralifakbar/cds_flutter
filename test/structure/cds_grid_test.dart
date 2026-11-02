import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

Widget _cell(String id, {double height = 40}) => SizedBox(key: Key(id), height: height, child: CdsText(id));

Widget _frame(Widget grid) => SizedBox(width: 400, child: grid);

void main() {
  testWidgets('fixed columns split width with gaps and wrap rows', (tester) async {
    await pumpCds(tester, _frame(CdsGrid(columns: 2, gap: 2, children: [_cell('a'), _cell('b'), _cell('c')])));
    // (400 - 16) / 2 = 192 per column.
    expect(tester.getSize(find.byKey(const Key('a'))).width, 192);
    final a = tester.getTopLeft(find.byKey(const Key('a')));
    final b = tester.getTopLeft(find.byKey(const Key('b')));
    final c = tester.getTopLeft(find.byKey(const Key('c')));
    expect(b.dx - a.dx, 208);
    expect(c.dx, a.dx);
    expect(c.dy - a.dy, 56);
  });

  testWidgets('cells in a row share the tallest height', (tester) async {
    await pumpCds(tester, _frame(CdsGrid(columns: 2, children: [_cell('a', height: 20), _cell('b', height: 60)])));
    expect(tester.getSize(find.byKey(const Key('a'))).height, 60);
  });

  testWidgets('columnMin picks the column count from the width', (tester) async {
    await pumpCds(tester, _frame(CdsGrid(columnMin: 120, children: [for (var i = 0; i < 4; i++) _cell('c$i')])));
    // 400px fits three 120px columns.
    final first = tester.getTopLeft(find.byKey(const Key('c0')));
    expect(tester.getTopLeft(find.byKey(const Key('c2'))).dy, first.dy);
    expect(tester.getTopLeft(find.byKey(const Key('c3'))).dy, greaterThan(first.dy));
  });

  testWidgets('CdsGridColumn spans and starts at a column', (tester) async {
    await pumpCds(
      tester,
      _frame(CdsGrid(columns: 4, children: [
        CdsGridColumn(colSpan: 3, child: _cell('wide')),
        _cell('one'),
        CdsGridColumn(colStart: 3, colSpan: 2, child: _cell('end')),
        CdsGridColumn(colSpan: 9, child: _cell('clamped')),
      ])),
    );
    expect(tester.getSize(find.byKey(const Key('wide'))).width, 300);
    final origin = tester.getTopLeft(find.byType(CdsGrid));
    expect(tester.getTopLeft(find.byKey(const Key('end'))).dx - origin.dx, 200);
    expect(tester.getSize(find.byKey(const Key('clamped'))).width, 400);
  });

  testWidgets('RTL places the first column on the right', (tester) async {
    await pumpCds(tester, _frame(CdsGrid(columns: 2, children: [_cell('a'), _cell('b')])),
        textDirection: TextDirection.rtl);
    expect(tester.getTopLeft(find.byKey(const Key('a'))).dx, greaterThan(tester.getTopLeft(find.byKey(const Key('b'))).dx));
  });

  testWidgets('works inside intrinsic sizing and at text scale 2.0', (tester) async {
    await pumpCds(
      tester,
      _frame(IntrinsicHeight(child: CdsGrid(columns: 3, gap: 1, children: [for (var i = 0; i < 5; i++) CdsText('Item $i')]))),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
