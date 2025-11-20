import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_bloc.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_event.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_state.dart';
import 'package:skelter/presentation/subscription/widgets/subscription_plan_card.dart';

class SubscriptionPlans extends StatelessWidget {
  const SubscriptionPlans({super.key});

  @override
  Widget build(BuildContext context) {
    final packages = context.select<SubscriptionBloc, List<Package>>(
      (bloc) {
        final state = bloc.state;
        if (state is FetchSubscriptionPlanLoadedState) return state.packages;
        return const <Package>[];
      },
    );

    final selectedPlan = context.select<SubscriptionBloc, Package?>(
      (bloc) {
        final state = bloc.state;
        return state is FetchSubscriptionPlanLoadedState
            ? state.selectedPackage
            : null;
      },
    );

    return Column(
      children: packages.map((package) {
        final isMonthly = package.packageType == PackageType.monthly;
        final isSelected = selectedPlan != null &&
            selectedPlan.storeProduct.identifier ==
                package.storeProduct.identifier;

        return SubscriptionPlanCard(
          title: isMonthly
              ? context.localization.monthly_plan
              : context.localization.yearly_plan,
          price: package.storeProduct.priceString,
          duration: isMonthly
              ? context.localization.monthly_duration
              : context.localization.yearly_duration,
          renewal: isMonthly
              ? context.localization.monthly_renewal
              : context.localization.yearly_renewal,
          isSelected: isSelected,
          onTap: () => context.read<SubscriptionBloc>().add(
                SelectSubscriptionPlanEvent(
                  packages: packages,
                  selectedPackage: package,
                ),
              ),
        );
      }).toList(),
    );
  }
}
