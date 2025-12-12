import 'package:dartz/dartz.dart';
import 'package:skelter/core/errors/exceptions.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/utils/currency_converter/data/datasources/currency_converter_remote_data_source.dart';
import 'package:skelter/utils/currency_converter/data/models/currency_rate_model.dart';
import 'package:skelter/utils/currency_converter/domain/entities/currency_rate.dart';
import 'package:skelter/utils/currency_converter/domain/repositories/currency_converter_repository.dart';
import 'package:skelter/utils/typedef.dart';

class CurrencyConverterRepositoryImpl with CurrencyConverterRepository {
  const CurrencyConverterRepositoryImpl(this._remoteDatasource);

  final CurrencyConverterRemoteDatasource _remoteDatasource;

  @override
  ResultFuture<CurrencyRate> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final CurrencyRateModel result = await _remoteDatasource.getExchangeRate(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
      return Right(result);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    }
  }
}
