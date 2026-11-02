import 'package:cds_flutter/cds_flutter.dart';
import 'package:cds_flutter_example/gallery/scheme_scope.dart';
import 'package:cds_flutter_example/sample/wallet_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() {
  return SchemeScope(
    scheme: CdsColorSchemePreference.light,
    onChange: (_) {},
    child: CdsThemeProvider(
      colorScheme: CdsColorSchemePreference.light,
      child: Builder(
        builder: (context) => MaterialApp(theme: cdsMaterialTheme(context.cds), home: const SampleWalletApp()),
      ),
    ),
  );
}

void main() {
  testWidgets('home shows the sample label, balance and assets', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Sample data'), findsWidgets);
    expect(find.text('Total balance'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Bitcoin'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Bitcoin'), findsOneWidget);
  });

  testWidgets('buy flow: amount on the numpad, confirm, toast', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount'), findsOneWidget);
    for (final digit in ['2', '5']) {
      await tester.tap(find.descendant(of: find.byType(CdsNumpad), matching: find.text(digit)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text(r'Buy $25.00'), findsOneWidget);
    await tester.tap(find.text(r'Buy $25.00'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sample order'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  });

  testWidgets('activity search filters and shows a no-match empty state', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    expect(find.text('Bought Bitcoin'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches "zzz"'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Bought Bitcoin'), findsOneWidget);
  });

  testWidgets('settings can force the error state, and Try again recovers', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Error'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Error'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text("Couldn't load your assets"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Bitcoin'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Bitcoin'), findsOneWidget);
  });
}
