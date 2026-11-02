import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Like `pumpCds` but with a custom screen size; the shared harness fixes
/// the media query size at 390x844.
Future<void> pumpCdsSized(
  WidgetTester tester,
  Widget child,
  Size size, {
  TextDirection textDirection = TextDirection.ltr,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MediaQuery(
    data: MediaQueryData(size: size),
    child: CdsTheme(
      data: CdsThemeData.light,
      child: MaterialApp(
        builder: (context, app) => Directionality(textDirection: textDirection, child: app!),
        home: Builder(
          builder: (context) => ColoredBox(color: context.cds.color.bg, child: Center(child: child)),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}
