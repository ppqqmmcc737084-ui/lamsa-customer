import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/page_transitions.dart';
import '../../models/product.dart';
import '../../models/payment_type.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../services/coupon_service.dart';
import 'order_confirmation_screen.dart';
import '../addresses/addresses_screen.dart';

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
  final _refController = TextEditingController();

  // ✅ 1. متغيرات كود الخصم
  final _couponController = TextEditingController();
  int _couponDiscount = 0;
  String? _couponError;
  bool _checkingCoupon = false;

  // ✅ 2. حسابات الأسعار الجديدة (الخصم على المنتج فقط، وليس على التوصيل)
  double get subtotal => widget.product.finalPrice * widget.quantity;
  double get total => subtotal + widget.product.deliveryFee; // الإجمالي قبل الخصم
  
  double get discountedSubtotal => subtotal * (1 - _couponDiscount / 100); // الخصم على المنتج فقط
  double get discountedTotal => discountedSubtotal + widget.product.deliveryFee; // الإجمالي النهائي
  
  double get depositAmount => discountedSubtotal * widget.product.depositPercent; // العربون بناءً على سعر المنتج بعد الخصم

  bool get _needsReference => _selected == PaymentType.deposit || _selected == PaymentType.walletTransfer;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
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
            _orderSummaryCard(),
            const SizedBox(height: 20),
            const Text('اختر طريقة الدفع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...widget.product.allowedPayments.map(_paymentOption),
            const SizedBox(height: 12),
            if (_needsReference) ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(AppRadius.medium)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('حوّل المبلغ على:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text('${widget.product.walletName ?? ''} — ${widget.product.walletNumber ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      _selected == PaymentType.deposit
                          ? 'المبلغ المطلوب تحويله: ${depositAmount.toStringAsFixed(0)} ر.س (عربون)'
                          : 'المبلغ المطلوب تحويله: ${discountedTotal.toStringAsFixed(0)} ر.س (كامل)',
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: _refController, decoration: const InputDecoration(hintText: 'رقم مرجع التحويل (من رسالة التأكيد)')),
                    const SizedBox(height: 6),
                    const Text('⚠️ الطلب يبقى بانتظار موافقة البائع لحين تأكده من استلام التحويل فعلياً.',
                        style: TextStyle(fontSize: 11, color: AppColors.grey)),
                  ],
                ),
              ),
            ],
            
            // ✅ 3. قسم كود الخصم
            const Text('كود الخصم', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'كود الخصم (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _checkingCoupon ? null : () async {
                    setState(() {
                      _checkingCoupon = true;
                      _couponError = null;
                    });
                    final result = await CouponService().validate(
                      _couponController.text,
                      widget.product.sellerId,
                      widget.product.id,
                    );
                    setState(() {
                      _checkingCoupon = false;
                      if (result == null) {
                        _couponDiscount = 0;
                        _couponError = 'الكود غير صالح أو منتهي الصلاحية';
                      } else {
                        _couponDiscount = result.discountPercent;
                      }
                    });
                  },
                  child: _checkingCoupon
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('تطبيق'),
                ),
              ],
            ),
            if (_couponError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_couponError!, style: const TextStyle(color: AppColors.primary, fontSize: 11)),
              ),
            if (_couponDiscount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('تم تطبيق خصم $_couponDiscount% على سعر المنتج ✅', style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            const SizedBox(height: 20),

            const Text('بيانات التوصيل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'الاسم الكامل')),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressesScreen(selectMode: true)),
                );
                if (result != null) {
                  setState(() {
                    _addressController.text = result['fullAddress'];
                    _phoneController.text = result['phone'];
                  });
                }
              },
              icon: const Icon(Icons.location_on_outlined, size: 18),
              label: const Text('اختر من عناويني المحفوظة'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            ),
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
                child: const Text('تأكيد الطلب'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ 4. تحديث بطاقة الملخص لتوضيح التفصيل (سعر المنتج + التوصيل)
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.product.deliveryFee > 0)
                Text('+ ${widget.product.deliveryFee.toStringAsFixed(0)} توصيل', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
              Text('${discountedTotal.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
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

  // ✅ 5. تحديث ملخص المبلغ ليعكس الحسابات الجديدة بدقة
  Widget _amountSummary() {
    String label;
    double amountNow;
    double remaining;
    switch (_selected) {
      case PaymentType.cashOnDelivery:
        label = 'يدفع عند الاستلام';
        amountNow = 0;
        remaining = discountedTotal;
        break;
      case PaymentType.deposit:
        label = 'العربون المحوّل';
        amountNow = depositAmount;
        remaining = discountedTotal - depositAmount;
        break;
      case PaymentType.walletTransfer:
      case PaymentType.fullOnline:
        label = 'المبلغ المحوّل';
        amountNow = discountedTotal;
        remaining = 0;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Column(
        children: [
          if (_couponDiscount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('سعر المنتج قبل الخصم', style: TextStyle(fontSize: 12, color: AppColors.grey, decoration: TextDecoration.lineThrough)),
                Text('${subtotal.toStringAsFixed(0)} ر.س', style: const TextStyle(fontSize: 12, color: AppColors.grey, decoration: TextDecoration.lineThrough)),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (widget.product.deliveryFee > 0) ...[
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('رسوم التوصيل', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                Text('${widget.product.deliveryFee.toStringAsFixed(0)} ر.س', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('إجمالي الطلب', style: TextStyle(fontWeight: FontWeight.w700)), Text('${discountedTotal.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary))]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('${amountNow.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
          ]),
          if (remaining > 0) ...[
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('المتبقي عند الاستلام', style: TextStyle(fontSize: 12, color: AppColors.grey)),
              Text('${remaining.toStringAsFixed(0)} ر.س', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ]),
          ],
        ],
      ),
    );
  }

  // ✅ 6. تحديث إرسال الطلب ليستخدم المبلغ بعد الخصم + التوصيل
  void _submitOrder() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك عبّي الاسم ورقم الجوال والعنوان')),
      );
      return;
    }

    if (_needsReference && _refController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم مرجع التحويل')),
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
      case PaymentType.walletTransfer:
      case PaymentType.fullOnline:
        paid = discountedTotal;
        break;
    }

    final order = OrderModel(
      id: '',
      product: widget.product,
      quantity: widget.quantity,
      paymentType: _selected,
      totalAmount: discountedTotal, // ✅ الإجمالي النهائي يشمل الخصم على المنتج + التوصيل
      paidAmount: paid,
      remainingAmount: discountedTotal - paid,
      status: OrderStatus.pendingApproval,
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
        transferReference: _needsReference ? _refController.text.trim() : null,
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
        transferReference: _needsReference ? _refController.text.trim() : null,
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