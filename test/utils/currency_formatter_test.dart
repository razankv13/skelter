import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/utils/currency_formatter.dart';

void main() {
  const usdLocale = 'en_US';
  const inrLocale = 'en_IN';

  /*
  NOTE:
  The `r` prefix makes the string a raw literal.
  Special characters like `$` are treated literally, not interpolated.
  Used here to accurately test currency symbols in formatted strings.
*/

  group('CurrencyFormatter Full Test Suite', () {
    group('Basic Formatting', () {
      test('formats positive numbers', () {
        expect(
          CurrencyFormatter.format(1234.56, locale: usdLocale),
          r'$1,234.56',
        );
      });

      test('formats zero', () {
        expect(CurrencyFormatter.format(0, locale: usdLocale), r'$0.00');
      });

      test('formats negative numbers', () {
        expect(CurrencyFormatter.format(-50.25, locale: usdLocale), r'-$50.25');
      });

      test('formats large numbers', () {
        expect(
          CurrencyFormatter.format(1000000, locale: usdLocale),
          r'$1,000,000.00',
        );
      });
    });

    group('Locales', () {
      test('US locale uses correct symbol and grouping', () {
        expect(CurrencyFormatter.format(125.99, locale: usdLocale), r'$125.99');
      });

      test('IN locale uses correct Lakh/Crore grouping', () {
        const amount = 1259999.99;
        final result = CurrencyFormatter.format(amount, locale: inrLocale);
        expect(result, contains('12,59,999.99'));
      });

      test('Override currency code to EUR', () {
        final result = CurrencyFormatter.format(
          100.00,
          currencyCode: 'EUR',
          locale: usdLocale,
        );
        expect(result, contains('€100.00'));
      });
    });

    group('Decimal Digits', () {
      test('default 2 decimals', () {
        expect(
          CurrencyFormatter.format(1234.56789, locale: usdLocale),
          r'$1,234.57',
        );
      });

      test('0 decimals rounding', () {
        expect(
          CurrencyFormatter.format(
            1234.56789,
            decimalDigits: 0,
            locale: usdLocale,
          ),
          r'$1,235',
        );
      });

      test('3 decimals', () {
        expect(
          CurrencyFormatter.format(
            1234.56789,
            decimalDigits: 3,
            locale: usdLocale,
          ),
          r'$1,234.568',
        );
      });
    });

    group('Symbol Options', () {
      test('hide symbol', () {
        expect(
          CurrencyFormatter.format(
            99.99,
            shouldShowSymbol: false,
            locale: usdLocale,
          ),
          '99.99',
        );
      });

      test('custom symbol override', () {
        final result = CurrencyFormatter.format(
          99.99,
          symbolOverride: '¥',
          locale: usdLocale,
        );
        expect(result, contains('¥99.99'));
      });
    });

    group('Custom Separators and Position', () {
      test('custom grouping . and decimal ,', () {
        final result = CurrencyFormatter.format(
          1234567.89,
          groupingSeparator: '.',
          decimalSeparator: ',',
          locale: usdLocale,
        );
        expect(result, contains('1.234.567,89 \$'));
      });

      test('custom grouping # and 0 decimals', () {
        final result = CurrencyFormatter.format(
          1234567.89,
          groupingSeparator: '#',
          decimalDigits: 0,
          locale: usdLocale,
        );
        expect(result, contains('1#234#568 \$'));
      });

      test('custom symbol separator', () {
        final result = CurrencyFormatter.format(
          1234.56,
          symbolSeparator: ':::',
          locale: usdLocale,
        );
        expect(result, contains('1,234.56:::'));
        expect(result, endsWith('\$'));
      });

      test('symbol explicit left', () {
        final result = CurrencyFormatter.format(
          99.99,
          symbolSide: CurrencySymbolPosition.left,
          locale: usdLocale,
        );
        expect(result.indexOf(r'$'), lessThan(result.indexOf('99.99')));
      });

      test('symbol explicit right', () {
        final result = CurrencyFormatter.format(
          99.99,
          symbolSide: CurrencySymbolPosition.right,
          locale: usdLocale,
        );
        expect(result.indexOf('99.99'), lessThan(result.indexOf(r'$')));
      });
    });

    group('Compact Format', () {
      test('short format', () {
        final result = CurrencyFormatter.format(
          1500000,
          compactFormatType: CompactFormatType.short,
          locale: usdLocale,
        );
        expect(result, r'$1.5M');
      });

      test('long format', () {
        final result = CurrencyFormatter.format(
          1200000,
          compactFormatType: CompactFormatType.long,
          locale: usdLocale,
        );
        expect(result.toLowerCase(), contains('million'));
        expect(result, contains('1.2'));
      });

      test('compact with custom symbol', () {
        final result = CurrencyFormatter.format(
          1500000,
          compactFormatType: CompactFormatType.short,
          symbolOverride: '€',
          locale: usdLocale,
        );
        expect(result, contains('€1.5M'));
      });
    });

    group('Input Types & Edge Cases', () {
      test('string numeric input', () {
        expect(
          CurrencyFormatter.format('123.45', locale: usdLocale),
          r'$123.45',
        );
      });

      test('int input', () {
        expect(CurrencyFormatter.format(100, locale: usdLocale), r'$100.00');
      });

      test('null input fallback', () {
        expect(CurrencyFormatter.format(null, locale: usdLocale), '0.00');
      });

      test('invalid string fallback', () {
        expect(CurrencyFormatter.format('abc', locale: usdLocale), '0.00');
      });

      test('decimal rounding edge', () {
        expect(CurrencyFormatter.format(99.999, locale: usdLocale), r'$100.00');
      });

      test('negative zero', () {
        expect(CurrencyFormatter.format(-0, locale: usdLocale), r'$0.00');
      });

      test('large number with decimals', () {
        expect(
          CurrencyFormatter.format(
            1234567890.123,
            decimalDigits: 3,
            locale: usdLocale,
          ),
          r'$1,234,567,890.123',
        );
      });

      test('small decimal rounding', () {
        expect(
          CurrencyFormatter.format(
            0.0049,
            decimalDigits: 2,
            locale: usdLocale,
          ),
          r'$0.00',
        );
      });

      test('1 digit decimal', () {
        expect(
          CurrencyFormatter.format(1.5, decimalDigits: 1, locale: usdLocale),
          r'$1.5',
        );
      });

      test('symbol override with left side', () {
        final result = CurrencyFormatter.format(
          50,
          symbolOverride: '£',
          symbolSide: CurrencySymbolPosition.left,
          locale: usdLocale,
        );
        expect(result, startsWith('£'));
      });

      test('symbol override with right side', () {
        final result = CurrencyFormatter.format(
          50,
          symbolOverride: '£',
          symbolSide: CurrencySymbolPosition.right,
          locale: usdLocale,
        );
        expect(result, endsWith('£'));
      });
    });
  });
}
