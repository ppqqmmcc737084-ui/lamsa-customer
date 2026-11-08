import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lamsa_customer/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_colors.dart';
import '../../data/mock_data.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../models/store_category.dart';
import '../../services/ads_service.dart';
import '../../services/banner_service.dart';
import '../../services/cart_service.dart';
import '../../services/product_service.dart';
import '../../widgets/home/banner_carousel.dart';
import '../../widgets/home/category_row.dart';
import '../../widgets/home/product_card.dart';
import '../../widgets/home/section_header.dart';
import '../all_products/all_products_screen.dart';
import '../cart/cart_screen.dart';
import '../product/product_detail_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;
  late Stream<List<Product>> _productsStream = ProductService().streamProducts();
  late final _bannersStream = BannerService().streamBanners();
  late final _adsStream = AdsService().streamActiveAds();

  /// الفئات الفعلية من المنتجات الموجودة، والأيقونة من القائمة المعروفة أو أيقونة عامة.
  List<StoreCategory> _categoriesFrom(List<Product> all) {
    final known = {for (final c in mockCategories) c.name: c};
    final names = <String>[];
    for (final p in all) {
      final n = p.category.trim();
      if (n.isNotEmpty && !names.contains(n)) names.add(n);
    }
    return names
        .map((n) => known[n] ?? StoreCategory(id: n, name: n, icon: Icons.category_rounded))
        .toList();
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
  }

  void _openAll(BuildContext context, String title, List<Product> list) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AllProductsScreen(title: title, products: list)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Product>>(
          stream: _productsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError && !snapshot.hasData) return _errorView(context);
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final all = snapshot.data!;
            final categories = _categoriesFrom(all);
            final selected = categories.any((c) => c.name == _selectedCategory) ? _selectedCategory : null;
            final products = selected == null ? all : all.where((p) => p.category.trim() == selected).toList();
            final bestSellers = (List<Product>.from(products)..sort((a, b) => b.soldCount.compareTo(a.soldCount)))
                .where((p) => p.soldCount > 0)
                .take(6)
                .toList();
            final bestIds = bestSellers.map((p) => p.id).toSet();
            final featured = products.where((p) => p.isFeatured).toList();

            return CustomScrollView(
              slivers: [
                _appBar(context),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 6),
                      StreamBuilder<QuerySnapshot>(
                        stream: _bannersStream,
                        builder: (context, bannerSnap) {
                          final docs = bannerSnap.data?.docs ?? [];
                          if (docs.isEmpty) return const SizedBox.shrink();
                          final banners = docs.map((d) => d.data() as Map<String, dynamic>).toList();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 22),
                            child: BannerCarousel(
                              banners: banners,
                              onTap: (productId) async {
                                if (productId == null || productId.isEmpty) return;
                                final p = await ProductService().getProductById(productId);
                                if (p != null && context.mounted) _openProduct(context, p);
                              },
                            ),
                          );
                        },
                      ),
                      if (categories.isNotEmpty) ...[
                        CategoryRow(
                          categories: categories,
                          selectedName: selected,
                          onSelect: (name) => setState(() {
                            _selectedCategory = selected == name ? null : name;
                          }),
                        ),
                        const SizedBox(height: 22),
                      ],
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _adsStream,
                        builder: (context, adSnap) {
                          final ads = adSnap.data ?? [];
                          if (ads.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.campaign_rounded, color: AppColors.accent, size: 18),
                                  const SizedBox(width: 6),
                                  Text('إعلانات',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textMain)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 130,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: ads.length,
                                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) => _adCard(context, ads[index]),
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                          );
                        },
                      ),
                      if (all.isEmpty)
                        _emptyView(context, Icons.storefront_outlined, 'ما فيه منتجات حالياً',
                            'يضيف البائعون منتجات جديدة باستمرار، ارجع بعد قليل')
                      else if (products.isEmpty)
                        _emptyView(context, Icons.search_off_rounded, 'ما فيه منتجات بهذي الفئة حالياً', null),
                      if (featured.isNotEmpty) ...[
                        SectionHeader(
                          title: '⭐ منتجات مميزة',
                          onSeeAll: () => _openAll(context, 'منتجات مميزة', featured),
                        ),
                        const SizedBox(height: 12),
                        _productRow(context, featured),
                        const SizedBox(height: 22),
                      ],
                      if (bestSellers.isNotEmpty) ...[
                        SectionHeader(
                          title: '🔥 الأكثر مبيعاً',
                          onSeeAll: () => _openAll(context, 'الأكثر مبيعاً', bestSellers),
                        ),
                        const SizedBox(height: 12),
                        _productRow(context, bestSellers, forceBest: true),
                        const SizedBox(height: 22),
                      ],
                      if (products.isNotEmpty) ...[
                        SectionHeader(
                          title: '✨ تسوقي الآن',
                          onSeeAll: () => _openAll(context, 'تسوقي الآن', products),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ]),
                  ),
                ),
                if (products.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final p = products[index];
                          return GestureDetector(
                            onTap: () => _openProduct(context, p),
                            child: ProductCard(product: p, forceBestSeller: bestIds.contains(p.id)),
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Text(
        AppLocalizations.of(context).appName,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: context.textMain),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
        ),
        ValueListenableBuilder<List<CartItem>>(
          valueListenable: CartService.instance.items,
          builder: (context, items, _) {
            final count = items.fold<int>(0, (s, i) => s + i.quantity);
            return IconButton(
              icon: Badge(
                label: Text('$count'),
                isLabelVisible: count > 0,
                child: Icon(Icons.shopping_bag_outlined, color: context.textMain),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _productRow(BuildContext context, List<Product> list, {bool forceBest = false}) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = list[index];
          return SizedBox(
            width: 150,
            child: GestureDetector(
              onTap: () => _openProduct(context, p),
              child: ProductCard(product: p, forceBestSeller: forceBest ? true : null),
            ),
          );
        },
      ),
    );
  }

  Widget _adCard(BuildContext context, Map<String, dynamic> ad) {
    final image = (ad['productImage'] ?? '').toString();
    final name = (ad['productName'] ?? '').toString();
    return GestureDetector(
      onTap: () async {
        final id = ad['productId'];
        if (id is! String || id.isEmpty) return;
        final p = await ProductService().getProductById(id);
        if (p != null && context.mounted) _openProduct(context, p);
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [BoxShadow(color: context.softShadow, blurRadius: 8)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: context.fieldBg),
                errorWidget: (_, _, _) => Container(
                  color: context.fieldBg,
                  child: Icon(Icons.image_not_supported_outlined, color: context.textMuted),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('إعلان',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
              ),
              if (name.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                      ),
                    ),
                    child: Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyView(BuildContext context, IconData icon, String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 52, color: context.textMuted),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textMain)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: context.textMuted)),
          ],
        ],
      ),
    );
  }

  Widget _errorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: context.textMuted),
            const SizedBox(height: 12),
            Text('تعذّر تحميل المنتجات',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textMain)),
            const SizedBox(height: 4),
            Text('تأكد من الإنترنت وحاول مرة ثانية',
                style: TextStyle(fontSize: 12, color: context.textMuted)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => setState(() => _productsStream = ProductService().streamProducts()),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(160, 44)),
            ),
          ],
        ),
      ),
    );
  }
}
