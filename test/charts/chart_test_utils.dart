import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records platform haptic calls for the rest of the test.
class HapticLog {
  HapticLog(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments as String?);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
  }

  final List<String?> calls = [];

  int get selections => calls.where((c) => c == 'HapticFeedbackType.selectionClick').length;
}

/// Sample series used across chart tests. Generated values, not real prices.
const List<double> sampleValues = [10, 22, 29, 45, 98, 45, 22];
