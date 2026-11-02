import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

CdsBanner _banner({
  CdsBannerVariant variant = CdsBannerVariant.warning,
  bool showDismiss = false,
  VoidCallback? onClose,
  CdsBannerStyleVariant style = CdsBannerStyleVariant.contextual,
}) =>
    CdsBanner(
      variant: variant,
      startIcon: CdsIconName.warning,
      startIconAccessibilityLabel: 'Warning',
      title: 'Verify your identity',
      description: 'Sending is paused until you finish verification.',
      label: 'Sample data: updated 2 min ago',
      showDismiss: showDismiss,
      onClose: onClose,
      styleVariant: style,
      primaryAction: CdsButton(label: 'Verify now', size: CdsButtonSize.xs, transparent: true, onPress: () {}),
    );

void main() {
  testWidgets('renders every variant in light and dark', (tester) async {
    for (final b in Brightness.values) {
      for (final v in CdsBannerVariant.values) {
        await pumpCds(tester, _banner(variant: v), brightness: b);
        expect(find.text('Verify your identity'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('variant colors come from CDS banner tokens', (tester) async {
    expect(CdsBannerColors.of(CdsBannerVariant.error).background, CdsColor.bgNegativeWash);
    expect(CdsBannerColors.of(CdsBannerVariant.warning).iconColor, CdsColor.fgWarning);
    expect(CdsBannerColors.of(CdsBannerVariant.promotional).background, CdsColor.bgPrimaryWash);
    expect(CdsBannerColors.of(CdsBannerVariant.informational).background, CdsColor.bgSecondary);
  });

  testWidgets('dismiss collapses the banner, then calls onClose', (tester) async {
    var closed = 0;
    await pumpCds(tester, _banner(showDismiss: true, onClose: () => closed++));
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(closed, 0);
    await tester.pumpAndSettle();
    expect(closed, 1);
    final size = tester.getSize(find.byType(CdsBanner));
    expect(size.height, 0);
  });

  testWidgets('dismiss is instant under reduced motion', (tester) async {
    var closed = 0;
    await pumpCds(tester, _banner(showDismiss: true, onClose: () => closed++), disableAnimations: true);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pump();
    expect(closed, 1);
    expect(find.text('Verify your identity'), findsNothing);
  });

  testWidgets('icon has a label and the close target is 44px', (tester) async {
    await pumpCds(tester, _banner(showDismiss: true));
    expect(find.bySemanticsLabel(RegExp('^Warning')), findsOneWidget);
    final close = find.ancestor(of: find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.close), matching: find.byType(CdsPressable));
    expect(tester.getSize(close).height, greaterThanOrEqualTo(44));
  });

  testWidgets('global style draws a start bar; text scale 2.0 does not overflow', (tester) async {
    await pumpCds(tester, SizedBox(width: 360, child: _banner(style: CdsBannerStyleVariant.global)), textScale: 2);
    expect(tester.takeException(), isNull);
    expect(find.byType(PositionedDirectional), findsOneWidget);
  });
}
