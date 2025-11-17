import 'package:flutter/material.dart';
import 'package:skelter/widgets/styling/app_colors.dart';

class SubscriptionActivatedSuccessIcon extends StatelessWidget {
  const SubscriptionActivatedSuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.greenSuccess600,
      child: Icon(Icons.check, color: AppColors.white, size: 50),
    );
  }
}
