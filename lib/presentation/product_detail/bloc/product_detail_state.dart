import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';

class ProductDetailState with EquatableMixin {
  final int selectedImageIndex;
  final ProductDetail? productDetail;
  final String? errorMessage;
  final AiProductDescription? aiDescription;
  final bool isGeneratingAiDescription;

  const ProductDetailState({
    required this.selectedImageIndex,
    this.productDetail,
    this.errorMessage,
    this.aiDescription,
    this.isGeneratingAiDescription = false,
  });

  const ProductDetailState.initial()
      : selectedImageIndex = 0,
        productDetail = null,
        errorMessage = null,
        aiDescription = null,
        isGeneratingAiDescription = false;

  ProductDetailState.copy(ProductDetailState state)
      : selectedImageIndex = state.selectedImageIndex,
        productDetail = state.productDetail,
        errorMessage = state.errorMessage,
        aiDescription = state.aiDescription,
        isGeneratingAiDescription = state.isGeneratingAiDescription;

  ProductDetailState copyWith({
    int? selectedImageIndex,
    ProductDetail? productDetail,
    String? errorMessage,
    AiProductDescription? aiDescription,
    bool? isGeneratingAiDescription,
  }) {
    return ProductDetailState(
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      productDetail: productDetail ?? this.productDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      aiDescription: aiDescription ?? this.aiDescription,
      isGeneratingAiDescription:
          isGeneratingAiDescription ?? this.isGeneratingAiDescription,
    );
  }

  @visibleForTesting
  const ProductDetailState.test({
    this.selectedImageIndex = 0,
    this.productDetail,
    this.errorMessage,
    this.aiDescription,
    this.isGeneratingAiDescription = false,
  });

  @override
  List<Object?> get props => [
        selectedImageIndex,
        productDetail,
        errorMessage,
        aiDescription,
        isGeneratingAiDescription,
      ];
}

class ProductDetailLoading extends ProductDetailState {
  ProductDetailLoading(ProductDetailState state)
      : super.copy(
          state.copyWith(),
        );
}

class ProductDetailLoadedState extends ProductDetailState {
  ProductDetailLoadedState(
    ProductDetailState state, {
    required ProductDetail productDetail,
  }) : super.copy(
          state.copyWith(
            productDetail: productDetail,
          ),
        );
}

class ProductDetailErrorState extends ProductDetailState {
  ProductDetailErrorState(
    ProductDetailState state, {
    required String errorMessage,
  }) : super.copy(
          state.copyWith(errorMessage: errorMessage),
        );
}

class AiDescriptionGenerating extends ProductDetailState {
  AiDescriptionGenerating(ProductDetailState state)
      : super.copy(
          state.copyWith(isGeneratingAiDescription: true),
        );
}

class AiDescriptionGenerated extends ProductDetailState {
  AiDescriptionGenerated(
    ProductDetailState state, {
    required AiProductDescription aiDescription,
  }) : super.copy(
          state.copyWith(
            aiDescription: aiDescription,
            isGeneratingAiDescription: false,
          ),
        );
}

class AiDescriptionError extends ProductDetailState {
  AiDescriptionError(
    ProductDetailState state, {
    required String errorMessage,
  }) : super.copy(
          state.copyWith(
            errorMessage: errorMessage,
            isGeneratingAiDescription: false,
          ),
        );
}

