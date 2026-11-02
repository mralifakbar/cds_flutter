import 'package:flutter/foundation.dart';

/// What a [RollingNumberPart] renders.
enum RollingNumberPartType { digit, symbol }

/// One glyph run of a formatted number, keyed so the same column keeps its
/// state (and animates) when the value changes.
///
/// Integer digits are keyed from the right and fraction digits from the
/// left, like CDS `IntlNumberFormat.formatToParts`, so going from `$999` to
/// `$1,000` keeps the ones column in place and adds a new column on the left.
@immutable
class RollingNumberPart {
  const RollingNumberPart.digit(this.key, int this.digit)
      : type = RollingNumberPartType.digit,
        text = null;

  const RollingNumberPart.symbol(this.key, String this.text)
      : type = RollingNumberPartType.symbol,
        digit = null;

  final String key;
  final RollingNumberPartType type;
  final int? digit;
  final String? text;

  @override
  bool operator ==(Object other) =>
      other is RollingNumberPart && other.key == key && other.digit == digit && other.text == text;

  @override
  int get hashCode => Object.hash(key, digit, text);

  @override
  String toString() => type == RollingNumberPartType.digit ? '$key=$digit' : '$key="$text"';
}

/// A formatted number split into the four sections CDS renders.
@immutable
class RollingNumberParts {
  const RollingNumberParts({
    required this.pre,
    required this.integer,
    required this.fraction,
    required this.post,
  });

  /// Text before the first digit: sign, currency symbol.
  final List<RollingNumberPart> pre;

  /// Integer digits and group separators.
  final List<RollingNumberPart> integer;

  /// Decimal separator and fraction digits.
  final List<RollingNumberPart> fraction;

  /// Text after the last digit: compact suffix, percent sign, unit.
  final List<RollingNumberPart> post;

  Iterable<RollingNumberPart> get all => [...pre, ...integer, ...fraction, ...post];
}

const _subscriptDigits = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];

bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;

/// Splits [formatted] into keyed parts. The numeric core runs from the first
/// to the last ASCII digit; [decimalSeparator] inside it starts the fraction.
///
/// With [enableSubscriptNotation], two or more leading zeros in the fraction
/// collapse to one zero plus a subscript count (`0.00009` becomes `0.0₄9`).
RollingNumberParts splitRollingNumber(
  String formatted, {
  String decimalSeparator = '.',
  bool enableSubscriptNotation = false,
}) {
  final units = formatted.codeUnits;
  final first = units.indexWhere(_isDigit);
  if (first < 0) {
    return RollingNumberParts(
      pre: formatted.isEmpty ? const [] : [RollingNumberPart.symbol('pre:0', formatted)],
      integer: const [],
      fraction: const [],
      post: const [],
    );
  }
  final last = units.lastIndexWhere(_isDigit);
  final preText = formatted.substring(0, first);
  final core = formatted.substring(first, last + 1);
  final postText = formatted.substring(last + 1);

  final decimalAt = decimalSeparator.isEmpty ? -1 : core.lastIndexOf(decimalSeparator);
  final integerText = decimalAt < 0 ? core : core.substring(0, decimalAt);
  final fractionText = decimalAt < 0 ? '' : core.substring(decimalAt + decimalSeparator.length);

  final integer = <RollingNumberPart>[];
  var digitCount = 0;
  var symbolCount = 0;
  for (var i = integerText.length - 1; i >= 0; i--) {
    final c = integerText.codeUnitAt(i);
    if (_isDigit(c)) {
      integer.add(RollingNumberPart.digit('integer:${digitCount++}', c - 0x30));
    } else {
      integer.add(RollingNumberPart.symbol('group:${symbolCount++}', integerText[i]));
    }
  }

  final fraction = <RollingNumberPart>[];
  if (decimalAt >= 0) fraction.add(RollingNumberPart.symbol('decimal:0', decimalSeparator));
  var fractionBody = fractionText;
  var fractionDigit = 0;
  var fractionSymbol = 0;
  if (enableSubscriptNotation) {
    final zeros = RegExp(r'^0+').firstMatch(fractionBody)?.group(0)?.length ?? 0;
    if (zeros > 1) {
      fraction.add(RollingNumberPart.digit('fraction:${fractionDigit++}', 0));
      final count = zeros.toString().split('').map((d) => _subscriptDigits[int.parse(d)]).join();
      fraction.add(RollingNumberPart.symbol('subscript:0', count));
      fractionBody = fractionBody.substring(zeros);
    }
  }
  for (var i = 0; i < fractionBody.length; i++) {
    final c = fractionBody.codeUnitAt(i);
    if (_isDigit(c)) {
      fraction.add(RollingNumberPart.digit('fraction:${fractionDigit++}', c - 0x30));
    } else {
      fraction.add(RollingNumberPart.symbol('fractionSymbol:${fractionSymbol++}', fractionBody[i]));
    }
  }

  return RollingNumberParts(
    pre: preText.isEmpty ? const [] : [RollingNumberPart.symbol('pre:0', preText)],
    integer: integer.reversed.toList(),
    fraction: fraction,
    post: postText.isEmpty ? const [] : [RollingNumberPart.symbol('post:0', postText)],
  );
}
