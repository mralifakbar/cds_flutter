import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in everything a CDS widget expects: directionality, media
/// query, overlay/navigation (via WidgetsApp) and a CDS theme.
Widget cdsHarness(
  Widget child, {
  Brightness brightness = Brightness.light,
  CdsThemeConfig config = CdsThemeConfig.standard,
  TextDirection textDirection = TextDirection.ltr,
  bool disableAnimations = false,
  double textScale = 1,
  bool center = true,
}) {
  return MediaQuery(
    data: MediaQueryData(
      disableAnimations: disableAnimations,
      textScaler: TextScaler.linear(textScale),
      size: const Size(390, 844),
    ),
    child: CdsTheme(
      data: CdsThemeData(config: config, brightness: brightness),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: cdsMaterialTheme(CdsThemeData(config: config, brightness: brightness)),
        builder: (context, app) => Directionality(textDirection: textDirection, child: app!),
        home: Builder(
          builder: (context) => ColoredBox(
            color: context.cds.color.bg,
            child: center ? Center(child: child) : child,
          ),
        ),
      ),
    ),
  );
}

/// Pumps [child] inside [cdsHarness] and settles animations.
Future<void> pumpCds(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
  bool disableAnimations = false,
  double textScale = 1,
  bool center = true,
  bool settle = true,
}) async {
  await tester.pumpWidget(cdsHarness(
    child,
    brightness: brightness,
    textDirection: textDirection,
    disableAnimations: disableAnimations,
    textScale: textScale,
    center: center,
  ));
  if (settle) await tester.pumpAndSettle();
}

/// Renders [child] in light and dark side by side for golden comparison.
Widget goldenPair(Widget child, {double width = 360}) {
  Widget pane(Brightness b) => CdsTheme(
        data: CdsThemeData(config: CdsThemeConfig.standard, brightness: b),
        child: Builder(
          builder: (context) => Container(
            width: width,
            color: context.cds.color.bg,
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );
  return MediaQuery(
    data: const MediaQueryData(size: Size(800, 1200)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [pane(Brightness.light), pane(Brightness.dark)],
        ),
      ),
    ),
  );
}
