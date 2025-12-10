import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skelter/i18n/app_localizations.dart';
import 'package:skelter/presentation/checkout/bloc/checkout_events.dart';
import 'package:skelter/presentation/checkout/bloc/checkout_state.dart';
import 'package:skelter/presentation/checkout/data/cart_sample_data.dart';
import 'package:skelter/presentation/checkout/model/invoice_model.dart';
import 'package:skelter/services/pdf_service.dart';
import 'package:skelter/utils/permission_util.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final AppLocalizations _localizations;

  CheckoutBloc(this._localizations) : super(CheckoutState.initial()) {
    _setupEventListener();
  }

  void _setupEventListener() {
    on<StepperIndexUpdateEvent>(_onStepperIndexUpdateEvent);
    on<InitialCalculationEvent>(_onInitialCalculationEvent);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethodEvent);
    on<GenerateInvoiceEvent>(_onGenerateInvoiceEvent);
    on<ClearInvoiceGenerationErrorEvent>(_onClearInvoiceGenerationErrorEvent);
  }

  void _onInitialCalculationEvent(
    InitialCalculationEvent event,
    Emitter<CheckoutState> emit,
  ) {
    final totalPrice = cartSampleData.fold(
      0.0,
      (total, item) => total + (item.product.price * item.quantities),
    );
    const discount = 25.9;
    const deliveryCharges = 10.0;
    final finalAmount =
        ((totalPrice - discount) + deliveryCharges).toStringAsFixed(2);

    emit(
      state.copyWith(
        totalPrice: totalPrice,
        discount: discount,
        deliveryCharges: deliveryCharges,
        finalAmount: double.parse(finalAmount),
      ),
    );
  }

  void _onStepperIndexUpdateEvent(
    StepperIndexUpdateEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(StepperIndexUpdateState(state, index: event.index));
  }

  void _onSelectPaymentMethodEvent(
    SelectPaymentMethodEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(
      state.copyWith(isPaymentMethodOnline: event.isPaymentMethodOnline),
    );
  }

  Future<void> _onGenerateInvoiceEvent(
    GenerateInvoiceEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    final hasPermission = await PermissionUtil.hasStoragePermission();
    if (!hasPermission) {
      emit(
        state.copyWith(
          invoiceGenerationError: _localizations.storage_permission_required,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isGeneratingInvoice: true,
        haveToClearPreviousInvoice: true,
      ),
    );
    try {
      final invoice = InvoiceModel.fromCheckoutState(
        userName: state.userName,
        address: state.address,
        isPaymentMethodOnline: state.isPaymentMethodOnline,
        cartData: state.cartData,
        totalPrice: state.totalPrice,
        discount: state.discount,
        deliveryCharges: state.deliveryCharges,
        finalAmount: state.finalAmount,
        localization: _localizations,
      );

      final pdfBytes =
          await PdfService.generateInvoicePdf(invoice, _localizations);
      final fileName = '${invoice.invoiceNumber}.pdf';

      emit(
        state.copyWith(
          isGeneratingInvoice: false,
          generatedInvoicePdf: pdfBytes,
          generatedInvoiceName: fileName,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isGeneratingInvoice: false,
          invoiceGenerationError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onClearInvoiceGenerationErrorEvent(
    ClearInvoiceGenerationErrorEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(haveToClearInvoiceGenerationError: true));
  }
}
