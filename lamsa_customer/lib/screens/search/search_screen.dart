import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/utils/arabic_search.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/home/product_card.dart';
import '../product/product_detail_screen.dart';
import '../store/store_page_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  late final Stream<List<Product>> _productsStream = ProductService().streamProducts();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _message(BuildContext context, IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: context.textMuted),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: context.textMuted)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'دور على منتج أو متجر أو فئة...',
            border: InputBorder.none,
            filled: false,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError && !snapshot.hasData) {
            return _message(context, Icons.wifi_off_rounded, 'تعذّر تحميل المنتجات، حاول مرة ثانية');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final all = snapshot.data!;

          if (_query.isEmpty) {
            return _message(context, Icons.search_rounded, 'دور باسم المنتج أو المتجر أو الفئة');
          }

          final q = normalizeArabic(_query);
          bool nameMatch(Product p) => normalizeArabic(p.name).contains(q);
          bool matches(Product p) =>
              nameMatch(p) || normalizeArabic(p.storeName).contains(q) || normalizeArabic(p.category).contains(q);

          final results = all.where(matches).toList()
            ..sort((a, b) => (nameMatch(a) ? 0 : 1).compareTo(nameMatch(b) ? 0 : 1));

          final stores = <String, String>{};
          for (final p in all) {
            if (p.storeName.isNotEmpty && p.sellerId.isNotEmpty && normalizeArabic(p.storeName).contains(q)) {
              stores[p.storeName] = p.sellerId;
            }
          }

          if (results.isEmpty) {
            return _message(context, Icons.search_off_rounded, 'ما لقينا أي نتيجة');
          }

          return CustomScrollView(
            slivers: [
              if (stores.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 12, AppSpacing.md, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('متاجر',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: context.textMuted)),
                        const SizedBox(height: 8),
                        ...stores.entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: context.cardBg,
                                borderRadius: BorderRadius.circular(AppRadius.medium),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StorePageScreen(sellerId: entry.value, storeName: entry.key),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.storefront_rounded, color: AppColors.primary),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(entry.key,
                                              style: TextStyle(fontWeight: FontWeight.w700, color: context.textMain)),
                                        ),
                                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.textMuted),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 8, AppSpacing.md, 8),
                  child: Text('منتجات (${results.length})',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: context.textMuted)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.62,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: results[index])),
                      ),
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
