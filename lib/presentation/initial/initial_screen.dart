import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' as app_settings;
import 'package:skelter/common/theme/text_style/app_text_styles.dart';
import 'package:skelter/constants/constants.dart';
import 'package:skelter/core/deep_link/app_deep_link_manager.dart';
import 'package:skelter/core/services/injection_container.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/presentation/force_update/constants/force_update_constants.dart';
import 'package:skelter/presentation/login/models/login_details.dart';
import 'package:skelter/routes.gr.dart';
import 'package:skelter/services/local_auth_services.dart';
import 'package:skelter/services/remote_config_service.dart';
import 'package:skelter/shared_pref/pref_keys.dart';
import 'package:skelter/shared_pref/prefs.dart';
import 'package:skelter/utils/app_version_helper.dart';
import 'package:skelter/utils/extensions/primitive_types_extensions.dart';
import 'package:skelter/utils/theme/extention/theme_extension.dart';

@RoutePage()
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  Future<void> _checkForceUpdateAndAuthStatus() async {
    final remoteConfig = RemoteConfigService();

    final appCurrentVersion = (await PackageInfo.fromPlatform()).version;

    final currentAppVersion = getExtendedVersionNumber(appCurrentVersion);
    final latestAppVersion = getExtendedVersionNumber(
      remoteConfig.getString(kRemoteConfigAppLatestVersionKey),
    );
    final minimumRequiredVersion = getExtendedVersionNumber(
      remoteConfig.getString(kRemoteConfigMandatoryAppVersionKey),
    );

    final isMandatoryUpdateRequired =
        currentAppVersion < minimumRequiredVersion;
    final isOptionalUpdateAvailable = currentAppVersion < latestAppVersion;

    if (isMandatoryUpdateRequired) {
      await context.router.replaceAll([
        ForceUpdateRoute(isMandatoryUpdate: true),
      ]);
      return;
    }

    if (isOptionalUpdateAvailable) {
      await showOptionalUpdate(context: context);
    }

    await _checkAuthAndHandleDeepLink();
  }

  Future<void> _checkAuthAndHandleDeepLink() async {
    final userDetailsJson = await Prefs.getString(PrefKeys.kUserDetails);
    final userDetails = LoginDetails.fromJson(
      json.decode(userDetailsJson ?? '{}'),
    );

    if (!mounted) return;

    final deepLinkManager = sl<AppDeepLinkManager>();

    if ((userDetails.uid ?? '').haveContent()) {
      await authenticateWithBiometrics(context);
      if (deepLinkManager.hasPendingDeepLink) {
        final isDeepLinkHandled =
            await deepLinkManager.handlePendingDeepLink(context);

        // Case 1: Deep link exists -> try handling it; if invalid,
        // navigate to Home.
        if (!isDeepLinkHandled) {
          await context.router.replace(const HomeRoute());
        }
      } else {
        // Case 2: No deep link -> navigate directly to Home.
        await context.router.replace(const HomeRoute());
      }
    } else {
      await context.router.replace(LoginWithPhoneNumberRoute());
    }
  }

  Future<void> showOptionalUpdate({
    required BuildContext context,
  }) async {
    final dateTimeNow = DateTime.now();

    final lastShownUpdatePromptTimeStamp =
        await Prefs.getInt(kLastShownUpdatePromptTimestamp);

    final lastShownUpdateTime = lastShownUpdatePromptTimeStamp != null
        ? DateTime.fromMillisecondsSinceEpoch(lastShownUpdatePromptTimeStamp)
        : null;

    final hasNeverBeenShown = lastShownUpdateTime == null;
    final cooldownTimePassed = lastShownUpdateTime != null &&
        dateTimeNow.difference(lastShownUpdateTime) >=
            kOptionalUpdateCooldownTime;

    final shouldShowUpdatePrompt = hasNeverBeenShown || cooldownTimePassed;

    if (shouldShowUpdatePrompt) {
      await Prefs.setInt(
        kLastShownUpdatePromptTimestamp,
        dateTimeNow.millisecondsSinceEpoch,
      );

      await context.router.push(
        ForceUpdateRoute(isMandatoryUpdate: false),
      );
    }
  }

  Future<void> authenticateWithBiometrics(BuildContext context) async {
    final localAuthService = sl<LocalAuthService>();

    final biometricAuthStatus = await localAuthService.authenticate();

    switch (biometricAuthStatus) {
      case BiometricAuthStatus.success:
        await context.router.replace(const HomeRoute());

      case BiometricAuthStatus.notSupported:
        await context.router.replace(const HomeRoute());

      case BiometricAuthStatus.notEnrolled:
        await _showBiometricEnrollmentDialog(context);

      case BiometricAuthStatus.cancelled:
        _exitApp();

      case BiometricAuthStatus.error:
        _exitApp();
    }
  }

  Future<void> _showBiometricEnrollmentDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Text(
          context.localization.biometric_auth_desc_for_enrollment,
          style: AppTextStyles.p2Medium
              .copyWith(color: context.currentTheme.textNeutralPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(context.localization.ok),
            child: Text(
              context.localization.ok,
              style: TextStyle(color: context.currentTheme.textNeutralLight),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(context.localization.settings),
            child: Text(
              context.localization.go_to_settings,
              style: TextStyle(color: context.currentTheme.textNeutralLight),
            ),
          ),
        ],
      ),
    );

    if (result == KSettings) {
      try {
        await app_settings.openAppSettings();
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (_) {}
    }

    _exitApp();
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      FlutterExitApp.exitApp();
    } else if (Platform.isIOS) {
      FlutterExitApp.exitApp(iosForceExit: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkForceUpdateAndAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
