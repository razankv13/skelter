import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static const String subscriptionEntitlement = 'Skelter Pro';

  factory SubscriptionService() => _instance;

  SubscriptionService._internal() {
    _init();
  }

  static final _instance = SubscriptionService._internal();

  final ValueNotifier<bool> isUserSubscribed = ValueNotifier<bool>(false);

  Future<void> _init() async {
    await _checkSubscriptionStatus();
    Purchases.addCustomerInfoUpdateListener(_updateSubscriptionStatus);
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateSubscriptionStatus(customerInfo);
    } on PlatformException catch (e) {
      isUserSubscribed.value = false;
      debugPrint('Error fetching subscription status: $e');
    }
  }

  Future<List<Package>> getPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      final availablePackages = offerings.current?.availablePackages ?? [];
      return availablePackages;
    } on PlatformException catch (e) {
      debugPrint('Error fetching offerings: $e');
      rethrow;
    }
  }

  Future<bool> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    _updateSubscriptionStatus(customerInfo);
    return isUserSubscribed.value;
  }

  Future<void> purchasePackage(Package package) async {
    await Purchases.purchasePackage(package);
  }

  Future<String?> getUserManagementUrl() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.managementURL;
    } catch (e) {
      debugPrint('Error getting management URL: $e');
      return null;
    }
  }

  void _updateSubscriptionStatus(CustomerInfo customerInfo) {
    isUserSubscribed.value =
        customerInfo.entitlements.active.containsKey(subscriptionEntitlement);
    debugPrint('Subscription status updated: ${isUserSubscribed.value}');
  }
}
