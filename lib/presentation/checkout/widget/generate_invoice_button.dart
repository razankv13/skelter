import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:skelter/presentation/checkout/bloc/checkout_bloc.dart';
import 'package:skelter/presentation/checkout/bloc/checkout_events.dart';
import 'package:skelter/widgets/app_button/app_button.dart';
import 'package:skelter/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:skelter/widgets/app_button/enums/app_button_style_enum.dart';

class GenerateInvoiceButton extends StatelessWidget {
  const GenerateInvoiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isGenerating = context.select<CheckoutBloc, bool>(
      (bloc) => bloc.state.isGeneratingInvoice,
    );

    return AppButton(
      onPressed: isGenerating
          ? null
          : () {
              context.read<CheckoutBloc>().add(const GenerateInvoiceEvent());
            },
      leftIcon: TablerIcons.receipt,
      style: AppButtonStyle.textOrIcon,
      size: AppButtonSize.extraLarge,
      isLoading: isGenerating,
    );
  }
}
