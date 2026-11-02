import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

/// The hues in the CDS color spectrum.
enum CdsHue { blue, green, orange, yellow, gray, indigo, pink, purple, red, teal, chartreuse }

/// The raw CDS color spectrum: 11 hues, 13 steps each (0, 5, 10, 15, 20, 30 ... 100).
///
/// Prefer semantic tokens ([CdsColor]) in components. Reach for the spectrum only
/// for data visualisation or illustration work where a semantic token does not exist.
@immutable
class CdsSpectrum {
  const CdsSpectrum(this._colors);

  /// The 13 steps each hue defines, in order.
  static const List<int> steps = [0, 5, 10, 15, 20, 30, 40, 50, 60, 70, 80, 90, 100];

  final Map<CdsHue, List<Color>> _colors;

  /// Returns the color for [hue] at [step]. Throws if [step] is not in [steps].
  Color of(CdsHue hue, int step) {
    final index = steps.indexOf(step);
    if (index < 0) {
      throw ArgumentError.value(step, 'step', 'must be one of $steps');
    }
    return _colors[hue]![index];
  }

  /// Returns a copy with some hues replaced. Each list must hold 13 colors.
  CdsSpectrum copyWith(Map<CdsHue, List<Color>> overrides) {
    assert(overrides.values.every((c) => c.length == steps.length));
    return CdsSpectrum({..._colors, ...overrides});
  }

  @override
  bool operator ==(Object other) =>
      other is CdsSpectrum &&
      CdsHue.values.every((h) => listEquals(_colors[h], other._colors[h]));

  @override
  int get hashCode => Object.hashAll(CdsHue.values.map((h) => Object.hashAll(_colors[h]!)));
}
