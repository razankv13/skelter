import 'package:flutter/material.dart';
import 'package:skelter/common/theme/text_style/app_text_styles.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/utils/extensions/currency_formatter_extensions.dart';
import 'package:skelter/utils/theme/extention/theme_extension.dart';

class Price extends StatelessWidget {
  final double price;

  const Price({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: context.formatCurrency(price, decimalDigits: 2),
        style: AppTextStyles.p3SemiBold.copyWith(
          color: context.currentTheme.textBrandPrimary,
        ),
        children: <InlineSpan>[
          const WidgetSpan(
            child: SizedBox(width: 5),
          ),
          TextSpan(
            text: context.localization.inclusive_of_taxes,
            style: AppTextStyles.p3Medium.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
