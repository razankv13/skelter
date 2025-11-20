import 'package:flutter/material.dart';
import 'package:skelter/presentation/subscription_activated/widgets/go_to_home_screen_button.dart';
import 'package:skelter/presentation/subscription_activated/widgets/subscription_activated_message.dart';
import 'package:skelter/presentation/subscription_activated/widgets/subscription_activated_success_icon.dart';
import 'package:skelter/presentation/subscription_activated/widgets/subscription_activated_title.dart';

class SubscriptionActivatedScreen extends StatelessWidget {
  const SubscriptionActivatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SubscriptionActivatedSuccessIcon(),
                SizedBox(height: 24),
                SubscriptionActivatedTitle(),
                SizedBox(height: 12),
                SubscriptionActivatedMessage(),
                SizedBox(height: 24),
                GoToHomeScreenButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
