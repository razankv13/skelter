import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/utils/extensions/build_context_ext.dart';
import 'package:skelter/widgets/app_button/app_button.dart';
import 'package:skelter/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:skelter/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:skelter/widgets/styling/app_colors.dart';

class RestoreSubscription extends StatefulWidget {
  const RestoreSubscription({super.key});

  @override
  State<RestoreSubscription> createState() => _RestoreSubscriptionState();
}

class _RestoreSubscriptionState extends State<RestoreSubscription> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: context.localization.restore_subscription,
      style: AppButtonStyle.textOrIcon,
      foregroundColor: AppColors.bgBrandDefault,
      isLoading: isLoading,
      size: AppButtonSize.extraLarge,
      onPressed: isLoading ? null : () => restorePurchases(context),
    );
  }

  Future<void> restorePurchases(BuildContext context) async {
    isLoading = true;
    setState(() {});
    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasEntitlement = customerInfo.entitlements.active.isNotEmpty;
      if (!context.mounted) return;

      context.showSnackBar(
        hasEntitlement
            ? context.localization.restore_success
            : context.localization.no_active_subscriptions,
      );
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      context.showSnackBar(
        '${context.localization.restore_error} $e',
      );
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }
}
