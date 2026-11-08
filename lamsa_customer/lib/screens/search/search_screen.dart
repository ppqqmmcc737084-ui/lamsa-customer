import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/home/product_card.dart';
import '../product/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'دور على منتج أو متجر...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: ProductService().streamProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final allProducts = snapshot.data ?? [];

          if (_query.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_rounded, size: 56, color: AppColors.grey),
                  SizedBox(height: 12),
                  Text('دور باسم المنتج أو اسم المتجر', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            );
          }

          final q = _query.toLowerCase();
          final byName = allProducts.where((p) => p.name.toLowerCase().contains(q));
          final byStore = allProducts.where((p) => p.storeName.toLowerCase().contains(q));
          final results = {...byName, ...byStore}.toList();

          final matchingStoreNames = allProducts
              .map((p) => p.storeName)
              .toSet()
              .where((name) => name.toLowerCase().contains(q))
              .toList();

          if (results.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded, size: 56, color: AppColors.grey),
                  SizedBox(height: 12),
                  Text('ما لقينا أي نتيجة', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              if (matchingStoreNames.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 12, AppSpacing.md, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('متاجر', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.grey)),
                        const SizedBox(height: 8),
                        ...matchingStoreNames.map((storeName) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.medium)),
                              child: Row(
                                children: [
                                  const Icon(Icons.storefront_rounded, color: AppColors.primary),
                                  const SizedBox(width: 10),
                                  Text(storeName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            )),
                        const SizedBox(height: 8),
                        const Text('منتجات', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.grey)),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.62),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: results[index]))),
                      child: ProductCard(product: results[index]),
                    ),
                    childCount: results.length,
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
            ],
          );
        },
      ),
    );
  }
}