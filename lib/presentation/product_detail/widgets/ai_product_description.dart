import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skelter/common/theme/text_style/app_text_styles.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_bloc.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_event.dart';
import 'package:skelter/presentation/product_detail/bloc/product_detail_state.dart';
import 'package:skelter/presentation/product_detail/domain/entities/product_detail.dart';
import 'package:skelter/utils/theme/extention/theme_extension.dart';

class AIProductDescription extends StatelessWidget {
  final ProductDetail productDetail;
  final List<String>? userOrderHistory;

  const AIProductDescription({
    super.key,
    required this.productDetail,
    this.userOrderHistory,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      buildWhen: (previous, current) =>
          previous.isGeneratingAIDescription !=
              current.isGeneratingAIDescription ||
          previous.aiDescription != current.aiDescription ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        final hasAIDescription = state.aiDescription != null;
        final isGenerating = state.isGeneratingAIDescription;
        final hasError = state is AIDescriptionError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, hasAIDescription, isGenerating),
            const SizedBox(height: 12),
            if (isGenerating)
              _buildLoadingShimmer(context)
            else if (hasError)
              _buildErrorState(context, state)
            else if (hasAIDescription)
              _buildAIDescriptionContent(context, state)
            else
              _buildGenerateButton(context),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool hasAIDescription,
    bool isGenerating,
  ) {
    return Row(
      children: [
        Icon(
          Icons.auto_awesome,
          size: 20,
          color: context.currentTheme.textBrandPrimary,
        ),
        const SizedBox(width: 8),
        Text(
          hasAIDescription
              ? context.localization.ai_powered_description
              : context.localization.get_ai_description,
          style: AppTextStyles.p2Bold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        if (userOrderHistory != null && userOrderHistory!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.currentTheme.bgBrandLight50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.localization.personalized,
                style: AppTextStyles.p4Medium.copyWith(
                  color: context.currentTheme.textBrandPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    return InkWell(
      onTap: () => _generateAIDescription(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.currentTheme.strokeBrandDefault,
          ),
          borderRadius: BorderRadius.circular(12),
          color: context.currentTheme.bgBrandLight50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              color: context.currentTheme.textBrandPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              context.localization.generate_ai_description,
              style: AppTextStyles.p3Medium.copyWith(
                color: context.currentTheme.textBrandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.currentTheme.bgNeutralLight100,
      highlightColor: context.currentTheme.bgNeutralLight50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ProductDetailState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.currentTheme.bgErrorLight50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.currentTheme.strokeErrorDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: context.currentTheme.textErrorPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.localization.failed_to_load_subscriptions,
                  style: AppTextStyles.p3Bold.copyWith(
                    color: context.currentTheme.textErrorPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: AppTextStyles.p4Regular.copyWith(
                color: context.currentTheme.textErrorSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _generateAIDescription(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.currentTheme.bgErrorDefault,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 16,
                    color: context.currentTheme.textNeutralWhite,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.localization.try_again,
                    style: AppTextStyles.p4Medium.copyWith(
                      color: context.currentTheme.textNeutralWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIDescriptionContent(
    BuildContext context,
    ProductDetailState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.currentTheme.bgSurfaceBase,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.currentTheme.strokeBrandDefault,
            ),
          ),
          child: Text(
            state.aiDescription!.generatedDescription,
            style: AppTextStyles.p3Medium.copyWith(
              color: context.currentTheme.textNeutralPrimary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.localization.generated_by_ai,
              style: AppTextStyles.p4Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _generateAIDescription(context),
              icon: Icon(
                Icons.refresh,
                size: 16,
                color: context.currentTheme.textBrandPrimary,
              ),
              label: Text(
                context.localization.regenerate,
                style: AppTextStyles.p4Medium.copyWith(
                  color: context.currentTheme.textBrandPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _generateAIDescription(BuildContext context) {
    context.read<ProductDetailBloc>().add(
          GenerateAIDescriptionEvent(
            productDetail: productDetail,
            userOrderHistory: userOrderHistory,
          ),
        );
  }
}

