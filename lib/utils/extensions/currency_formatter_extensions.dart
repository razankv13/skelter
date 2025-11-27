import 'package:flutter/material.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/utils/currency_formatter.dart';

extension CurrencyFormatterExtensions on BuildContext {
  String formatCurrency(
    dynamic amount, {
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
    final locale = AppLocalizations.of(this)?.localeName;
    const fallbackLocale = 'en_US';

    return CurrencyFormatter.format(
      amount,
      locale: locale ?? fallbackLocale,
      currencyCode: currencyCode,
      decimalDigits: decimalDigits,
      shouldShowSymbol: shouldShowSymbol,
      symbolOverride: symbolOverride,
      symbolSide: symbolSide,
      groupingSeparator: groupingSeparator,
      decimalSeparator: decimalSeparator,
      symbolSeparator: symbolSeparator,
      compactFormatType: compactFormatType,
      fallbackValue: fallbackValue,
    );
  }
}
