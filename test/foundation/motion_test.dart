import 'dart:async';

import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('project matches the UIScrollView deceleration formula', () {
    expect(CdsMotion.project(1000), closeTo(0.998 / 0.002, 1e-9));
    expect(CdsMotion.project(-500), lessThan(0));
    expect(CdsMotion.project(0), 0);
  });

  test('rubberband resists progressively and never exceeds the overshoot', () {
    final small = CdsMotion.rubberband(10, 300);
    final large = CdsMotion.rubberband(200, 300);
    expect(small, lessThan(10));
    expect(large, lessThan(200));
    expect(large / 200, lessThan(small / 10));
    expect(CdsMotion.rubberband(-50, 300), lessThan(0));
    expect(CdsMotion.rubberband(50, 0), 0);
  });

  test('springs derive stiffness from response', () {
    final fast = CdsSprings.of(dampingRatio: 1, response: 0.2);
    final slow = CdsSprings.of(dampingRatio: 1, response: 0.5);
    expect(fast.stiffness, greaterThan(slow.stiffness));
  });

  testWidgets('springTo starts from the current value and settles at the target', (tester) async {
    final controller = AnimationController.unbounded(vsync: const TestVSync(), value: 0.3);
    addTearDown(controller.dispose);
    unawaited(CdsMotion.springTo(controller, 1));
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.value, greaterThan(0.3));
    expect(controller.value, lessThan(1));
    await tester.pump(const Duration(seconds: 2));
    expect(controller.value, closeTo(1, 0.001));
  });

  testWidgets('duration collapses under reduced motion', (tester) async {
    late Duration d;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Builder(builder: (context) {
        d = CdsMotion.duration(context, CdsDurations.moderate3);
        return const SizedBox();
      }),
    ));
    expect(d, Duration.zero);
  });
}
