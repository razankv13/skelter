import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_event.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_state.dart';
import 'package:skelter/presentation/product_detail/domain/usecases/generate_ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/usecases/get_product_detail.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc({
    required GetProductDetail getProductDetail,
    required GenerateAiProductDescription generateAiProductDescription,
  })  : _getProductDetail = getProductDetail,
        _generateAiProductDescription = generateAiProductDescription,
        super(const ProductDetailState.initial()) {
    _setupEventListeners();
  }

  final GetProductDetail _getProductDetail;
  final GenerateAiProductDescription _generateAiProductDescription;

  void _setupEventListeners() {
    on<GetProductDetailDataEvent>(_onGetProductDetailDataEvent);
    on<ProductImageSelectedEvent>(_onProductImageSelectedEvent);
    on<GenerateAiDescriptionEvent>(_onGenerateAiDescriptionEvent);
  }

  void _onGetProductDetailDataEvent(
    GetProductDetailDataEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading(state));

    final result = await _getProductDetail(
      GetProductDetailParams(id: event.productId),
    );

    result.fold(
      (failure) => emit(
        ProductDetailErrorState(state, errorMessage: failure.errorMessage),
      ),
      (productDetail) => emit(
        ProductDetailLoadedState(
          state,
          productDetail: productDetail,
        ),
      ),
    );
  }

  void _onProductImageSelectedEvent(
    ProductImageSelectedEvent event,
    Emitter<ProductDetailState> emit,
  ) {
    emit(
      state.copyWith(selectedImageIndex: event.selectedIndex),
    );
  }

  void _onGenerateAiDescriptionEvent(
    GenerateAiDescriptionEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    debugPrint('[AI Description] Starting generation...');
    emit(AiDescriptionGenerating(state));

    try {
      final result = await _generateAiProductDescription(
        GenerateAiProductDescriptionParams(
          productDetail: event.productDetail,
          userOrderHistory: event.userOrderHistory,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('[AI Description] Error: ${failure.errorMessage}');
          emit(
            AiDescriptionError(state, errorMessage: failure.errorMessage),
          );
        },
        (aiDescription) {
          debugPrint('[AI Description] Success: Generated description');
          emit(
            AiDescriptionGenerated(
              state,
              aiDescription: aiDescription,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('[AI Description] Exception: $e');
      emit(
        AiDescriptionError(
          state,
          errorMessage: 'Failed to generate AI description: $e',
        ),
      );
    }
  }
}
