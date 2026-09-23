import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/home/banner_carousel.dart';
import '../../widgets/home/category_row.dart';
import '../../widgets/home/product_card.dart';
import '../../widgets/home/section_header.dart';
import '../product/product_detail_screen.dart';
import '../search/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/banner_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Product>>(
          stream: ProductService().streamProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }

            final allProducts = snapshot.data ?? [];
            final products = _selectedCategory == null
                ? allProducts
                : allProducts.where((p) => p.category == _selectedCategory).toList();
            final bestSellers = products.where((p) => p.isBestSeller).toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  title: const Text('لمسة',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  actions: [
                    IconButton(
                    icon: const Icon(Icons.search_rounded, color: AppColors.dark),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
                    IconButton(icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.dark), onPressed: () {}),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 6),
                      StreamBuilder<QuerySnapshot>(
                        stream: BannerService().streamBanners(),
                        builder: (context, bannerSnap) {
                          final bannerDocs = bannerSnap.data?.docs ?? [];
                          if (bannerDocs.isEmpty) return const SizedBox.shrink();
                          final banners = bannerDocs.map((d) => d.data() as Map<String, dynamic>).toList();
                          return BannerCarousel(
                            banners: banners,
                            onTap: (productId) async {
                              if (productId == null) return;
                              final p = await ProductService().getProductById(productId);
                              if (p != null && context.mounted) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      CategoryRow(
                        categories: mockCategories,
                        selectedName: _selectedCategory,
                        onSelect: (name) => setState(() {
                          _selectedCategory = _selectedCategory == name ? null : name;
                        }),
                      ),
                      const SizedBox(height: 22),
                      if (products.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text('ما فيه منتجات بهذي الفئة حالياً', style: TextStyle(color: AppColors.grey)),
                          ),
                        ),
                      if (bestSellers.isNotEmpty) ...[
                        SectionHeader(title: '🔥 الأكثر مبيعاً', onSeeAll: () {}),
                        const SizedBox(height: 12),
                      ],
                    ]),
                  ),
                ),
                if (bestSellers.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.62),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: bestSellers[index]))),
                          child: ProductCard(product: bestSellers[index]),
                        ),
                        childCount: bestSellers.length,
                      ),
                    ),
                  ),
                if (products.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 22, AppSpacing.md, 8),
                    sliver: SliverToBoxAdapter(child: SectionHeader(title: '✨ تسوقي الآن', onSeeAll: () {})),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 4, AppSpacing.md, 24),
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
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}