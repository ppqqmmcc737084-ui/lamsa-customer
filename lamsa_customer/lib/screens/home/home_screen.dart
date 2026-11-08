import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/banner_service.dart';
import '../../services/ads_service.dart';
import '../../widgets/home/banner_carousel.dart';
import '../../widgets/home/category_row.dart';
import '../../widgets/home/product_card.dart';
import '../../widgets/home/section_header.dart';
import '../product/product_detail_screen.dart';
import '../all_products/all_products_screen.dart';
import '../search/search_screen.dart';

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

            final sortedBySales = List<Product>.from(products)
              ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
            final bestSellers = sortedBySales.where((p) => p.soldCount > 0).take(6).toList();
            final bestSellerIds = bestSellers.map((p) => p.id).toSet();
            final featured = products.where((p) => p.isFeatured).toList();

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
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                    ),
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
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: AdsService().streamActiveAds(),
                        builder: (context, adSnap) {
                          final ads = adSnap.data ?? [];
                          if (ads.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.campaign_rounded, color: AppColors.accent, size: 18),
                                  SizedBox(width: 6),
                                  Text('📢 إعلانات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.dark)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 130,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: ads.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final ad = ads[index];
                                    return GestureDetector(
                                      onTap: () async {
                                        final p = await ProductService().getProductById(ad['productId']);
                                        if (p != null && context.mounted) {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
                                        }
                                      },
                                      child: Container(
                                        width: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(AppRadius.medium),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(AppRadius.medium),
                                              child: Image.network(ad['productImage'] ?? '', width: 160, height: 130, fit: BoxFit.cover),
                                            ),
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(6)),
                                                child: const Text('إعلان', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent]),
                                                ),
                                                child: Text(ad['productName'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                          );
                        },
                      ),
                      if (products.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text('ما فيه منتجات بهذي الفئة حالياً', style: TextStyle(color: AppColors.grey))),
                        ),
                      if (featured.isNotEmpty) ...[
                        SectionHeader(
                          title: '⭐ منتجات مميزة',
                          onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllProductsScreen(title: 'منتجات مميزة', products: featured))),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 240,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: featured.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) => SizedBox(
                              width: 150,
                              child: GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: featured[index]))),
                                child: ProductCard(product: featured[index]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                      if (bestSellers.isNotEmpty) ...[
                        SectionHeader(
                          title: '🔥 الأكثر مبيعاً',
                          onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllProductsScreen(title: 'الأكثر مبيعاً', products: bestSellers))),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ]),
                  ),
                ),
                if (bestSellers.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.62),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: bestSellers[index]))),
                          child: ProductCard(product: bestSellers[index], forceBestSeller: true),
                        ),
                        childCount: bestSellers.length,
                      ),
                    ),
                  ),
                if (products.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 22, AppSpacing.md, 8),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        title: '✨ تسوقي الآن',
                        onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllProductsScreen(title: 'تسوقي الآن', products: products))),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 4, AppSpacing.md, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.62),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: products[index]))),
                          child: ProductCard(product: products[index], forceBestSeller: bestSellerIds.contains(products[index].id)),
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