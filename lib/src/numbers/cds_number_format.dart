import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Formatting style for [CdsNumberFormat], mirroring `Intl.NumberFormat`'s `style`.
enum CdsNumberFormatStyle {
  /// Plain number: `1,234.567`.
  decimal,

  /// Number with a currency symbol in front: `$1,234.56`.
  currency,

  /// The value multiplied by 100 with a percent sign: `0.1234` becomes `12%`.
  percent,
}

/// Notation for [CdsNumberFormat], mirroring `Intl.NumberFormat`'s `notation`.
/// Scientific and engineering notation are not supported, like CDS.
enum CdsNumberNotation {
  standard,

  /// Short scale suffixes: `98345` becomes `98K`.
  compact,
}

/// When [CdsNumberFormat] shows a sign, mirroring `Intl.NumberFormat`'s `signDisplay`.
enum CdsNumberSignDisplay {
  /// Minus sign for negative numbers only.
  auto,

  /// Plus or minus sign for every number, including zero.
  always,

  /// Plus or minus sign for every number except zero.
  exceptZero,

  /// Never shows a sign.
  never,
}

/// Number formatting options for `CdsRollingNumber`, modeled on the
/// `Intl.NumberFormat` options CDS accepts in its `format` prop.
///
/// The package has no `intl` dependency, so formatting follows en-US rules by
/// default. Change [decimalSeparator] and [groupSeparator] for other locales,
/// or wrap your own formatter (for example one from `package:intl`) with
/// [CdsNumberFormat.custom].
///
/// ```dart
/// const CdsNumberFormat.currency()                 // $1,234.56
/// const CdsNumberFormat.percent(maximumFractionDigits: 2) // 12.34%
/// const CdsNumberFormat(notation: CdsNumberNotation.compact) // 98K
/// CdsNumberFormat.custom((v) => NumberFormat.simpleCurrency(locale: 'de_DE').format(v),
///     decimalSeparator: ',')
/// ```
@immutable
class CdsNumberFormat {
  const CdsNumberFormat({
    this.style = CdsNumberFormatStyle.decimal,
    this.currencySymbol = r'$',
    this.minimumFractionDigits,
    this.maximumFractionDigits,
    this.useGrouping = true,
    this.notation = CdsNumberNotation.standard,
    this.signDisplay = CdsNumberSignDisplay.auto,
    this.decimalSeparator = '.',
    this.groupSeparator = ',',
  }) : formatter = null;

  /// Currency formatting: two fraction digits by default.
  const CdsNumberFormat.currency({
    String symbol = r'$',
    this.minimumFractionDigits,
    this.maximumFractionDigits,
    this.useGrouping = true,
    this.notation = CdsNumberNotation.standard,
    this.signDisplay = CdsNumberSignDisplay.auto,
    this.decimalSeparator = '.',
    this.groupSeparator = ',',
  })  : style = CdsNumberFormatStyle.currency,
        currencySymbol = symbol,
        formatter = null;

  /// Percent formatting: the value is multiplied by 100, no fraction digits by default.
  const CdsNumberFormat.percent({
    this.minimumFractionDigits,
    this.maximumFractionDigits,
    this.useGrouping = true,
    this.signDisplay = CdsNumberSignDisplay.auto,
    this.decimalSeparator = '.',
    this.groupSeparator = ',',
  })  : style = CdsNumberFormatStyle.percent,
        currencySymbol = r'$',
        notation = CdsNumberNotation.standard,
        formatter = null;

  /// Uses [formatter] to turn the value into a string. [decimalSeparator] tells
  /// `CdsRollingNumber` where the fraction starts so digits keep their place
  /// when the integer part grows or shrinks.
  const CdsNumberFormat.custom(
    String Function(num value) this.formatter, {
    this.decimalSeparator = '.',
  })  : style = CdsNumberFormatStyle.decimal,
        currencySymbol = r'$',
        minimumFractionDigits = null,
        maximumFractionDigits = null,
        useGrouping = true,
        notation = CdsNumberNotation.standard,
        signDisplay = CdsNumberSignDisplay.auto,
        groupSeparator = ',';

  final CdsNumberFormatStyle style;

  /// Symbol placed before the number when [style] is [CdsNumberFormatStyle.currency].
  final String currencySymbol;

  /// Defaults to 0 for decimal and percent, 2 for currency.
  final int? minimumFractionDigits;

  /// Defaults to 3 for decimal, 0 for percent, 2 for currency. Compact
  /// notation defaults to two significant digits (`1.2K`, `98K`, `123K`).
  final int? maximumFractionDigits;

  /// Insert [groupSeparator] every three integer digits.
  final bool useGrouping;
  final CdsNumberNotation notation;
  final CdsNumberSignDisplay signDisplay;
  final String decimalSeparator;
  final String groupSeparator;

  /// Custom formatter set through [CdsNumberFormat.custom]. Overrides every other option.
  final String Function(num value)? formatter;

  /// Formats [value] to a string.
  String format(num value) {
    if (formatter != null) return formatter!(value);
    if (value.isNaN) return 'NaN';

    var v = value.toDouble();
    if (style == CdsNumberFormatStyle.percent) v *= 100;
    final negative = v < 0 || (v == 0 && v.isNegative);
    var magnitude = v.abs();

    var compactSuffix = '';
    int? compactFraction;
    if (notation == CdsNumberNotation.compact && magnitude.isFinite) {
      (magnitude, compactSuffix, compactFraction) = _compact(magnitude);
    }

    final (defaultMin, defaultMax) = switch (style) {
      CdsNumberFormatStyle.decimal => (0, 3),
      CdsNumberFormatStyle.currency => (2, 2),
      CdsNumberFormatStyle.percent => (0, 0),
    };
    var maxFraction = maximumFractionDigits ?? compactFraction ?? defaultMax;
    final minFraction = math.min(minimumFractionDigits ?? (compactFraction != null ? 0 : defaultMin), 20);
    maxFraction = math.max(math.min(maxFraction, 20), minFraction);

    final String body;
    if (magnitude.isInfinite) {
      body = '∞';
    } else {
      body = _digits(magnitude, minFraction, maxFraction);
    }
    final isZero = magnitude == 0 || RegExp(r'^[0.,]*$').hasMatch(body.replaceAll(groupSeparator, ''));

    final sign = switch (signDisplay) {
      CdsNumberSignDisplay.auto => negative ? '-' : '',
      CdsNumberSignDisplay.always => negative ? '-' : '+',
      CdsNumberSignDisplay.exceptZero => isZero ? '' : (negative ? '-' : '+'),
      CdsNumberSignDisplay.never => '',
    };

    return switch (style) {
      CdsNumberFormatStyle.currency => '$sign$currencySymbol$body$compactSuffix',
      CdsNumberFormatStyle.percent => '$sign$body$compactSuffix%',
      CdsNumberFormatStyle.decimal => '$sign$body$compactSuffix',
    };
  }

  static const _compactUnits = [(1e12, 'T'), (1e9, 'B'), (1e6, 'M'), (1e3, 'K')];

  (double, String, int?) _compact(double magnitude) {
    for (var i = 0; i < _compactUnits.length; i++) {
      final (divisor, suffix) = _compactUnits[i];
      if (magnitude >= divisor) {
        final scaled = magnitude / divisor;
        final fraction = maximumFractionDigits ?? _significantFraction(scaled);
        // 999.95K rounds to 1000K; promote it to the next unit so it reads 1M.
        if (i > 0 && double.parse(scaled.toStringAsFixed(fraction)) >= 1000) {
          final (nextDivisor, nextSuffix) = _compactUnits[i - 1];
          final next = magnitude / nextDivisor;
          return (next, nextSuffix, _significantFraction(next));
        }
        return (scaled, suffix, _significantFraction(scaled));
      }
    }
    return (magnitude, '', _significantFraction(magnitude));
  }

  static int _significantFraction(double v) {
    if (v == 0) return 0;
    if (v < 1) return 2;
    final integerDigits = (math.log(v) / math.ln10).floor() + 1;
    return math.max(0, 2 - integerDigits);
  }

  String _digits(double magnitude, int minFraction, int maxFraction) {
    // toStringAsFixed switches to exponent notation at 1e21; clamp to keep digits.
    final fixed = magnitude >= 1e21 ? magnitude.toStringAsFixed(0) : magnitude.toStringAsFixed(maxFraction);
    final dot = fixed.indexOf('.');
    var integer = dot < 0 ? fixed : fixed.substring(0, dot);
    var fraction = dot < 0 ? '' : fixed.substring(dot + 1);
    while (fraction.length > minFraction && fraction.endsWith('0')) {
      fraction = fraction.substring(0, fraction.length - 1);
    }
    if (useGrouping && integer.length > 3) {
      final buffer = StringBuffer();
      for (var i = 0; i < integer.length; i++) {
        if (i > 0 && (integer.length - i) % 3 == 0) buffer.write(groupSeparator);
        buffer.write(integer[i]);
      }
      integer = buffer.toString();
    }
    return fraction.isEmpty ? integer : '$integer$decimalSeparator$fraction';
  }

  @override
  bool operator ==(Object other) =>
      other is CdsNumberFormat &&
      other.style == style &&
      other.currencySymbol == currencySymbol &&
      other.minimumFractionDigits == minimumFractionDigits &&
      other.maximumFractionDigits == maximumFractionDigits &&
      other.useGrouping == useGrouping &&
      other.notation == notation &&
      other.signDisplay == signDisplay &&
      other.decimalSeparator == decimalSeparator &&
      other.groupSeparator == groupSeparator &&
      other.formatter == formatter;

  @override
  int get hashCode => Object.hash(style, currencySymbol, minimumFractionDigits, maximumFractionDigits,
      useGrouping, notation, signDisplay, decimalSeparator, groupSeparator, formatter);
}
