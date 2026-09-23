import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order.dart';
import '../../models/payment_type.dart';
import '../home/home_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isPending = order.status == OrderStatus.pendingApproval;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: (isPending ? AppColors.accent : AppColors.success).withOpacity(0.12),
                  child: Icon(isPending ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                      color: isPending ? AppColors.accent : AppColors.success, size: 44),
                ),
              ),
              const SizedBox(height: 20),
              Text(isPending ? 'طلبك بانتظار موافقة البائع' : 'تم الدفع بنجاح 🎉',
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.dark)),
              const SizedBox(height: 8),
              Text(
                isPending ? 'راح توصلك إشعار فور ما البائع يوافق على طلبك' : 'جاري تجهيز طلبك، راح نشعرك بكل تحديث',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.grey),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.medium), boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ]),
                child: Column(
                  children: [
                    _row('رقم الطلب', '#${order.id.substring(order.id.length - 6)}'),
                    _row('المنتج', order.product.name),
                    _row('الكمية', '${order.quantity}'),
                    _row('طريقة الدفع', order.paymentType.shortLabel),
                    const Divider(height: 24),
                    _row('الإجمالي', '${order.totalAmount.toStringAsFixed(0)} ر.س'),
                    _row('المدفوع الآن', '${order.paidAmount.toStringAsFixed(0)} ر.س'),
                    if (order.remainingAmount > 0) _row('المتبقي', '${order.remainingAmount.toStringAsFixed(0)} ر.س'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false),
                  child: const Text('العودة للرئيسية'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.grey)),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.dark)),
      ]),
    );
  }
}