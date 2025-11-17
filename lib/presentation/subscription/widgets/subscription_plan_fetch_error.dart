import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_bloc.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_state.dart';
import 'package:skelter/widgets/styling/app_colors.dart';

class SubscriptionPlanFetchError extends StatelessWidget {
  const SubscriptionPlanFetchError({super.key});

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.select<SubscriptionBloc, String>(
      (bloc) => (bloc.state as FetchSubscriptionPlanFailure).error,
    );

    return Center(
      child: Text(
        errorMessage,
        style: const TextStyle(color: AppColors.snackBarErrorColor),
      ),
    );
  }
}
