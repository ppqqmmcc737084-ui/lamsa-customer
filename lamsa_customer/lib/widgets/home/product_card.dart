import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../common/favorite_button.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.medium)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Hero(
                    tag: 'product_${product.id}',
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.lightGrey,
                        highlightColor: Colors.white,
                        child: Container(color: AppColors.lightGrey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.lightGrey,
                        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              if (product.isBestSeller)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                    child: const Text('الأكثر مبيعاً',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              if (product.hasDiscount)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                    child: Text('-${product.discountPercent}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
               Positioned(bottom: 8, left: 8, child: FavoriteButton(productId: product.id)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.dark)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: product.rating,
                      itemCount: 5,
                      itemSize: 12,
                      unratedColor: AppColors.lightGrey,
                      itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.accent),
                    ),
                    const SizedBox(width: 4),
                    Text('(${product.reviewsCount})', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('${product.finalPrice.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text('${product.price.toStringAsFixed(0)} ر.س',
                          style: const TextStyle(fontSize: 11, color: AppColors.grey, decoration: TextDecoration.lineThrough)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}