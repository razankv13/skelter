import 'package:flutter/material.dart';
import 'package:skelter/widgets/styling/app_colors.dart';

class PaymentFailedIcon extends StatelessWidget {
  const PaymentFailedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.redError700,
      child: Icon(Icons.close_rounded, color: AppColors.white, size: 50),
    );
  }
}
