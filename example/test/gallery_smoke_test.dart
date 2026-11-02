import 'package:cds_flutter/cds_flutter.dart';
import 'package:cds_flutter_example/gallery/categories.dart';
import 'package:cds_flutter_example/gallery/category_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds every gallery demo in light and dark, and at 2x text, failing on
/// any exception or layout overflow.
void main() {
  Widget host(Widget child, {required Brightness brightness, double textScale = 1}) {
    final data = CdsThemeData(config: CdsThemeConfig.standard, brightness: brightness);
    return CdsTheme(
      data: data,
      child: MaterialApp(
        theme: cdsMaterialTheme(data),
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: CdsToastHost(child: app!),
        ),
        home: child,
      ),
    );
  }

  for (final category in componentCategories) {
    for (final demo in category.demos) {
      for (final (label, brightness, scale) in [
        ('light', Brightness.light, 1.0),
        ('dark', Brightness.dark, 1.0),
        ('2x text', Brightness.light, 2.0),
      ]) {
        testWidgets('${category.title} / ${demo.title} ($label)', (tester) async {
          tester.view.physicalSize = const Size(1179, 2556);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(host(DemoPage(demo: demo), brightness: brightness, textScale: scale));
          await tester.pump(const Duration(seconds: 1));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 1));
        });
      }
    }
  }
}
