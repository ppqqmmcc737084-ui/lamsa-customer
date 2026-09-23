import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/cart_service.dart';
import '../checkout/checkout_screen.dart';
import '../checkout/cart_checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السلة')),
      body: ValueListenableBuilder(
        valueListenable: CartService.instance.items,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.grey),
                  SizedBox(height: 12),
                  Text('سلتك فاضية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
                  SizedBox(height: 4),
                  Text('أضف منتجات عشان تبدأ التسوق', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(item.product.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('${item.product.finalPrice.toStringAsFixed(0)} ر.س',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _qtyBtn(Icons.remove_rounded, () => CartService.instance.updateQuantity(item.product.id, item.quantity - 1)),
                              Container(width: 30, alignment: Alignment.center, child: Text('${item.quantity}')),
                              _qtyBtn(Icons.add_rounded, () => CartService.instance.updateQuantity(item.product.id, item.quantity + 1)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي', style: TextStyle(fontSize: 14, color: AppColors.grey)),
                          Text('${CartService.instance.totalPrice.toStringAsFixed(0)} ر.س',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final firstItem = items.first;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(product: firstItem.product, quantity: firstItem.quantity),
                              ),
                            );
                          },
                          child: const Text('إتمام الطلب'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: AppColors.dark),
      ),
    );
  }
}