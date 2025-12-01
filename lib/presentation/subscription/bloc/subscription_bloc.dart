import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/constants/constants.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_event.dart';
import 'package:skelter/presentation/subscription/bloc/subscription_state.dart';
import 'package:skelter/services/subscription_service.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final AppLocalizations _localization;
  final SubscriptionService _subscriptionService;

  SubscriptionBloc({
    required AppLocalizations localization,
    required SubscriptionService subscriptionService,
  })  : _localization = localization,
        _subscriptionService = subscriptionService,
        super(FetchSubscriptionPlanLoadingState()) {
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
    emit(FetchSubscriptionPlanLoadingState());

    try {
      final availablePackages = await _subscriptionService.getPackages();

      if (availablePackages.isEmpty) {
        emit(
          FetchSubscriptionPlanFailureState(
            state,
            error: _localization.no_subscription_available,
          ),
        );
        return;
      }

      final selectedPackage = availablePackages.firstWhere(
        (pkg) => pkg.storeProduct.identifier == revenueCatMonthly,
      );

      emit(
        FetchSubscriptionPlanLoadedState(
          state.copyWith(
            packages: availablePackages,
            selectedPackage: selectedPackage,
            isLoadingPackages: false,
          ),
        ),
      );
    } on Exception {
      emit(
        FetchSubscriptionPlanFailureState(
          state,
          error: _localization.failed_to_load_subscriptions,
        ),
      );
    }
  }

  Future<void> _onPurchaseSubscriptionEvent(
    PurchaseSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionPaymentProcessingState(state));

    final success = await _subscriptionService.purchasePackage(
      event.package,
      onError: (errorMessage, {stackTrace}) {
        emit(SubscriptionPaymentFailureState(state, error: errorMessage));
      },
    );

    if (success) {
      emit(SubscriptionPaymentSuccessState(state));
    }
  }

  Future<void> _onSelectSubscriptionPlanEvent(
    SelectSubscriptionPlanEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(
      FetchSubscriptionPlanLoadedState(
        state.copyWith(
          packages: event.packages,
          selectedPackage: event.selectedPackage,
        ),
      ),
    );
  }

  Future<void> _onRestoreSubscriptionEvent(
    RestoreSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(FetchSubscriptionPlanLoadedState(state.copyWith(isRestoring: true)));

    try {
      final isRestored = await _subscriptionService.restorePurchases();
      final message = isRestored
          ? _localization.restore_success
          : _localization.no_active_subscriptions;

      emit(
        FetchSubscriptionPlanLoadedState(
          state.copyWith(isRestoring: false, restoreStatusMessage: message),
        ),
      );
    } on PlatformException catch (e) {
      emit(
        FetchSubscriptionPlanLoadedState(
          state.copyWith(
            isRestoring: false,
            restoreStatusMessage: '${_localization.restore_error} ${e.message}',
          ),
        ),
      );
    }
  }

  void _onClearSnackBarMessageEvent(
    ClearSnackBarMessageEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(FetchSubscriptionPlanLoadedState(state.copyWith(clearSnackBar: true)));
  }
}
