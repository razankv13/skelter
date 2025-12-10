import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:skelter/presentation/checkout/data/cart_sample_data.dart';
import 'package:skelter/presentation/checkout/model/product_cart.dart';

class CheckoutState with EquatableMixin {
  final int stepperIndex;
  final double totalPrice;
  final double discount;
  final double deliveryCharges;
  final double finalAmount;
  final List<CartModel> cartData;
  final String userName;
  final String address;
  final bool isPaymentMethodOnline;
  final int couponCount;
  final bool isGeneratingInvoice;
  final String? invoiceGenerationError;
  final Uint8List? generatedInvoicePdf;
  final String? generatedInvoiceName;

  CheckoutState({
    required this.stepperIndex,
    required this.totalPrice,
    required this.discount,
    required this.deliveryCharges,
    required this.finalAmount,
    required this.cartData,
    required this.userName,
    required this.address,
    required this.isPaymentMethodOnline,
    required this.couponCount,
    this.isGeneratingInvoice = false,
    this.invoiceGenerationError,
    this.generatedInvoicePdf,
    this.generatedInvoiceName,
  });

  CheckoutState.initial()
      : stepperIndex = 0,
        totalPrice = 0.0,
        discount = 0.0,
        deliveryCharges = 0.0,
        finalAmount = 0.0,
        cartData = cartSampleData,
        userName = 'Roz Cooper',
        address = '2118 Thornridge Cir. Syracuse, Connecticut 35624',
        isPaymentMethodOnline = true,
        couponCount = 1,
        isGeneratingInvoice = false,
        invoiceGenerationError = null,
        generatedInvoicePdf = null,
        generatedInvoiceName = null;

  CheckoutState.copy(CheckoutState state)
      : stepperIndex = state.stepperIndex,
        totalPrice = state.totalPrice,
        discount = state.discount,
        deliveryCharges = state.deliveryCharges,
        finalAmount = state.finalAmount,
        cartData = state.cartData,
        userName = state.userName,
        address = state.address,
        isPaymentMethodOnline = state.isPaymentMethodOnline,
        couponCount = state.couponCount,
        isGeneratingInvoice = state.isGeneratingInvoice,
        invoiceGenerationError = state.invoiceGenerationError,
        generatedInvoicePdf = state.generatedInvoicePdf,
        generatedInvoiceName = state.generatedInvoiceName;

  CheckoutState copyWith({
    int? stepperIndex,
    double? totalPrice,
    double? discount,
    double? deliveryCharges,
    double? finalAmount,
    List<CartModel>? cartData,
    String? userName,
    String? address,
    bool? isPaymentMethodOnline,
    int? couponCount,
    bool? isGeneratingInvoice,
    String? invoiceGenerationError,
    Uint8List? generatedInvoicePdf,
    String? generatedInvoiceName,
    bool haveToClearPreviousInvoice = false,
    bool haveToClearInvoiceGenerationError = false,
  }) {
    return CheckoutState(
      stepperIndex: stepperIndex ?? this.stepperIndex,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      finalAmount: finalAmount ?? this.finalAmount,
      cartData: cartData ?? this.cartData,
      address: address ?? this.address,
      userName: userName ?? this.userName,
      isPaymentMethodOnline:
          isPaymentMethodOnline ?? this.isPaymentMethodOnline,
      couponCount: couponCount ?? this.couponCount,
      isGeneratingInvoice: isGeneratingInvoice ?? this.isGeneratingInvoice,
      invoiceGenerationError: haveToClearInvoiceGenerationError
          ? null
          : invoiceGenerationError ?? this.invoiceGenerationError,
      generatedInvoicePdf: haveToClearPreviousInvoice
          ? null
          : generatedInvoicePdf ?? this.generatedInvoicePdf,
      generatedInvoiceName: haveToClearPreviousInvoice
          ? null
          : generatedInvoiceName ?? this.generatedInvoiceName,
    );
  }

  CheckoutState.test({
    int? stepperIndex,
    double? totalPrice,
    double? discount,
    double? deliveryCharges,
    double? finalAmount,
    List<CartModel>? cartData,
    String? userName,
    String? address,
    bool? isPaymentMethodOnline,
    int? couponCount,
    bool? isGeneratingInvoice,
    this.invoiceGenerationError,
    this.generatedInvoicePdf,
    this.generatedInvoiceName,
  })  : stepperIndex = stepperIndex ?? 0,
        totalPrice = totalPrice ?? 0.0,
        discount = discount ?? 0.0,
        deliveryCharges = deliveryCharges ?? 0.0,
        finalAmount = finalAmount ?? 0.0,
        cartData = cartData ?? cartSampleData,
        userName = userName ?? '',
        address = address ?? '',
        isPaymentMethodOnline = isPaymentMethodOnline ?? true,
        couponCount = couponCount ?? 1,
        isGeneratingInvoice = isGeneratingInvoice ?? false;

  @override
  List<Object?> get props => [
        stepperIndex,
        totalPrice,
        discount,
        deliveryCharges,
        finalAmount,
        cartData,
        userName,
        address,
        isPaymentMethodOnline,
        couponCount,
        isGeneratingInvoice,
        invoiceGenerationError,
        generatedInvoicePdf,
        generatedInvoiceName,
      ];
}

class StepperIndexUpdateState extends CheckoutState {
  StepperIndexUpdateState(
    CheckoutState state, {
    required int index,
  }) : super.copy(state.copyWith(stepperIndex: index));
}
