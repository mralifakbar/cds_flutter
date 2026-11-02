// The indicator painter is private; tests read its geometry dynamically.
// ignore_for_file: avoid_dynamic_calls

import 'dart:ui' show Tristate;

import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

const _tabs = [
  CdsTabValue(id: 'crypto', label: 'Crypto'),
  CdsTabValue(id: 'nfts', label: 'NFTs'),
  CdsTabValue(id: 'defi', label: 'DeFi'),
];

class _Host extends StatefulWidget {
  const _Host({this.initial = 'crypto', this.tabs = _tabs, this.onChange, this.pageController});

  final String? initial;
  final List<CdsTabValue> tabs;
  final ValueChanged<String>? onChange;
  final PageController? pageController;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late String? active = widget.initial;

  @override
  Widget build(BuildContext context) {
    return CdsTabs(
      accessibilityLabel: 'Sections',
      tabs: widget.tabs,
      activeTab: active,
      pageController: widget.pageController,
      onChange: (id) {
        widget.onChange?.call(id);
        setState(() => active = id);
      },
    );
  }
}

Rect _indicatorBar(WidgetTester tester) {
  final indicator = find.byType(CdsTabIndicator);
  final paint = tester.widget<CustomPaint>(find.descendant(of: indicator, matching: find.byType(CustomPaint)).first);
  final painter = paint.painter!;
  final origin = tester.getTopLeft(indicator);
  final x = (painter as dynamic).x as double;
  final w = (painter as dynamic).width as double;
  return Rect.fromLTWH(origin.dx + x, origin.dy, w, 2);
}

void main() {
  testWidgets('renders in light and dark', (tester) async {
    for (final b in Brightness.values) {
      await pumpCds(tester, const _Host(), brightness: b);
      expect(find.text('Crypto'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('tapping a tab calls onChange and moves the indicator under it', (tester) async {
    String? changed;
    await pumpCds(tester, _Host(onChange: (id) => changed = id));
    final before = _indicatorBar(tester);
    expect(before.center.dx, closeTo(tester.getCenter(find.text('Crypto')).dx, 1));

    await tester.tap(find.text('DeFi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final mid = _indicatorBar(tester);
    expect(mid.left, greaterThan(before.left));
    expect(mid.left, lessThan(tester.getTopLeft(find.text('DeFi')).dx));
    await tester.pumpAndSettle();
    expect(changed, 'defi');
    expect(_indicatorBar(tester).center.dx, closeTo(tester.getCenter(find.text('DeFi')).dx, 1));
  });

  testWidgets('tapping the active tab does not call onChange', (tester) async {
    var calls = 0;
    await pumpCds(tester, _Host(onChange: (_) => calls++));
    await tester.tap(find.text('Crypto'));
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('disabled tabs ignore taps and are skipped by arrow keys', (tester) async {
    final calls = <String>[];
    await pumpCds(
      tester,
      _Host(
        tabs: const [
          CdsTabValue(id: 'a', label: 'Alpha'),
          CdsTabValue(id: 'b', label: 'Beta', disabled: true),
          CdsTabValue(id: 'c', label: 'Gamma'),
        ],
        initial: 'a',
        onChange: calls.add,
      ),
    );
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(calls, ['c']);
  });

  testWidgets('arrow keys, Home and End move the selection and focus', (tester) async {
    final calls = <String>[];
    await pumpCds(tester, _Host(onChange: calls.add));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(calls, ['nfts', 'defi', 'crypto']);
  });

  testWidgets('arrow keys follow reading order in RTL', (tester) async {
    final calls = <String>[];
    await pumpCds(tester, _Host(onChange: calls.add), textDirection: TextDirection.rtl);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(calls, ['nfts']);
    expect(_indicatorBar(tester).center.dx, closeTo(tester.getCenter(find.text('NFTs')).dx, 1));
  });

  testWidgets('exposes a tab bar with selected tab semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCds(tester, const _Host());
    expect(
      tester.getSemantics(find.text('Crypto')),
      matchesSemantics(
        label: 'Crypto',
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    expect(tester.getSemantics(find.text('NFTs')).getSemanticsData().flagsCollection.isSelected, Tristate.isFalse);
    expect(tester.getSemantics(find.text('NFTs')).getSemanticsData().role, SemanticsRole.tab);
    expect(find.bySemanticsLabel('Sections'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('no active tab shows no indicator', (tester) async {
    await pumpCds(tester, const _Host(initial: null));
    final paint = tester.widgetList<CdsTabIndicator>(find.byType(CdsTabIndicator));
    expect(paint, isEmpty);
  });

  testWidgets('count badge renders next to the label', (tester) async {
    await pumpCds(
      tester,
      const _Host(tabs: [CdsTabValue(id: 'inbox', label: 'Inbox', count: 120), CdsTabValue(id: 'sent', label: 'Sent')], initial: 'inbox'),
    );
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('indicator follows a connected PageView drag', (tester) async {
    final controller = PageController();
    addTearDown(controller.dispose);
    await pumpCds(
      tester,
      Column(
        children: [
          _Host(pageController: controller),
          Expanded(
            child: PageView(
              controller: controller,
              children: const [Text('Page 1'), Text('Page 2'), Text('Page 3')],
            ),
          ),
        ],
      ),
      center: false,
    );
    final start = _indicatorBar(tester);
    final gesture = await tester.startGesture(tester.getCenter(find.text('Page 1')));
    await gesture.moveBy(const Offset(-100, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-95, 0));
    await tester.pump();
    final halfway = _indicatorBar(tester);
    final nfts = tester.getCenter(find.text('NFTs')).dx;
    expect(halfway.center.dx, greaterThan(start.center.dx + 10));
    expect(halfway.center.dx, lessThan(nfts));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion jumps the indicator with no running tickers', (tester) async {
    await pumpCds(tester, const _Host(), disableAnimations: true);
    await tester.tap(find.text('DeFi'));
    await tester.pump();
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(_indicatorBar(tester).center.dx, closeTo(tester.getCenter(find.text('DeFi')).dx, 1));
  });

  testWidgets('text scale 2.0 does not overflow', (tester) async {
    await pumpCds(tester, const SizedBox(width: 390, child: _Host()), textScale: 2);
    expect(tester.takeException(), isNull);
  });
}
