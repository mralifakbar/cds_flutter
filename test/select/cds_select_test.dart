import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';
import '../overlays/sized_harness.dart';

const _options = [
  CdsSelectOption(value: 'eth', label: 'Ethereum'),
  CdsSelectOption(value: 'base', label: 'Base'),
  CdsSelectOption(value: 'sol', label: 'Solana', description: 'SOL'),
  CdsSelectOption(value: 'btc', label: 'Bitcoin', disabled: true),
];

class _Single extends StatefulWidget {
  const _Single({this.presentation = CdsSelectPresentation.auto, this.variant, this.helperText, this.disabled = false});

  final CdsSelectPresentation presentation;
  final CdsSelectVariant? variant;
  final String? helperText;
  final bool disabled;

  @override
  State<_Single> createState() => _SingleState();
}

class _SingleState extends State<_Single> {
  String? value;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 320,
        child: CdsSelect<String>(
          label: 'Network',
          placeholder: 'Choose a network',
          helperText: widget.helperText,
          variant: widget.variant,
          disabled: widget.disabled,
          presentation: widget.presentation,
          value: value,
          onChange: (v) => setState(() => value = v),
          options: _options,
        ),
      );
}

class _Multi extends StatefulWidget {
  const _Multi({this.presentation = CdsSelectPresentation.auto});

  final CdsSelectPresentation presentation;

  @override
  State<_Multi> createState() => _MultiState();
}

class _MultiState extends State<_Multi> {
  List<String> value = [];

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 320,
        child: CdsSelect<String>.multi(
          label: 'Networks',
          placeholder: 'Choose networks',
          presentation: widget.presentation,
          maxSelectedOptionsToShow: 2,
          value: value,
          onChange: (v) => setState(() => value = v),
          options: _options,
        ),
      );
}

void main() {
  testWidgets('shows label, placeholder and helper text in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, const _Single(helperText: 'Sample data: fees vary by network'), brightness: b);
      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Choose a network'), findsOneWidget);
      expect(find.text('Sample data: fees vary by network'), findsOneWidget);
    }
  });

  testWidgets('compact width opens a tray; picking closes it and updates the value', (tester) async {
    await pumpCds(tester, const _Single());
    await tester.tap(find.text('Choose a network'));
    await tester.pumpAndSettle();
    expect(find.byType(CdsTray), findsOneWidget);
    await tester.tap(find.text('Base'));
    await tester.pumpAndSettle();
    expect(find.byType(CdsTray), findsNothing);
    expect(find.text('Base'), findsOneWidget);
    expect(find.text('Choose a network'), findsNothing);
  });

  testWidgets('wide screens open an anchored menu under the control', (tester) async {
    await pumpCdsSized(tester, const _Single(), const Size(1200, 800));
    await tester.tap(find.text('Choose a network'));
    await tester.pumpAndSettle();
    expect(find.byType(CdsTray), findsNothing);
    final menuTop = tester.getTopLeft(find.text('Ethereum')).dy;
    expect(menuTop, greaterThan(tester.getBottomLeft(find.text('Choose a network')).dy));
    await tester.tap(find.text('Solana'));
    await tester.pumpAndSettle();
    expect(find.text('Ethereum'), findsNothing);
    expect(find.text('Solana'), findsOneWidget);
  });

  testWidgets('disabled options and disabled controls ignore presses', (tester) async {
    await pumpCds(tester, const _Single(presentation: CdsSelectPresentation.dropdown));
    await tester.tap(find.text('Choose a network'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bitcoin'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a network'), findsOneWidget);

    await pumpCds(tester, const _Single(disabled: true));
    await tester.tap(find.text('Choose a network'));
    await tester.pumpAndSettle();
    expect(find.text('Ethereum'), findsNothing);
  });

  testWidgets('multi select toggles, shows chips with +N more, select all and clear all', (tester) async {
    await pumpCds(tester, const _Multi(presentation: CdsSelectPresentation.tray));
    await tester.tap(find.text('Choose networks'));
    await tester.pumpAndSettle();
    expect(find.text('Select all (3)'), findsOneWidget);
    await tester.tap(find.text('Ethereum'));
    await tester.pump();
    await tester.tap(find.text('Base'));
    await tester.pumpAndSettle();
    expect(find.byType(CdsTray), findsOneWidget);
    await tester.tap(find.text('Select all (3)'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(195, 10));
    await tester.pumpAndSettle();
    expect(find.text('+1 more'), findsOneWidget);
    final handle = tester.ensureSemantics();
    await tester.pump();
    final data = tester.getSemantics(find.bySemanticsLabel(RegExp('^Networks'))).getSemanticsData();
    expect(data.customSemanticsActionIds, hasLength(3));
    handle.dispose();

    await tester.tap(find.ancestor(of: find.text('Ethereum'), matching: find.byType(CdsPressable)).first);
    await tester.pumpAndSettle();
    expect(find.text('+1 more'), findsNothing);

    await tester.tap(find.byWidgetPredicate((w) => w is CdsIcon && w.name == CdsIconName.caretDown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(195, 10));
    await tester.pumpAndSettle();
    expect(find.text('Choose networks'), findsOneWidget);
  });

  testWidgets('control is a labeled button that reports its value', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const _Single(presentation: CdsSelectPresentation.dropdown));
    expect(find.bySemanticsLabel('Network, Choose a network'), findsOneWidget);
    await tester.tap(find.text('Choose a network'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ethereum'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Network, Ethereum'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('keyboard: Enter opens the menu, arrows move, Escape closes', (tester) async {
    await pumpCds(tester, const _Single(presentation: CdsSelectPresentation.dropdown));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Ethereum'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Base'), findsOneWidget);
    expect(find.text('Ethereum'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Ethereum'), findsNothing);
  });

  testWidgets('negative variant colors the helper text', (tester) async {
    await pumpCds(tester, const _Single(variant: CdsSelectVariant.negative, helperText: 'Choose a network to continue'));
    expect(tester.widget<CdsText>(find.widgetWithText(CdsText, 'Choose a network to continue')).color, CdsColor.fgNegative);
  });

  testWidgets('text scale 2.0 does not overflow', (tester) async {
    await pumpCds(tester, const _Multi(presentation: CdsSelectPresentation.tray), textScale: 2);
    await tester.tap(find.text('Choose networks'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty options show the empty label', (tester) async {
    await pumpCds(
      tester,
      CdsSelect<String>(
        presentation: CdsSelectPresentation.dropdown,
        placeholder: 'Choose',
        value: null,
        onChange: (_) {},
        options: const [],
      ),
    );
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();
    expect(find.text('No options available'), findsOneWidget);
  });
}
