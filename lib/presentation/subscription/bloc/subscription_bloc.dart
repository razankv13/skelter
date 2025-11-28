import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_event.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_state.dart';
import 'package:skelter/presentation/subscription/constant/subscription_constants.dart';
import 'package:skelter/services/subscription_service.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final AppLocalizations _localization;
  final SubscriptionService _subscriptionService;

  SubscriptionBloc({
    required AppLocalizations localization,
    required SubscriptionService subscriptionService,
  })  : _localization = localization,
        _subscriptionService = subscriptionService,
        super(const FetchSubscriptionPlanLoadingState()) {
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
      final availablePackages = await _subscriptionService.getPackages();

      if (availablePackages.isEmpty) {
        emit(
          FetchSubscriptionPlanFailureState(
            _localization.no_subscription_available,
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
          _localization.failed_to_load_subscriptions,
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
      await _subscriptionService.purchasePackage(event.package);
      emit(const SubscriptionPaymentSuccessState());
    } on PurchasesError catch (e) {
      final error = _getPaymentFailureErrorMessage(
        code: e.code,
      );
      emit(SubscriptionPaymentFailureState(error));
    } on Exception {
      emit(
        SubscriptionPaymentFailureState(
          _localization.unexpected_error_occurred,
        ),
      );
    }
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
      final isRestored = await _subscriptionService.restorePurchases();
      final message = isRestored
          ? _localization.restore_success
          : _localization.no_active_subscriptions;

      emit(
        loadedState.copyWith(isRestoring: false, restoreStatusMessage: message),
      );
    } on PlatformException catch (e) {
      emit(
        loadedState.copyWith(
          isRestoring: false,
          restoreStatusMessage: '${_localization.restore_error} ${e.message}',
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

  String _getPaymentFailureErrorMessage({
    required PurchasesErrorCode code,
  }) {
    return switch (code) {
      PurchasesErrorCode.storeProblemError =>
        _localization.store_login_required,
      PurchasesErrorCode.purchaseCancelledError =>
        _localization.user_purchase_cancelled,
      PurchasesErrorCode.networkError => _localization.no_internet_connection,
      _ => _localization.opps_something_went_wrong,
    };
  }
}
