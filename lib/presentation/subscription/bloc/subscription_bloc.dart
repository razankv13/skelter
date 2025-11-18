import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:skelter/constants/constants.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_event.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final AppLocalizations localization;

  SubscriptionBloc({required this.localization})
      : super(const FetchSubscriptionPlanLoadingState()) {
    on<FetchSubscriptionPackagesEvent>(_onFetchSubscriptionPackagesEvent);
    on<PurchaseSubscriptionEvent>(_onPurchaseSubscriptionEvent);
    on<SelectSubscriptionPlanEvent>(_onSelectSubscriptionPlanEvent);
  }

  Future<void> _onFetchSubscriptionPackagesEvent(
    FetchSubscriptionPackagesEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const FetchSubscriptionPlanLoadingState());

    try {
      final offerings = await Purchases.getOfferings();
      final availablePackages = offerings.current?.availablePackages ?? [];

      if (availablePackages.isEmpty) {
        emit(
          FetchSubscriptionPlanFailureState(
            localization.no_subscription_available,
          ),
        );
        return;
      }

      emit(
        FetchSubscriptionPlanLoadedState(
          packages: availablePackages,
          selectedPackage: availablePackages.firstWhere(
            (pkg) => pkg.storeProduct.identifier == revenueCatMonthly,
          ),
        ),
      );
    } on Exception {
      emit(
        FetchSubscriptionPlanFailureState(
          localization.failed_to_load_subscriptions,
        ),
      );
    }
  }

  Future<void> _onPurchaseSubscriptionEvent(
    PurchaseSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionPaymentProcessingState());

    try {
      await Purchases.purchasePackage(event.package);

      emit(const SubscriptionPaymentSuccessState());
    } on PurchasesError catch (e) {
      emit(
        SubscriptionPaymentFailureState(
          _getPaymentFailureErrorMessage(e.code),
        ),
      );
    } on Exception {
      emit(
        SubscriptionPaymentFailureState(localization.unexpected_error_occurred),
      );
    }
  }

  String _getPaymentFailureErrorMessage(PurchasesErrorCode code) {
    return switch (code) {
      PurchasesErrorCode.storeProblemError => localization.store_login_required,
      PurchasesErrorCode.purchaseCancelledError =>
        localization.user_purchase_cancelled,
      PurchasesErrorCode.networkError => localization.no_internet_connection,
      _ => localization.opps_something_went_wrong,
    };
  }

  Future<void> _onSelectSubscriptionPlanEvent(
    SelectSubscriptionPlanEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(
      FetchSubscriptionPlanLoadedState(
        packages: event.packages,
        selectedPackage: event.selectedPackage,
      ),
    );
  }
}
