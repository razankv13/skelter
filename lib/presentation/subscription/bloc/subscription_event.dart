import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchSubscriptionPackages extends SubscriptionEvent {
  FetchSubscriptionPackages();

  @override
  List<Object> get props => [];
}

class SelectSubscriptionPlan extends SubscriptionEvent {
  SelectSubscriptionPlan({
    required this.selectedPackage,
    required this.packages,
  });

  final Package selectedPackage;
  final List<Package> packages;

  @override
  List<Object> get props => [selectedPackage, packages];
}

class PurchaseSubscription extends SubscriptionEvent {
  PurchaseSubscription({required this.package});

  final Package package;

  @override
  List<Object> get props => [package];
}
