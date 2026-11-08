import 'package:flutter/material.dart';

enum PaymentType { cashOnDelivery, deposit, walletTransfer, fullOnline } // ✅ تمت إضافة fullOnline

extension PaymentTypeX on PaymentType {
  String get label {
    switch (this) {
      case PaymentType.cashOnDelivery:
        return 'حجز والدفع كاش عند الاستلام';
      case PaymentType.deposit:
        return 'ادفع عربون عبر المحفظة، والباقي كاش عند الاستلام';
      case PaymentType.walletTransfer:
        return 'تحويل كامل المبلغ عبر محفظة إلكترونية';
      case PaymentType.fullOnline: // ✅ تمت إضافة الحالة الجديدة
        return 'دفع كامل المبلغ إلكترونياً';
    }
  }

  String get shortLabel {
    switch (this) {
      case PaymentType.cashOnDelivery:
        return 'كاش عند الاستلام';
      case PaymentType.deposit:
        return 'عربون + الباقي كاش';
      case PaymentType.walletTransfer:
        return 'تحويل محفظة كامل';
      case PaymentType.fullOnline: // ✅ تمت إضافة الحالة الجديدة
        return 'دفع إلكتروني كامل';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentType.cashOnDelivery:
        return Icons.payments_outlined;
      case PaymentType.deposit:
        return Icons.savings_outlined;
      case PaymentType.walletTransfer:
        return Icons.account_balance_wallet_outlined;
      case PaymentType.fullOnline: // ✅ تمت إضافة الحالة الجديدة
        return Icons.credit_card_outlined;
    }
  }
}