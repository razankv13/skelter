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

  Future<bool> purchasePackage(
    Package package, {
    required Function(String, {StackTrace? stackTrace}) onError,
  }) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } on PurchasesError catch (e, stack) {
      _handlePurchaseError(e, onError, stackTrace: stack);
      return false;
    } on PlatformException catch (e, stack) {
      debugPrint('Platform exception during purchase: $e');
      final message = e.message ?? 'Unknown error';
      onError('Purchase failed: $message', stackTrace: stack);
      return false;
    } on Exception catch (e, stack) {
      debugPrint('Unexpected exception during purchase: $e');
      onError('Something went wrong', stackTrace: stack);
      return false;
    }
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

  void _handlePurchaseError(
    PurchasesError e,
    Function(String, {StackTrace? stackTrace}) onError, {
    StackTrace? stackTrace,
  }) {
    final errorMessage = switch (e.code) {
      PurchasesErrorCode.storeProblemError => 'Store login required',
      PurchasesErrorCode.purchaseCancelledError => 'Purchase cancelled',
      PurchasesErrorCode.networkError => 'No internet connection',
      PurchasesErrorCode.productAlreadyPurchasedError => 'Already subscribed',
      PurchasesErrorCode.receiptAlreadyInUseError => 'Receipt already in use',
      _ => 'Something went wrong',
    };

    debugPrint('Purchase error: ${e.code} - $errorMessage');
    onError(errorMessage, stackTrace: stackTrace);
  }
}
