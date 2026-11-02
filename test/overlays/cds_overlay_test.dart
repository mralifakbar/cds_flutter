import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('scrim uses bgOverlay scaled by opacity and reports taps', (tester) async {
    var taps = 0;
    await pumpCds(tester, CdsOverlay(opacity: 0.5, onPress: () => taps++, semanticLabel: 'Dismiss'), center: false);
    final box = tester.widget<ColoredBox>(find.descendant(of: find.byType(CdsOverlay), matching: find.byType(ColoredBox)));
    expect(box.color.a, closeTo(CdsThemeData.light.color.bgOverlay.a * 0.5, 0.01));
    await tester.tap(find.byType(CdsOverlay));
    expect(taps, 1);
    expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
  });

  testWidgets('portal renders above the page and follows visible', (tester) async {
    var visible = true;
    late StateSetter set;
    await pumpCds(
      tester,
      StatefulBuilder(builder: (context, setState) {
        set = setState;
        return CdsTheme(
          data: CdsThemeData.dark,
          child: CdsPortal(
            visible: visible,
            child: Builder(
              builder: (context) => Align(
                alignment: Alignment.topCenter,
                child: CdsText(context.cds.isDark ? 'Portal dark' : 'Portal light'),
              ),
            ),
          ),
        );
      }),
    );
    expect(find.text('Portal dark'), findsOneWidget);
    set(() => visible = false);
    await tester.pump();
    expect(find.text('Portal dark'), findsNothing);
  });
}
