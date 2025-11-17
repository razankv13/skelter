import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/routes.gr.dart';
import 'package:skelter/widgets/app_button/app_button.dart';
import 'package:skelter/widgets/app_button/enums/app_button_size_enum.dart';

class GoToHomeScreenButton extends StatelessWidget {
  const GoToHomeScreenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: context.localization.go_to_home,
      shouldSetFullWidth: true,
      size: AppButtonSize.extraLarge,
      onPressed: () => context.router.replaceAll([const HomeRoute()]),
    );
  }
}
