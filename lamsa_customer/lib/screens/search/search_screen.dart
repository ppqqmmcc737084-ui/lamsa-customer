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
            hintText: 'دور على منتج...',
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
                  Text('اكتب اسم المنتج اللي تدور عليه', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            );
          }

          final results = allProducts
              .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
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

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.62),
            itemCount: results.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: results[index]))),
              child: ProductCard(product: results[index]),
            ),
          );
        },
      ),
    );
  }
}