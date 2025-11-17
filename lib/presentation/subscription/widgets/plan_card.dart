import 'package:flutter/material.dart';
import 'package:skelter/common/theme/text_style/app_text_styles.dart';
import 'package:skelter/widgets/styling/app_colors.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final String renewal;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCard({
    required this.title,
    required this.price,
    required this.duration,
    required this.renewal,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.bgBrandDefault : AppColors.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.h3Medium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          '$price/ ',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.bgBrandDefault,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        duration,
                        style: AppTextStyles.p4Regular,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    renewal,
                    style: AppTextStyles.p3Medium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.bgBrandDefault : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  width: isSelected ? 0 : 1,
                  color: isSelected ? AppColors.blue : AppColors.black,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
