import 'package:dartz/dartz.dart';
import 'package:skelter/core/errors/failure.dart';
import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';

/// Repository interface for AI product description operations
abstract class AiProductDescriptionRepository {
  /// Generate AI-powered product description
  Future<Either<Failure, AiProductDescription>> generateProductDescription({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  });

  /// Generate AI description with streaming support
  Stream<Either<Failure, String>> generateProductDescriptionStream({
    required ProductDetail productDetail,
    List<String>? userOrderHistory,
  });
}

