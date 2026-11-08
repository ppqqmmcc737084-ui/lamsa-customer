import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../services/store_service.dart';
import '../../widgets/home/product_card.dart';
import '../product/product_detail_screen.dart';

class StorePageScreen extends StatelessWidget {
  final String sellerId;
  final String storeName;
  const StorePageScreen({super.key, required this.sellerId, required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.storefront_rounded, color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(height: 10),
                      Text(storeName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<List<Product>>(
            stream: StoreService().streamStoreProducts(sellerId),
            builder: (context, snapshot) {
              final products = snapshot.data ?? [];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );
              }

              if (products.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('ما فيه منتجات بهذا المتجر حالياً', style: TextStyle(color: AppColors.grey))),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.62),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: products[index]))),
                      child: ProductCard(product: products[index]),
                    ),
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}