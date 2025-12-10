import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/checkout/model/product_cart.dart';

class InvoiceModel {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerName;
  final String shippingAddress;
  final String paymentMethod;
  final List<CartModel> items;
  final double subtotal;
  final double discount;
  final double deliveryCharges;
  final double totalAmount;

  InvoiceModel({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharges,
    required this.totalAmount,
  });

  factory InvoiceModel.fromCheckoutState({
    required String userName,
    required String address,
    required bool isPaymentMethodOnline,
    required List<CartModel> cartData,
    required double totalPrice,
    required double discount,
    required double deliveryCharges,
    required double finalAmount,
    required AppLocalizations localization,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final invoiceNumber = 'INV-${timestamp.toString().substring(
          timestamp.toString().length - 8,
        )}';

    return InvoiceModel(
      invoiceNumber: invoiceNumber,
      invoiceDate: DateTime.now(),
      customerName: userName,
      shippingAddress: address,
      paymentMethod: isPaymentMethodOnline
          ? localization.online_payment_method
          : localization.cash_on_delivery,
      items: cartData,
      subtotal: totalPrice,
      discount: discount,
      deliveryCharges: deliveryCharges,
      totalAmount: finalAmount,
    );
  }
}
