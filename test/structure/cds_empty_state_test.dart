import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('empty variant renders in light and dark and fires both actions', (tester) async {
    for (final b in Brightness.values) {
      var primary = 0;
      var secondary = 0;
      await pumpCds(
        tester,
        CdsEmptyState(
          key: ValueKey(b),
          icon: CdsIconName.wallet,
          title: 'No assets yet',
          description: 'Assets you buy or receive appear here.',
          primaryAction: 'Buy Bitcoin',
          onPrimaryActionPress: () => primary++,
          secondaryAction: 'Receive crypto',
          onSecondaryActionPress: () => secondary++,
        ),
        brightness: b,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Buy Bitcoin'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Receive crypto'));
      expect(primary, 1);
      expect(secondary, 1);
    }
  });

  testWidgets('title is a header; error variant is a live region with an icon', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(
      tester,
      CdsEmptyState(
        variant: CdsEmptyStateVariant.error,
        title: 'Prices did not load',
        description: 'Check your connection, then try again.',
        primaryAction: 'Try again',
        onPrimaryActionPress: () {},
      ),
    );
    expect(tester.getSemantics(find.text('Prices did not load')), matchesSemantics(label: 'Prices did not load', isHeader: true));
    final icon = tester.widget<CdsIcon>(find.byType(CdsIcon));
    expect(icon.name, CdsIconName.error);
    expect(icon.color, CdsColor.fgNegative);
    final live = find.byWidgetPredicate((w) => w is Semantics && w.properties.liveRegion == true);
    expect(live, findsOneWidget);
    handle.dispose();
  });

  testWidgets('media slot replaces the icon; text scale 2.0 and RTL', (tester) async {
    await pumpCds(
      tester,
      const SizedBox(
        width: 320,
        child: CdsEmptyState(
          media: SizedBox(key: Key('art'), width: 80, height: 80),
          title: 'Your watchlist is empty',
          description: 'Tap the star on any asset to follow its price here.',
        ),
      ),
      textScale: 2,
      textDirection: TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('art')), findsOneWidget);
    expect(find.byType(CdsIcon), findsNothing);
  });
}
