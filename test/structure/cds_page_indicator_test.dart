import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

final _dots = find.byWidgetPredicate((w) => w is AnimatedContainer && w.constraints?.minHeight == 4);

double _dotWidth(WidgetTester tester, int index) => tester.getSize(_dots.at(index)).width;

void main() {
  testWidgets('active dot is 24px wide, others 4px, in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, const CdsPageIndicator(totalPages: 3, activePageIndex: 1), brightness: b);
      expect(_dotWidth(tester, 0), 4);
      expect(_dotWidth(tester, 1), 24);
      expect(_dotWidth(tester, 2), 4);
    }
  });

  testWidgets('pressing a dot reports its index; hit area is 44px tall', (tester) async {
    final pressed = <int>[];
    await pumpCds(tester, CdsPageIndicator(totalPages: 3, activePageIndex: 0, onPressPage: pressed.add));
    await tester.tap(find.bySemanticsLabel('Go to page 3'));
    expect(pressed, [2]);
    expect(tester.getSize(find.byType(CdsPressable).first).height, 44);
  });

  testWidgets('semantics: button, label and selected state', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(
      tester,
      CdsPageIndicator(
        totalPages: 2,
        activePageIndex: 0,
        onPressPage: (_) {},
        accessibilityLabel: (i) => 'Slide ${i + 1}',
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Slide 1')),
      matchesSemantics(
        label: 'Slide 1',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('width change animates and is instant under reduced motion', (tester) async {
    await pumpCds(tester, const CdsPageIndicator(totalPages: 2, activePageIndex: 0));
    await pumpCds(tester, const CdsPageIndicator(totalPages: 2, activePageIndex: 1), settle: false);
    await tester.pump(const Duration(milliseconds: 50));
    expect(_dotWidth(tester, 1), inExclusiveRange(4, 24));

    await pumpCds(tester, const CdsPageIndicator(totalPages: 2, activePageIndex: 0), disableAnimations: true, settle: false);
    await tester.pump();
    expect(_dotWidth(tester, 0), 24);
  });
}
