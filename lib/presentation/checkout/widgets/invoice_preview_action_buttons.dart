import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/services/pdf_service.dart';
import 'package:skelter/utils/extensions/build_context_ext.dart';
import 'package:skelter/utils/theme/extention/theme_extension.dart';
import 'package:skelter/widgets/app_button/app_button.dart';
import 'package:skelter/widgets/app_button/enums/app_button_size_enum.dart';

class InvoicePreviewActionButtons extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const InvoicePreviewActionButtons({
    required this.pdfBytes,
    required this.fileName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceBase2,
      ),
      child: SafeArea(
        child: AppButton(
          label: context.localization.download_invoice,
          onPressed: () => _downloadInvoice(context),
          foregroundColor: context.currentTheme.textNeutralLight,
          size: AppButtonSize.extraLarge,
        ),
      ),
    );
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    try {
      await PdfService.savePdfToDevice(pdfBytes, fileName);

      if (context.mounted) {
        context.showSnackBar(
          context.localization.invoice_saved_success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar(
          context.localization.invoice_generation_failed,
          isDisplayingError: true,
        );
      }
    }
  }
}
