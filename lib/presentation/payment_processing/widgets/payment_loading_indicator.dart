import 'package:flutter/material.dart';
import 'package:skelter/widgets/styling/app_colors.dart';

class PaymentLoadingIndicator extends StatelessWidget {
  const PaymentLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 80,
        width: 80,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgBrandDefault),
          backgroundColor: AppColors.bgBrandDefault,
          strokeWidth: 6.25,
        ),
      ),
    );
  }
}
