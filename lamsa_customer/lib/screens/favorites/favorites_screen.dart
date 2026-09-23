import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../services/favorites_service.dart';
import '../../widgets/home/product_card.dart';
import '../product/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: FavoritesService.instance.favoriteIds,
        builder: (context, favIds, _) {
          final favProducts = mockProducts.where((p) => favIds.contains(p.id)).toList();
          if (favProducts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.grey),
                  SizedBox(height: 12),
                  Text('ما أضفت أي منتج للمفضلة بعد', style: TextStyle(fontSize: 14, color: AppColors.grey)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.62),
            itemCount: favProducts.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: favProducts[index]))),
              child: ProductCard(product: favProducts[index]),
            ),
          );
        },
      ),
    );
  }
}