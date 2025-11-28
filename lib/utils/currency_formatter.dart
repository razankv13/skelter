import 'dart:math';
import 'package:intl/intl.dart';

enum CompactFormatType {
  none,
  short,
  long,
}

enum CurrencySymbolPosition {
  left,
  right,
  defaultLocale,
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(
    dynamic amount, {
    required String locale,
    String? currencyCode,
    int? decimalDigits,
    bool shouldShowSymbol = true,
    String? symbolOverride,
    CurrencySymbolPosition symbolSide = CurrencySymbolPosition.defaultLocale,
    String? groupingSeparator,
    String? decimalSeparator,
    String? symbolSeparator,
    CompactFormatType compactFormatType = CompactFormatType.none,
    String fallbackValue = '0.00',
  }) {
    if (amount == null) return fallbackValue;

    num? numericAmount;
    if (amount is num) {
      numericAmount = amount;
    } else if (amount is String) {
      numericAmount = num.tryParse(amount);
    }
    if (numericAmount == null) return fallbackValue;

    try {
      final resolvedCurrencyCode =
          currencyCode ?? _getCurrencyCodeForLocale(locale);

      final useCustomFormatting = groupingSeparator != null ||
          decimalSeparator != null ||
          symbolSeparator != null ||
          symbolSide != CurrencySymbolPosition.defaultLocale;

      if (useCustomFormatting && compactFormatType == CompactFormatType.none) {
        return _formatCustomCurrency(
          numericAmount,
          locale: locale,
          currencyCode: resolvedCurrencyCode,
          decimalDigits: decimalDigits,
          shouldShowSymbol: shouldShowSymbol,
          symbolOverride: symbolOverride,
          symbolSide: symbolSide,
          groupingSeparator: groupingSeparator,
          decimalSeparator: decimalSeparator,
          symbolSeparator: symbolSeparator,
        );
      }

      final numberFormatter = _createNumberFormatter(
        locale: locale,
        currencyCode: resolvedCurrencyCode,
        decimalDigits: decimalDigits,
        shouldShowSymbol: shouldShowSymbol,
        symbolOverride: symbolOverride,
        compactFormatType: compactFormatType,
      );

      return numberFormatter.format(numericAmount);
    } catch (_) {
      return fallbackValue;
    }
  }

  static String? _getCurrencyCodeForLocale(String locale) {
    try {
      return NumberFormat.simpleCurrency(locale: locale).currencyName;
    } catch (_) {
      return null;
    }
  }

  static String _formatCustomCurrency(
    num amount, {
    required String locale,
    String? currencyCode,
    int? decimalDigits,
    required bool shouldShowSymbol,
    String? symbolOverride,
    required CurrencySymbolPosition symbolSide,
    String? groupingSeparator,
    String? decimalSeparator,
    String? symbolSeparator,
  }) {
    final symbol = shouldShowSymbol
        ? symbolOverride ??
            NumberFormat.simpleCurrency(locale: locale, name: currencyCode)
                .currencySymbol
        : '';

    final numberFormat = NumberFormat.currency(locale: locale);

    final resolvedGroupingSeparator =
        groupingSeparator ?? numberFormat.symbols.GROUP_SEP;
    final resolvedDecimalSeparator =
        decimalSeparator ?? numberFormat.symbols.DECIMAL_SEP;
    final resolvedSymbolSeparator = symbolSeparator ?? '';
    final resolvedDecimalDigits = decimalDigits ?? 2;

    final isNegative = amount < 0;
    num absoluteAmount = amount.abs();

    if (resolvedDecimalDigits == 0) {
      absoluteAmount = absoluteAmount.round();
    }

    final integerPart = absoluteAmount.floor();
    final decimalPart =
        ((absoluteAmount - integerPart) * pow(10, resolvedDecimalDigits))
            .round();

    String integerString = integerPart.toString();

    if (resolvedGroupingSeparator.isNotEmpty && integerString.length > 3) {
      final buffer = StringBuffer();
      int counter = 0;
      for (int i = integerString.length - 1; i >= 0; i--) {
        if (counter == 3) {
          buffer.write(resolvedGroupingSeparator);
          counter = 0;
        }
        buffer.write(integerString[i]);
        counter++;
      }
      integerString = buffer.toString().split('').reversed.join();
    }

    final decimalString = resolvedDecimalDigits > 0
        ? decimalPart
            .toString()
            .padLeft(resolvedDecimalDigits, '0')
            .substring(0, resolvedDecimalDigits)
        : '';

    String formattedAmount = integerString +
        (decimalString.isNotEmpty
            ? '$resolvedDecimalSeparator$decimalString'
            : '');
    if (isNegative) formattedAmount = '-$formattedAmount';

    if (!shouldShowSymbol || symbol.isEmpty) return formattedAmount;

    final resolvedSide = symbolSide == CurrencySymbolPosition.defaultLocale
        ? _getCurrencySymbolPosition(locale, currencyCode)
        : symbolSide;

    return resolvedSide == CurrencySymbolPosition.left
        ? '$symbol$resolvedSymbolSeparator$formattedAmount'
        : '$formattedAmount$resolvedSymbolSeparator$symbol';
  }

  static CurrencySymbolPosition _getCurrencySymbolPosition(
    String locale,
    String? currencyCode,
  ) {
    try {
      final formattedSample = NumberFormat.simpleCurrency(
        locale: locale,
        name: currencyCode,
      ).format(100);

      final numberStartIndex = formattedSample.indexOf('100');
      final symbolPart = formattedSample.replaceAll(RegExp(r'\d'), '');
      final symbolStartIndex = formattedSample.indexOf(symbolPart);
      final isSymbolBeforeNumber = symbolStartIndex < numberStartIndex;

      return isSymbolBeforeNumber
          ? CurrencySymbolPosition.left
          : CurrencySymbolPosition.right;
    } catch (_) {
      return CurrencySymbolPosition.defaultLocale;
    }
  }

  static NumberFormat _createNumberFormatter({
    required String locale,
    String? currencyCode,
    int? decimalDigits,
    required bool shouldShowSymbol,
    String? symbolOverride,
    required CompactFormatType compactFormatType,
  }) {
    final resolvedSymbol = shouldShowSymbol
        ? symbolOverride ??
            NumberFormat.simpleCurrency(locale: locale, name: currencyCode)
                .currencySymbol
        : '';

    switch (compactFormatType) {
      case CompactFormatType.short:
        return NumberFormat.compactCurrency(
          locale: locale,
          name: currencyCode,
          symbol: resolvedSymbol,
          decimalDigits: decimalDigits,
        );
      case CompactFormatType.long:
        final formatter = NumberFormat.compactLong(locale: locale);
        if (decimalDigits != null) {
          formatter.minimumFractionDigits = decimalDigits;
          formatter.maximumFractionDigits = decimalDigits;
        }
        return formatter;
      case CompactFormatType.none:
        return NumberFormat.currency(
          locale: locale,
          name: currencyCode,
          symbol: resolvedSymbol,
          decimalDigits: decimalDigits,
        );
    }
  }
}
