import 'package:equatable/equatable.dart';
import 'package:skelter/core/usecase/usecase.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';
import 'package:skelter/presentation/product_detail/domain/repositories/ai_product_description_repository.dart';
import 'package:skelter/utils/typedef.dart';

/// Use case for generating AI-powered product descriptions
class GenerateAiProductDescription
    with
        UseCaseWithParams<
          AiProductDescription,
          GenerateAiProductDescriptionParams
        > {
  const GenerateAiProductDescription(this._repository);

  final AiProductDescriptionRepository _repository;

  @override
  ResultFuture<AiProductDescription> call(
    GenerateAiProductDescriptionParams params,
  ) async {
    return _repository.generateProductDescription(
      productDetail: params.productDetail,
      userOrderHistory: params.userOrderHistory,
    );
  }
}

/// Parameters for generating AI product description
class GenerateAiProductDescriptionParams extends Equatable {
  const GenerateAiProductDescriptionParams({
    required this.productDetail,
    this.userOrderHistory,
  });

  final ProductDetail productDetail;
  final List<String>? userOrderHistory;

  @override
  List<Object?> get props => [productDetail, userOrderHistory];
}
