import 'package:flutter/material.dart';

enum PaymentType { cashOnDelivery, deposit, fullOnline }

extension PaymentTypeX on PaymentType {
  String get label {
    switch (this) {
      case PaymentType.cashOnDelivery:
        return 'حجز والدفع كاش عند الاستلام';
      case PaymentType.deposit:
        return 'ادفع عربون واحجز، والباقي عند الاستلام';
      case PaymentType.fullOnline:
        return 'ادفع المبلغ كاملاً إلكترونياً الآن';
    }
  }

  String get shortLabel {
    switch (this) {
      case PaymentType.cashOnDelivery:
        return 'كاش عند الاستلام';
      case PaymentType.deposit:
        return 'عربون + الباقي لاحقاً';
      case PaymentType.fullOnline:
        return 'دفع إلكتروني كامل';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentType.cashOnDelivery:
        return Icons.payments_outlined;
      case PaymentType.deposit:
        return Icons.savings_outlined;
      case PaymentType.fullOnline:
        return Icons.credit_card_rounded;
    }
  }
}