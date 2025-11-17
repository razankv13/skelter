import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:skelter/constants/constants.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_event.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final AppLocalizations localization;

  SubscriptionBloc({required this.localization})
      : super(FetchSubscriptionPlanLoading()) {
    on<FetchSubscriptionPackages>(_onFetchPackages);
    on<PurchaseSubscription>(_onPurchaseSubscription);
    on<SelectSubscriptionPlan>(_onSelectSubscriptionPlan);
  }

  Future<void> _onFetchPackages(
    FetchSubscriptionPackages event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(FetchSubscriptionPlanLoading());

    try {
      final offerings = await Purchases.getOfferings();
      final availablePackages = offerings.current?.availablePackages ?? [];

      if (availablePackages.isEmpty) {
        emit(
          FetchSubscriptionPlanFailure(
            localization.no_subscription_available,
          ),
        );
        return;
      }

      emit(
        FetchSubscriptionPlanLoaded(
          packages: availablePackages,
          selectedPackage: availablePackages.firstWhere(
            (pkg) => pkg.storeProduct.identifier == revenueCatMonthly,
          ),
        ),
      );
    } on Exception {
      emit(
        FetchSubscriptionPlanFailure(
          localization.failed_to_load_subscriptions,
        ),
      );
    }
  }

  Future<void> _onPurchaseSubscription(
    PurchaseSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionPaymentProcessing());

    try {
      await Purchases.purchasePackage(event.package);

      emit(SubscriptionPaymentSuccess());
    } on PurchasesError catch (e) {
      emit(SubscriptionPaymentFailure(_getErrorMessage(e.code)));
    } on Exception {
      emit(SubscriptionPaymentFailure(localization.unexpected_error_occurred));
    }
  }

  String _getErrorMessage(PurchasesErrorCode code) {
    return switch (code) {
      PurchasesErrorCode.storeProblemError => localization.store_login_required,
      PurchasesErrorCode.purchaseCancelledError =>
        localization.user_purchase_cancelled,
      PurchasesErrorCode.networkError => localization.no_internet_connection,
      _ => localization.opps_something_went_wrong,
    };
  }

  Future<void> _onSelectSubscriptionPlan(
    SelectSubscriptionPlan event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(
      FetchSubscriptionPlanLoaded(
        packages: event.packages,
        selectedPackage: event.selectedPackage,
      ),
    );
  }
}
