import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_colors.dart';
import '../../models/product.dart';
import '../common/favorite_button.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool? forceBestSeller;
  const ProductCard({super.key, required this.product, this.forceBestSeller});

  bool get _isBestSeller => forceBestSeller ?? product.isBestSeller;

  @override
  Widget build(BuildContext context) {
    final hasRating = product.reviewsCount > 0;
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(color: context.softShadow, blurRadius: 10, offset: const Offset(0, 4)),
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
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Shimmer.fromColors(
                      baseColor: context.fieldBg,
                      highlightColor: context.cardBg,
                      child: Container(color: context.fieldBg),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: context.fieldBg,
                      child: Icon(Icons.image_not_supported_outlined, color: context.textMuted),
                    ),
                  ),
                ),
              ),
              if (_isBestSeller)
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
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textMain)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                    const SizedBox(width: 2),
                    Text(
                      hasRating ? product.rating.toStringAsFixed(1) : 'بدون تقييم',
                      style: TextStyle(
                        fontSize: hasRating ? 11 : 10,
                        fontWeight: hasRating ? FontWeight.w700 : FontWeight.w400,
                        color: hasRating ? context.textMain : context.textMuted,
                      ),
                    ),
                    if (hasRating) ...[
                      const SizedBox(width: 3),
                      Text('(${product.reviewsCount})', style: TextStyle(fontSize: 10, color: context.textMuted)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${product.finalPrice.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text('${product.price.toStringAsFixed(0)} ر.س',
                          style: TextStyle(fontSize: 11, color: context.textMuted, decoration: TextDecoration.lineThrough)),
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
