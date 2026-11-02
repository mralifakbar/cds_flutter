import 'package:cds_flutter/src/numbers/cds_rolling_number_parts.dart';
import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

String _nine(num v) => '$v!';

void main() {
  group('CdsNumberFormat', () {
    test('decimal defaults group thousands and keep up to 3 fraction digits', () {
      expect(const CdsNumberFormat().format(1234.5678), '1,234.568');
      expect(const CdsNumberFormat().format(1234), '1,234');
      expect(const CdsNumberFormat().format(-0.5), '-0.5');
      expect(const CdsNumberFormat().format(1234567), '1,234,567');
    });

    test('currency uses two fraction digits and puts the sign first', () {
      expect(const CdsNumberFormat.currency().format(1234.5), r'$1,234.50');
      expect(const CdsNumberFormat.currency().format(-1234.5), r'-$1,234.50');
      expect(const CdsNumberFormat.currency(symbol: '€').format(3), '€3.00');
      expect(
        const CdsNumberFormat.currency(minimumFractionDigits: 0, maximumFractionDigits: 0).format(99.6),
        r'$100',
      );
    });

    test('percent multiplies by 100', () {
      expect(const CdsNumberFormat.percent().format(0.1234), '12%');
      expect(const CdsNumberFormat.percent(maximumFractionDigits: 2).format(0.12345), '12.35%');
      expect(const CdsNumberFormat.percent(minimumFractionDigits: 2).format(0.5), '50.00%');
    });

    test('compact notation keeps two significant digits and promotes units', () {
      const f = CdsNumberFormat(notation: CdsNumberNotation.compact);
      expect(f.format(98345.67), '98K');
      expect(f.format(1234), '1.2K');
      expect(f.format(123456), '123K');
      expect(f.format(999950), '1M');
      expect(f.format(2500000000), '2.5B');
      expect(f.format(999), '999');
      expect(
        const CdsNumberFormat.currency(
          notation: CdsNumberNotation.compact,
          minimumFractionDigits: 2,
          maximumFractionDigits: 5,
        ).format(98345.67),
        r'$98.34567K',
      );
    });

    test('signDisplay', () {
      expect(const CdsNumberFormat(signDisplay: CdsNumberSignDisplay.always).format(5), '+5');
      expect(const CdsNumberFormat(signDisplay: CdsNumberSignDisplay.always).format(0), '+0');
      expect(const CdsNumberFormat(signDisplay: CdsNumberSignDisplay.exceptZero).format(0), '0');
      expect(const CdsNumberFormat(signDisplay: CdsNumberSignDisplay.exceptZero).format(-2), '-2');
      expect(const CdsNumberFormat(signDisplay: CdsNumberSignDisplay.never).format(-2), '2');
    });

    test('grouping and separators', () {
      expect(const CdsNumberFormat(useGrouping: false).format(98345.67), '98345.67');
      expect(
        const CdsNumberFormat(decimalSeparator: ',', groupSeparator: '.').format(1234.5),
        '1.234,5',
      );
    });

    test('custom formatter and non-finite values', () {
      expect(const CdsNumberFormat.custom(_nine).format(3), '3!');
      expect(const CdsNumberFormat().format(double.nan), 'NaN');
      expect(const CdsNumberFormat().format(double.infinity), '∞');
    });

    test('equality', () {
      expect(const CdsNumberFormat.currency(), const CdsNumberFormat(style: CdsNumberFormatStyle.currency));
      expect(const CdsNumberFormat.currency() == const CdsNumberFormat.percent(), isFalse);
    });
  });

  group('splitRollingNumber', () {
    test('splits currency into pre, integer, fraction and post', () {
      final parts = splitRollingNumber(r'$98,345.67K');
      expect(parts.pre, [const RollingNumberPart.symbol('pre:0', r'$')]);
      expect(parts.integer.map((p) => p.toString()).toList(),
          ['integer:4=9', 'integer:3=8', 'group:0=","', 'integer:2=3', 'integer:1=4', 'integer:0=5']);
      expect(parts.fraction.map((p) => p.key).toList(), ['decimal:0', 'fraction:0', 'fraction:1']);
      expect(parts.post, [const RollingNumberPart.symbol('post:0', 'K')]);
    });

    test('integer keys count from the right so columns keep their place', () {
      final before = splitRollingNumber(r'$999').integer.map((p) => p.key).toList();
      final after = splitRollingNumber(r'$1,000').integer.map((p) => p.key).toList();
      expect(before, ['integer:2', 'integer:1', 'integer:0']);
      expect(after, ['integer:3', 'group:0', 'integer:2', 'integer:1', 'integer:0']);
    });

    test('subscript notation collapses leading fraction zeros', () {
      final parts = splitRollingNumber('0.00009', enableSubscriptNotation: true);
      expect(parts.fraction.map((p) => p.digit ?? p.text).toList(), ['.', 0, '₄', 9]);
      final single = splitRollingNumber('0.09', enableSubscriptNotation: true);
      expect(single.fraction.map((p) => p.digit ?? p.text).toList(), ['.', 0, 9]);
    });

    test('custom decimal separator', () {
      final parts = splitRollingNumber('1.234,5 €', decimalSeparator: ',');
      expect(parts.integer.where((p) => p.digit != null).length, 4);
      expect(parts.fraction.map((p) => p.digit ?? p.text).toList(), [',', 5]);
      expect(parts.post.single.text, ' €');
    });

    test('text without digits becomes a single symbol', () {
      final parts = splitRollingNumber('NaN');
      expect(parts.all.single.text, 'NaN');
      expect(splitRollingNumber('').all, isEmpty);
    });
  });
}
