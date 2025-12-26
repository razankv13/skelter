import 'package:skelter/presentation/product_detail/domain/entities/ai_product_description.dart';
import 'package:skelter/utils/typedef.dart';

class AiProductDescriptionModel extends AiProductDescription {
  const AiProductDescriptionModel({
    required super.productId,
    required super.generatedDescription,
    required super.generatedAt,
    super.isPersonalized,
  });

  factory AiProductDescriptionModel.fromEntity(
    AiProductDescription entity,
  ) {
    return AiProductDescriptionModel(
      productId: entity.productId,
      generatedDescription: entity.generatedDescription,
      generatedAt: entity.generatedAt,
      isPersonalized: entity.isPersonalized,
    );
  }

  factory AiProductDescriptionModel.fromMap(DataMap map) {
    return AiProductDescriptionModel(
      productId: map['productId'] as String,
      generatedDescription: map['generatedDescription'] as String,
      generatedAt: DateTime.parse(map['generatedAt'] as String),
      isPersonalized: map['isPersonalized'] as bool? ?? false,
    );
  }

  DataMap toMap() {
    return {
      'productId': productId,
      'generatedDescription': generatedDescription,
      'generatedAt': generatedAt.toIso8601String(),
      'isPersonalized': isPersonalized,
    };
  }

  factory AiProductDescriptionModel.fromGeneratedText({
    required String productId,
    required String generatedText,
    bool isPersonalized = false,
  }) {
    return AiProductDescriptionModel(
      productId: productId,
      generatedDescription: generatedText,
      generatedAt: DateTime.now(),
      isPersonalized: isPersonalized,
    );
  }

  AiProductDescription toEntity() {
    return AiProductDescription(
      productId: productId,
      generatedDescription: generatedDescription,
      generatedAt: generatedAt,
      isPersonalized: isPersonalized,
    );
  }
}

