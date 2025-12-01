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

    group('Top 15 Countries Currency Support', () {
      testWidgets(
        'formatCurrency displays USD symbol for United States',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(context.formatCurrency(1250.99));
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('\$'), findsOneWidget);
          expect(find.textContaining('1,250.99'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays EUR symbol when '
        'currency code is overridden to EUR',
        (tester) async {
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
          expect(find.textContaining('€'), findsOneWidget);
          expect(find.textContaining('100.00'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays GBP symbol for British Pound currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(500.50, currencyCode: 'GBP'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('£'), findsOneWidget);
          expect(find.textContaining('500.50'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays JPY symbol for Japanese Yen currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(100000, currencyCode: 'JPY'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('¥'), findsOneWidget);
          expect(find.textContaining('100,000'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays CHF symbol for Swiss Franc currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(250.75, currencyCode: 'CHF'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('CHF'), findsOneWidget);
          expect(find.textContaining('250.75'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays CAD symbol for Canadian Dollar currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(350.25, currencyCode: 'CAD'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('\$'), findsOneWidget);
          expect(find.textContaining('350.25'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays AUD symbol for '
        'Australian Dollar currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(450.00, currencyCode: 'AUD'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('\$'), findsOneWidget);
          expect(find.textContaining('450.00'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays CNY symbol for Chinese Yuan currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(600.50, currencyCode: 'CNY'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('¥'), findsOneWidget);
          expect(find.textContaining('600.50'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays INR symbol for Indian Rupee currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(5000.00, currencyCode: 'INR'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('₹'), findsOneWidget);
          expect(find.textContaining('5,000.00'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays SGD symbol for Singapore Dollar currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(150.75, currencyCode: 'SGD'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('\$'), findsOneWidget);
          expect(find.textContaining('150.75'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays HKD symbol for Hong Kong Dollar currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(800.25, currencyCode: 'HKD'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('\$'), findsOneWidget);
          expect(find.textContaining('800.25'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays MXN symbol for Mexican Peso currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(2000.50, currencyCode: 'MXN'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('\$'), findsOneWidget);
          expect(find.textContaining('2,000.50'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays BRL symbol for Brazilian Real currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(1500.75, currencyCode: 'BRL'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('R'), findsOneWidget);
          expect(find.textContaining('1,500.75'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays KRW symbol for South Korean Won currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(50000.00, currencyCode: 'KRW'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('₩'), findsOneWidget);
          expect(find.textContaining('50,000'), findsOneWidget);
        },
      );

      testWidgets(
        'formatCurrency displays THB symbol for Thai Baht currency code',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Text(
                      context.formatCurrency(8000.50, currencyCode: 'THB'),
                    );
                  },
                ),
              ),
            ),
          );
          expect(find.textContaining('฿'), findsOneWidget);
          expect(find.textContaining('8,000.50'), findsOneWidget);
        },
      );
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
        expect(find.textContaining('¥'), findsOneWidget);
        expect(find.textContaining('99.99'), findsOneWidget);
      });

      testWidgets('symbol override with pound', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    context.formatCurrency(50, symbolOverride: '£'),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.textContaining('£'), findsOneWidget);
        expect(find.textContaining('50.00'), findsOneWidget);
      });
    });

    group('Custom Separators', () {
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
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.textContaining('1.234.567,89'), findsOneWidget);
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
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.textContaining('1#234#568'), findsOneWidget);
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
                    ),
                  );
                },
              ),
            ),
          ),
        );
        expect(find.textContaining(':::'), findsOneWidget);
        expect(find.textContaining('1,234.56'), findsOneWidget);
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
        expect(find.textContaining('1.5M'), findsOneWidget);
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
        expect(find.textContaining('€'), findsOneWidget);
        expect(find.textContaining('1.5M'), findsOneWidget);
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
    });

    group('Fallback Behavior', () {
      testWidgets('uses fallback locale when AppLocalizations is missing',
          (tester) async {
        await tester.pumpWidget(testWidget);
        expect(find.text(r'$1,234.56'), findsOneWidget);
      });
    });
  });
}
