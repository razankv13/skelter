import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skelter/utils/currency_formatter.dart';
import 'package:skelter/utils/extensions/currency_formatter_extensions.dart';

void main() {
  group('CurrencyFormatterExtensions Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Text(context.formatCurrency(1234.56));
            },
          ),
        ),
      );
    });

    group('Basic Formatting', () {
      testWidgets('formats positive numbers with default setup',
          (tester) async {
        await tester.pumpWidget(testWidget);
        expect(find.text(r'$1,234.56'), findsOneWidget);
      });

      testWidgets('formats zero', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(0));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$0.00'), findsOneWidget);
      });

      testWidgets('formats negative numbers', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(-50.25));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'-$50.25'), findsOneWidget);
      });

      testWidgets('formats large numbers', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(1000000));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$1,000,000.00'), findsOneWidget);
      });
    });

    group('Locales', () {
      testWidgets('US locale uses correct symbol and grouping', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en', 'US'),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(125.99));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$125.99'), findsOneWidget);
      });

      testWidgets('Override currency code to EUR', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(100.00, currencyCode: 'EUR'),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text('€100.00'), findsOneWidget);
      });
    });

    group('Decimal Digits', () {
      testWidgets('default 2 decimals', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(1234.56789));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$1,234.57'), findsOneWidget);
      });

      testWidgets('0 decimals rounding', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(1234.56789, decimalDigits: 0),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$1,235'), findsOneWidget);
      });

      testWidgets('3 decimals', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(1234.56789, decimalDigits: 3),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$1,234.568'), findsOneWidget);
      });
    });

    group('Symbol Options', () {
      testWidgets('hide symbol', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(99.99, shouldShowSymbol: false),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text('99.99'), findsOneWidget);
      });

      testWidgets('custom symbol override', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(99.99, symbolOverride: '¥'),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text('¥99.99'), findsOneWidget);
      });
    });

    group('Custom Separators and Position', () {
      testWidgets('custom grouping . and decimal ,', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      1234567.89,
                      groupingSeparator: '.',
                      decimalSeparator: ',',
                      symbolSide: CurrencySymbolPosition.right,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text('1.234.567,89 \$'), findsOneWidget);
      });

      testWidgets('custom grouping # and 0 decimals', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      1234567.89,
                      groupingSeparator: '#',
                      decimalDigits: 0,
                      symbolSide: CurrencySymbolPosition.right,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text('1#234#568 \$'), findsOneWidget);
      });

      testWidgets('custom symbol separator', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      1234.56,
                      symbolSeparator: ':::',
                      symbolSide: CurrencySymbolPosition.right,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text('1,234.56::: \$'), findsOneWidget);
      });

      testWidgets('symbol explicit left', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      99.99,
                      symbolSide: CurrencySymbolPosition.left,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$99.99'), findsOneWidget);
      });

      testWidgets('symbol explicit right', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      99.99,
                      symbolSide: CurrencySymbolPosition.right,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text(r'99.99 $'), findsOneWidget);
      });
    });

    group('Compact Format', () {
      testWidgets('short format', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      1500000,
                      compactFormatType: CompactFormatType.short,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$1.5M'), findsOneWidget);
      });

      testWidgets('long format', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      1200000,
                      compactFormatType: CompactFormatType.long,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.textContaining('million'), findsOneWidget);
        expect(find.textContaining('1.2'), findsOneWidget);
      });

      testWidgets('compact with custom symbol', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      1500000,
                      compactFormatType: CompactFormatType.short,
                      symbolOverride: '€',
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text('€1.5M'), findsOneWidget);
      });
    });

    group('Input Types & Edge Cases', () {
      testWidgets('string numeric input', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency('123.45'));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$123.45'), findsOneWidget);
      });

      testWidgets('int input', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(100));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$100.00'), findsOneWidget);
      });

      testWidgets('null input fallback', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(null));
                },
              ),
            ),
          ),
        );
        expect(find.text('0.00'), findsOneWidget);
      });

      testWidgets('invalid string fallback', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency('abc'));
                },
              ),
            ),
          ),
        );
        expect(find.text('0.00'), findsOneWidget);
      });

      testWidgets('decimal rounding edge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(99.999));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$100.00'), findsOneWidget);
      });

      testWidgets('negative zero', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(-0));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$0.00'), findsOneWidget);
      });

      testWidgets('large number with decimals', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      1234567890.123,
                      decimalDigits: 3,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$1,234,567,890.123'), findsOneWidget);
      });

      testWidgets('small decimal rounding', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      0.0049,
                      decimalDigits: 2,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$0.00'), findsOneWidget);
      });

      testWidgets('1 digit decimal', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(1.5, decimalDigits: 1),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$1.5'), findsOneWidget);
      });

      testWidgets('symbol override with left side', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      50,
                      symbolOverride: '£',
                      symbolSide: CurrencySymbolPosition.left,
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('£50.00'), findsOneWidget);
      });

      testWidgets('symbol override with right side', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(
                      50,
                      symbolOverride: '£',
                      symbolSide: CurrencySymbolPosition.right,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.text('50.00 £'), findsOneWidget);
      });
    });

    group('Fallback Behavior', () {
      testWidgets('uses fallback locale when AppLocalizations is missing',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(context.formatCurrency(1234.56));
                },
              ),
            ),
          ),
        );
        expect(find.text(r'$1,234.56'), findsOneWidget);
      });
    });
  });
}
