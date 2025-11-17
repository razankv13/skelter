import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/presentation/payment_failed/payment_failed_screen.dart';
import 'package:skelter/presentation/payment_processing/payment_processing_screen.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_bloc.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_event.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_state.dart';
import 'package:skelter/presentation/subscription/widgets/pro_icon_text.dart';
import 'package:skelter/presentation/subscription/widgets/subscription_bottom_nav_bar.dart';
import 'package:skelter/presentation/subscription/widgets/subscription_close_icon.dart';
import 'package:skelter/presentation/subscription/widgets/subscription_plan_fetch_error.dart';
import 'package:skelter/presentation/subscription/widgets/subscription_plans.dart';
import 'package:skelter/presentation/subscription/widgets/subscription_renew_text.dart';
import 'package:skelter/presentation/subscription_activated/subscription_activated_screen.dart';

@RoutePage()
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return SubscriptionBloc(localization: context.localization)
          ..add(FetchSubscriptionPackages());
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is FetchSubscriptionPlanLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FetchSubscriptionPlanFailure) {
                return const SubscriptionPlanFetchError();
              } else if (state is FetchSubscriptionPlanLoaded) {
                return const SubscriptionScreenBody();
              } else if (state is SubscriptionPaymentProcessing) {
                return const PaymentProcessingScreen();
              } else if (state is SubscriptionPaymentSuccess) {
                return const SubscriptionActivatedScreen();
              } else if (state is SubscriptionPaymentFailure) {
                return const PaymentFailedScreen();
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is FetchSubscriptionPlanLoaded) {
              return const SubscriptionBottomNavBar();
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class SubscriptionScreenBody extends StatelessWidget {
  const SubscriptionScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SubscriptionCloseIcon(),
            SizedBox(height: 14),
            ProIconText(),
            SizedBox(height: 14),
            SubscriptionPlans(),
            SizedBox(height: 14),
            SubscriptionRenewText(),
          ],
        ),
      ),
    );
  }
}
