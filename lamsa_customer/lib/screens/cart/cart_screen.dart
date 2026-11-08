import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_colors.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../checkout/cart_checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const int _maxQuantity = 99;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السلة')),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartService.instance.items,
        builder: (context, items, _) {
          if (items.isEmpty) return _empty(context);

          final subtotal = items.fold<double>(0, (s, i) => s + i.product.finalPrice * i.quantity);
          final delivery = items.fold<double>(0, (s, i) => s + i.product.deliveryFee);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _itemTile(context, items[index]),
                ),
              ),
              _footer(context, items, subtotal, delivery),
            ],
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: context.isDarkMode ? 0.18 : 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text('سلتك فاضية',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.textMain)),
            const SizedBox(height: 6),
            Text('أضف منتجات من الرئيسية وتعال أكمل طلبك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: context.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _itemTile(BuildContext context, CartItem item) {
    final product = item.product;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [BoxShadow(color: context.softShadow, blurRadius: 8)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(width: 64, height: 64, color: context.fieldBg),
              errorWidget: (_, _, _) => Container(
                width: 64,
                height: 64,
                color: context.fieldBg,
                child: Icon(Icons.image_not_supported_outlined, color: context.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.textMain)),
                const SizedBox(height: 4),
                Text('${product.finalPrice.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                if (product.deliveryFee > 0)
                  Text('+ ${product.deliveryFee.toStringAsFixed(0)} توصيل',
                      style: TextStyle(fontSize: 10.5, color: context.textMuted)),
              ],
            ),
          ),
          Row(
            children: [
              _qtyBtn(context, Icons.remove_rounded,
                  () => CartService.instance.updateQuantity(product.id, item.quantity - 1)),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text('${item.quantity}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: context.textMain)),
              ),
              _qtyBtn(
                context,
                Icons.add_rounded,
                item.quantity < _maxQuantity
                    ? () => CartService.instance.updateQuantity(product.id, item.quantity + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, List<CartItem> items, double subtotal, double delivery) {
    final total = subtotal + delivery;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        boxShadow: [BoxShadow(color: context.softShadow, blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _line(context, 'المنتجات', subtotal),
            if (delivery > 0) ...[
              const SizedBox(height: 6),
              _line(context, 'رسوم التوصيل', delivery),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textMain)),
                Text('${total.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 6),
            Text('الدفع من السلة عند الاستلام. للدفع بالتحويل اطلب المنتج مباشرة من صفحته.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: context.textMuted)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartCheckoutScreen(items: List<CartItem>.of(items)),
                    ),
                  );
                },
                child: Text('إتمام الطلب (${items.length})'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: context.textMuted)),
        Text('${amount.toStringAsFixed(0)} ر.س',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textMain)),
      ],
    );
  }

  Widget _qtyBtn(BuildContext context, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: context.fieldBg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: onTap == null ? context.textMuted : context.textMain),
      ),
    );
  }
}
