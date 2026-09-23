import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/page_transitions.dart';
import '../../models/cart_item.dart';
import '../../models/payment_type.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/cart_service.dart';
import 'order_confirmation_screen.dart';

class CartCheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  const CartCheckoutScreen({super.key, required this.items});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  late PaymentType _selected;
  bool _loading = false;
  String? _error;

  List<PaymentType> get _commonPayments {
    final sets = widget.items.map((i) => i.product.allowedPayments.toSet()).toList();
    return sets.reduce((a, b) => a.intersection(b)).toList();
  }

  double get total => widget.items.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  void initState() {
    super.initState();
    _selected = _commonPayments.isNotEmpty ? _commonPayments.first : PaymentType.cashOnDelivery;
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      setState(() => _error = 'من فضلك عبّي الاسم ورقم الجوال والعنوان');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      for (final item in widget.items) {
        final itemTotal = item.totalPrice;
        double paid;
        switch (_selected) {
          case PaymentType.cashOnDelivery:
            paid = 0;
            break;
          case PaymentType.deposit:
            paid = itemTotal * item.product.depositPercent;
            break;
          case PaymentType.fullOnline:
            paid = itemTotal;
            break;
        }
        final order = OrderModel(
          id: '',
          product: item.product,
          quantity: item.quantity,
          paymentType: _selected,
          totalAmount: itemTotal,
          paidAmount: paid,
          remainingAmount: itemTotal - paid,
          status: _selected == PaymentType.fullOnline ? OrderStatus.confirmed : OrderStatus.pendingApproval,
          createdAt: DateTime.now(),
        );
        await OrderService().submitOrder(
          order,
          customerName: _nameController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          customerAddress: _addressController.text.trim(),
        );
      }

      CartService.instance.clear();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        SlideFadeRoute(
          page: OrderConfirmationScreen(
            order: OrderModel(
              id: 'multi',
              product: widget.items.first.product,
              quantity: widget.items.fold(0, (s, i) => s + i.quantity),
              paymentType: _selected,
              totalAmount: total,
              paidAmount: _selected == PaymentType.fullOnline ? total : 0,
              remainingAmount: _selected == PaymentType.fullOnline ? 0 : total,
              status: _selected == PaymentType.fullOnline ? OrderStatus.confirmed : OrderStatus.pendingApproval,
              createdAt: DateTime.now(),
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء إرسال الطلب: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.items.length} منتج بالسلة', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            ...widget.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                      Text('×${item.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                      const SizedBox(width: 8),
                      Text('${item.totalPrice.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                )),
            const Divider(height: 24),
            const Text('اختر طريقة الدفع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (_commonPayments.isEmpty)
              const Text('منتجات السلة ما فيها طريقة دفع مشتركة، احذف منتج وجرب مرة ثانية',
                  style: TextStyle(color: AppColors.primary, fontSize: 12))
            else
              ..._commonPayments.map((type) {
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
              }),
            const SizedBox(height: 20),
            const Text('بيانات التوصيل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'الاسم الكامل')),
            const SizedBox(height: 10),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'رقم الجوال')),
            const SizedBox(height: 10),
            TextField(controller: _addressController, decoration: const InputDecoration(hintText: 'العنوان')),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(AppRadius.medium)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي الكلي', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('${total.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_loading || _commonPayments.isEmpty) ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('تأكيد كل الطلبات'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}