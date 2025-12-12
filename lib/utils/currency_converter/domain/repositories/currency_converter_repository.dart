import 'package:skelter/utils/currency_converter/domain/entities/currency_rate.dart';
import 'package:skelter/utils/typedef.dart';

mixin CurrencyConverterRepository {
  ResultFuture<CurrencyRate> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  });
}
