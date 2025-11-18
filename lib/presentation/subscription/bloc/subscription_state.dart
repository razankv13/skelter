import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionPlanSelectedState extends SubscriptionState {
  const SubscriptionPlanSelectedState(this.package);

  final Package package;

  @override
  List<Object> get props => [package];
}

class SubscriptionPaymentProcessingState extends SubscriptionState {
  const SubscriptionPaymentProcessingState();
}

class SubscriptionPaymentSuccessState extends SubscriptionState {
  const SubscriptionPaymentSuccessState();
}

class SubscriptionPaymentFailureState extends SubscriptionState {
  const SubscriptionPaymentFailureState(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

class FetchSubscriptionPlanLoadingState extends SubscriptionState {
  const FetchSubscriptionPlanLoadingState();
}

class FetchSubscriptionPlanLoadedState extends SubscriptionState {
  const FetchSubscriptionPlanLoadedState({
    required this.packages,
    required this.selectedPackage,
  });

  final List<Package> packages;
  final Package selectedPackage;

  @override
  List<Object> get props => [packages, selectedPackage];
}

class FetchSubscriptionPlanFailureState extends SubscriptionState {
  const FetchSubscriptionPlanFailureState(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
