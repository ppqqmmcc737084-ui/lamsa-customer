import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../widgets/home/product_card.dart';
import '../product/product_detail_screen.dart';

class AllProductsScreen extends StatelessWidget {
  final String title;
  final List<Product> products;
  const AllProductsScreen({super.key, required this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: products.isEmpty
          ? const Center(child: Text('ما فيه منتجات هنا حالياً', style: TextStyle(color: AppColors.grey)))
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.62),
              itemCount: products.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: products[index]))),
                child: ProductCard(product: products[index]),
              ),
            ),
    );
  }
}