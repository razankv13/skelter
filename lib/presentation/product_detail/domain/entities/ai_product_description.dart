import 'package:equatable/equatable.dart';

class AiProductDescription extends Equatable {
  const AiProductDescription({
    required this.productId,
    required this.generatedDescription,
    required this.generatedAt,
    this.isPersonalized = false,
  });

  final String productId;
  final String generatedDescription;
  final DateTime generatedAt;
  final bool isPersonalized;

  @override
  List<Object?> get props => [
        productId,
        generatedDescription,
        generatedAt,
        isPersonalized,
      ];

  AiProductDescription copyWith({
    String? productId,
    String? generatedDescription,
    DateTime? generatedAt,
    bool? isPersonalized,
  }) {
    return AiProductDescription(
      productId: productId ?? this.productId,
      generatedDescription: generatedDescription ?? this.generatedDescription,
      generatedAt: generatedAt ?? this.generatedAt,
      isPersonalized: isPersonalized ?? this.isPersonalized,
    );
  }
}

