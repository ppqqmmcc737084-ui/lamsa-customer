import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../widgets/home/product_card.dart';
import '../../widgets/home/section_header.dart';
import '../checkout/checkout_screen.dart';
import '../../services/cart_service.dart';
import '../../services/review_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imageIndex = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final similar = mockProducts.where((p) => p.id != product.id).take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.dark),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [SizedBox(width: 8)],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CarouselSlider.builder(
                      itemCount: product.allImages.length,
                      itemBuilder: (context, index, _) => CachedNetworkImage(
                        imageUrl: product.allImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      options: CarouselOptions(
                        height: 320,
                        viewportFraction: 1,
                        onPageChanged: (i, _) => setState(() => _imageIndex = i),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: product.allImages.asMap().entries.map((e) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _imageIndex == e.key ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _imageIndex == e.key ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (product.isBestSeller)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                              child: const Text('الأكثر مبيعاً',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          Text('تم بيع ${product.soldCount}+ قطعة', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.dark)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: product.rating,
                            itemCount: 5,
                            itemSize: 16,
                            unratedColor: AppColors.lightGrey,
                            itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.accent),
                          ),
                          const SizedBox(width: 6),
                          Text('${product.rating} (${product.reviewsCount} تقييم)', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text('${product.finalPrice.toStringAsFixed(0)} ر.س',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 10),
                            Text('${product.price.toStringAsFixed(0)} ر.س',
                                style: const TextStyle(fontSize: 15, color: AppColors.grey, decoration: TextDecoration.lineThrough)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text('وفّر ${product.discountPercent}%',
                                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text('الوصف', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.dark)),
                      const SizedBox(height: 6),
                      Text(product.description, style: const TextStyle(fontSize: 13.5, color: AppColors.grey, height: 1.6)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('الكمية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.dark)),
                          const Spacer(),
                          _quantitySelector(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('التقييمات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.dark)),
                          TextButton(
                            onPressed: () => _showAddReviewDialog(context, product.id),
                            child: const Text('أضف تقييمك'),
                          ),
                        ],
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: ReviewService().streamReviews(product.id),
                        builder: (context, snapshot) {
                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('كن أول من يقيّم هذا المنتج', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                            );
                          }
                          return Column(
                            children: docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.medium)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RatingBarIndicator(
                                      rating: (data['rating'] ?? 0).toDouble(),
                                      itemCount: 5,
                                      itemSize: 14,
                                      unratedColor: AppColors.lightGrey,
                                      itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.accent),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(data['comment'] ?? '', style: const TextStyle(fontSize: 12.5, color: AppColors.dark)),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(title: 'منتجات مشابهة', onSeeAll: () {}),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 240,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: similar.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) => SizedBox(
                            width: 150,
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: similar[index])),
                              ),
                              child: ProductCard(product: similar[index]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(context, product),
    );
  }

  Widget _quantitySelector() {
    return Row(
      children: [
        _qtyButton(Icons.remove_rounded, () {
          if (_quantity > 1) setState(() => _quantity--);
        }),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text('$_quantity', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        _qtyButton(Icons.add_rounded, () => setState(() => _quantity++)),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: AppColors.dark),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  CartService.instance.addProduct(product, quantity: _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت الإضافة للسلة'), duration: Duration(seconds: 1)),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: const Text('أضف للسلة'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CheckoutScreen(product: product, quantity: _quantity)),
                  );
                },
                icon: const Icon(Icons.flash_on_rounded, size: 18),
                label: const Text('اطلب الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, String productId) {
    double rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('قيّم هذا المنتج'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                itemCount: 5,
                itemSize: 32,
                itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.accent),
                onRatingUpdate: (value) => rating = value,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'اكتب تعليقك (اختياري)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                await ReviewService().addReview(productId, rating: rating, comment: commentController.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}