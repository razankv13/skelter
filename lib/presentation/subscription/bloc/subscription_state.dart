import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionState extends Equatable {
  @override
  List<Object> get props => [];
}

class SubscriptionPlanSelected extends SubscriptionState {
  SubscriptionPlanSelected(this.package);

  final Package package;

  @override
  List<Object> get props => [package];
}

class SubscriptionPaymentProcessing extends SubscriptionState {}

class SubscriptionPaymentSuccess extends SubscriptionState {}

class SubscriptionPaymentFailure extends SubscriptionState {
  SubscriptionPaymentFailure(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

class FetchSubscriptionPlanLoading extends SubscriptionState {}

class FetchSubscriptionPlanLoaded extends SubscriptionState {
  FetchSubscriptionPlanLoaded({
    required this.packages,
    required this.selectedPackage,
  });

  final List<Package> packages;
  final Package selectedPackage;

  @override
  List<Object> get props => [packages, selectedPackage];
}

class FetchSubscriptionPlanFailure extends SubscriptionState {
  FetchSubscriptionPlanFailure(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
