import 'package:flutter/widgets.dart';
import 'package:lamsa_customer/l10n/app_localizations.dart';

class Money {
  static String format(BuildContext context, num amount) {
    return '${amount.toStringAsFixed(0)} ${AppLocalizations.of(context).currencySymbol}';
  }
}