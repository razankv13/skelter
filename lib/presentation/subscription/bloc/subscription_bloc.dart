import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_event.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_state.dart';
import 'package:skelter/presentation/subscription/constant/subscription_constants.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final AppLocalizations localization;

  SubscriptionBloc({required this.localization})
      : super(const FetchSubscriptionPlanLoadingState()) {
    on<FetchSubscriptionPackagesEvent>(_onFetchSubscriptionPackagesEvent);
    on<PurchaseSubscriptionEvent>(_onPurchaseSubscriptionEvent);
    on<SelectSubscriptionPlanEvent>(_onSelectSubscriptionPlanEvent);
    on<RestoreSubscriptionEvent>(_onRestoreSubscriptionEvent);
    on<ClearSnackBarMessageEvent>(_onClearSnackBarMessageEvent);
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

  Future<void> _onRestoreSubscriptionEvent(
    RestoreSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is! FetchSubscriptionPlanLoadedState) return;
    final loadedState = state as FetchSubscriptionPlanLoadedState;

    emit(loadedState.copyWith(isRestoring: true));

    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasEntitlement = customerInfo.entitlements.active.isNotEmpty;
      final message = hasEntitlement
          ? localization.restore_success
          : localization.no_active_subscriptions;

      emit(
        loadedState.copyWith(isRestoring: false, snackBarMessage: message),
      );
    } on PlatformException catch (e) {
      emit(
        loadedState.copyWith(
          isRestoring: false,
          snackBarMessage: '${localization.restore_error} ${e.message}',
        ),
      );
    }
  }

  void _onClearSnackBarMessageEvent(
    ClearSnackBarMessageEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    if (state is! FetchSubscriptionPlanLoadedState) return;
    final loadedState = state as FetchSubscriptionPlanLoadedState;
    emit(loadedState.copyWith(clearSnackBar: true));
  }
}
