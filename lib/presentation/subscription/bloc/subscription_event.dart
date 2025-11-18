import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class FetchSubscriptionPackagesEvent extends SubscriptionEvent {
  const FetchSubscriptionPackagesEvent();

  @override
  List<Object> get props => [];
}

class SelectSubscriptionPlanEvent extends SubscriptionEvent {
  const SelectSubscriptionPlanEvent({
    required this.selectedPackage,
    required this.packages,
  });

  final Package selectedPackage;
  final List<Package> packages;

  @override
  List<Object> get props => [selectedPackage, packages];
}

class PurchaseSubscriptionEvent extends SubscriptionEvent {
  const PurchaseSubscriptionEvent({required this.package});

  final Package package;

  @override
  List<Object> get props => [package];
}

class RestoreSubscriptionEvent extends SubscriptionEvent {
  const RestoreSubscriptionEvent();

  @override
  List<Object> get props => [];
}

class ClearSnackBarMessageEvent extends SubscriptionEvent {
  const ClearSnackBarMessageEvent();

  @override
  List<Object> get props => [];
}
