import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:skelter/common/theme/text_style/app_text_styles.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/presentation/profile/constants/analytics_constant.dart';
import 'package:skelter/utils/theme/extention/theme_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class CancelSubscription extends StatelessWidget {
  const CancelSubscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          tileColor: context.currentTheme.bgSurfaceBase2,
          leading: Icon(
            TablerIcons.circle_x,
            color: context.currentTheme.iconNeutralDefault,
          ),
          title: Text(
            context.localization.cancel_subscription,
            style: AppTextStyles.h6SemiBold.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
          trailing: Icon(
            TablerIcons.chevron_right,
            color: context.currentTheme.iconNeutralDefault,
          ),
          onTap: _handleManageSubscriptions,
        ),
      ],
    );
  }

  Future<void> _handleManageSubscriptions() async {
    final url =
        Platform.isIOS ? appStoreSubscriptionUrl : playStoreSubscriptionUrl;

    try {
      await launchUrl(Uri.parse(url));
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }
}
