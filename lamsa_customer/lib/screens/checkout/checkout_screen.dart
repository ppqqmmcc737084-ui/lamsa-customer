import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/page_transitions.dart';
import '../../models/product.dart';
import '../../models/payment_type.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;
  final int quantity;
  const CheckoutScreen({super.key, required this.product, required this.quantity});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late PaymentType _selected = widget.product.allowedPayments.first;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  double get total => widget.product.finalPrice * widget.quantity;
  double get depositAmount => total * widget.product.depositPercent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _orderSummaryCard(),
            const SizedBox(height: 20),
            const Text('اختر طريقة الدفع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...widget.product.allowedPayments.map(_paymentOption),
            const SizedBox(height: 20),
            const Text('بيانات التوصيل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'الاسم الكامل')),
            const SizedBox(height: 10),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'رقم الجوال')),
            const SizedBox(height: 10),
            TextField(controller: _addressController, decoration: const InputDecoration(hintText: 'العنوان')),
            const SizedBox(height: 24),
            _amountSummary(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitOrder,
                child: Text(_selected == PaymentType.fullOnline ? 'ادفع الآن' : 'تأكيد الطلب'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _orderSummaryCard() {
    final p = widget.product;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(p.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('الكمية: ${widget.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Text('${total.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _paymentOption(PaymentType type) {
    final selected = _selected == type;
    return GestureDetector(
      onTap: () => setState(() => _selected = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: selected ? AppColors.primary : AppColors.lightGrey, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(type.icon, color: selected ? AppColors.primary : AppColors.grey),
            const SizedBox(width: 12),
            Expanded(child: Text(type.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? AppColors.primary : AppColors.dark))),
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? AppColors.primary : AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _amountSummary() {
    String label;
    double amountNow;
    double remaining;
    switch (_selected) {
      case PaymentType.cashOnDelivery:
        label = 'يدفع عند الاستلام';
        amountNow = 0;
        remaining = total;
        break;
      case PaymentType.deposit:
        label = 'العربون المطلوب الآن';
        amountNow = depositAmount;
        remaining = total - depositAmount;
        break;
      case PaymentType.fullOnline:
        label = 'المبلغ المطلوب الآن';
        amountNow = total;
        remaining = 0;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('إجمالي الطلب'), Text('${total.toStringAsFixed(0)} ر.س')]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('${amountNow.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
          ]),
          if (remaining > 0) ...[
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('المتبقي لاحقاً', style: TextStyle(fontSize: 12, color: AppColors.grey)),
              Text('${remaining.toStringAsFixed(0)} ر.س', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ]),
          ],
        ],
      ),
    );
  }

  void _submitOrder() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك عبّي الاسم ورقم الجوال والعنوان')),
      );
      return;
    }

    double paid;
    switch (_selected) {
      case PaymentType.cashOnDelivery:
        paid = 0;
        break;
      case PaymentType.deposit:
        paid = depositAmount;
        break;
      case PaymentType.fullOnline:
        paid = total;
        break;
    }
    final order = OrderModel(
      id: '',
      product: widget.product,
      quantity: widget.quantity,
      paymentType: _selected,
      totalAmount: total,
      paidAmount: paid,
      remainingAmount: total - paid,
      status: _selected == PaymentType.fullOnline ? OrderStatus.confirmed : OrderStatus.pendingApproval,
      createdAt: DateTime.now(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final orderId = await OrderService().submitOrder(
        order,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerAddress: _addressController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      final savedOrder = OrderModel(
        id: orderId,
        product: order.product,
        quantity: order.quantity,
        paymentType: order.paymentType,
        totalAmount: order.totalAmount,
        paidAmount: order.paidAmount,
        remainingAmount: order.remainingAmount,
        status: order.status,
        createdAt: order.createdAt,
      );
      Navigator.pushReplacement(context, SlideFadeRoute(page: OrderConfirmationScreen(order: savedOrder)));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب: $e')),
      );
    }
  }
}