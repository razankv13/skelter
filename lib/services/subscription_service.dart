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

  void _updateSubscriptionStatus(CustomerInfo customerInfo) {
    isUserSubscribed.value =
        customerInfo.entitlements.active.containsKey(subscriptionEntitlement);
    debugPrint('Subscription status updated: ${isUserSubscribed.value}');
  }
}
