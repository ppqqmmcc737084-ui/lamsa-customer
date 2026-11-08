import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_colors.dart';
import '../../models/payment_type.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/product_service.dart';
import '../../services/review_service.dart';
import '../../widgets/home/product_card.dart';
import '../../widgets/home/section_header.dart';
import '../cart/cart_screen.dart';
import '../checkout/checkout_screen.dart';
import '../store/store_page_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const int _maxQuantity = 99;
  int _imageIndex = 0;
  int _quantity = 1;
  late final Stream<List<Product>> _allProductsStream = ProductService().streamProducts();
  late final Stream<QuerySnapshot> _reviewsStream = ReviewService().streamReviews(widget.product.id);

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.allImages.where((u) => u.isNotEmpty).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _gallery(context, images),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.isBestSeller || product.soldCount > 0) ...[
                        _badgesRow(context, product),
                        const SizedBox(height: 8),
                      ],
                      Text(product.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.textMain)),
                      if (product.storeName.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _storeLink(context, product),
                      ],
                      const SizedBox(height: 8),
                      _ratingRow(context, product),
                      const SizedBox(height: 14),
                      _priceRow(context, product),
                      if (product.deliveryFee > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 16, color: context.textMuted),
                            const SizedBox(width: 6),
                            Text('رسوم التوصيل ${product.deliveryFee.toStringAsFixed(0)} ر.س',
                                style: TextStyle(fontSize: 12, color: context.textMuted)),
                          ],
                        ),
                      ],
                      if (product.allowedPayments.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _sectionTitle(context, 'طرق الدفع'),
                        const SizedBox(height: 8),
                        _paymentChips(context, product),
                      ],
                      if (product.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _sectionTitle(context, 'الوصف'),
                        const SizedBox(height: 6),
                        Text(product.description,
                            style: TextStyle(fontSize: 13.5, color: context.textMuted, height: 1.6)),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _sectionTitle(context, 'الكمية'),
                          const Spacer(),
                          _quantitySelector(context),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle(context, 'التقييمات'),
                          TextButton(
                            onPressed: () => _showAddReviewDialog(context, product.id),
                            child: const Text('أضف تقييمك'),
                          ),
                        ],
                      ),
                      _reviewsList(context),
                      _similarSection(context, product),
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

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textMain));
  }

  Widget _gallery(BuildContext context, List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 320,
        width: double.infinity,
        color: context.fieldBg,
        child: Icon(Icons.image_not_supported_outlined, size: 48, color: context.textMuted),
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider.builder(
          itemCount: images.length,
          itemBuilder: (context, index, _) => CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (_, _) => Container(color: context.fieldBg),
            errorWidget: (_, _, _) => Container(
              color: context.fieldBg,
              child: Icon(Icons.image_not_supported_outlined, color: context.textMuted),
            ),
          ),
          options: CarouselOptions(
            height: 320,
            viewportFraction: 1,
            enableInfiniteScroll: images.length > 1,
            onPageChanged: (i, _) => setState(() => _imageIndex = i),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((e) {
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
    );
  }

  Widget _badgesRow(BuildContext context, Product product) {
    return Row(
      children: [
        if (product.isBestSeller)
          Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
            child: const Text('الأكثر مبيعاً',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        if (product.soldCount > 0)
          Text('تم بيع ${product.soldCount}+ قطعة', style: TextStyle(fontSize: 12, color: context.textMuted)),
      ],
    );
  }

  Widget _storeLink(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StorePageScreen(sellerId: product.sellerId, storeName: product.storeName),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront_outlined, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(product.storeName,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _ratingRow(BuildContext context, Product product) {
    if (product.reviewsCount == 0) {
      return Row(
        children: [
          Icon(Icons.star_border_rounded, size: 16, color: context.textMuted),
          const SizedBox(width: 4),
          Text('لا توجد تقييمات بعد', style: TextStyle(fontSize: 12, color: context.textMuted)),
        ],
      );
    }
    return Row(
      children: [
        RatingBarIndicator(
          rating: product.rating,
          itemCount: 5,
          itemSize: 16,
          unratedColor: context.fieldBg,
          itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.accent),
        ),
        const SizedBox(width: 6),
        Text('${product.rating.toStringAsFixed(1)} (${product.reviewsCount} تقييم)',
            style: TextStyle(fontSize: 12, color: context.textMuted)),
      ],
    );
  }

  Widget _priceRow(BuildContext context, Product product) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        Text('${product.finalPrice.toStringAsFixed(0)} ر.س',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
        if (product.hasDiscount) ...[
          Text('${product.price.toStringAsFixed(0)} ر.س',
              style: TextStyle(fontSize: 15, color: context.textMuted, decoration: TextDecoration.lineThrough)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('وفّر ${product.discountPercent}%',
                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ],
    );
  }

  Widget _paymentChips(BuildContext context, Product product) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product.allowedPayments.map((PaymentType t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: context.fieldBg, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(t.icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(t.label,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: context.textMain)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _quantitySelector(BuildContext context) {
    return Row(
      children: [
        _qtyButton(context, Icons.remove_rounded, _quantity > 1 ? () => setState(() => _quantity--) : null),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text('$_quantity',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textMain)),
        ),
        _qtyButton(context, Icons.add_rounded, _quantity < _maxQuantity ? () => setState(() => _quantity++) : null),
      ],
    );
  }

  Widget _qtyButton(BuildContext context, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: context.fieldBg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: onTap == null ? context.textMuted : context.textMain),
      ),
    );
  }

  Widget _reviewsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _reviewsStream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('كن أول من يقيّم هذا المنتج', style: TextStyle(color: context.textMuted, fontSize: 12)),
          );
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final comment = (data['comment'] ?? '').toString().trim();
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(AppRadius.medium)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBarIndicator(
                    rating: ((data['rating'] ?? 0) as num).toDouble(),
                    itemCount: 5,
                    itemSize: 14,
                    unratedColor: context.fieldBg,
                    itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: AppColors.accent),
                  ),
                  if (comment.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(comment, style: TextStyle(fontSize: 12.5, color: context.textMain)),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// منتجات حقيقية من نفس الفئة، وتختفي الفقرة لو ما فيه شيء مشابه.
  Widget _similarSection(BuildContext context, Product product) {
    final category = product.category.trim();
    if (category.isEmpty) return const SizedBox.shrink();
    return StreamBuilder<List<Product>>(
      stream: _allProductsStream,
      builder: (context, snapshot) {
        final similar = (snapshot.data ?? [])
            .where((p) => p.id != product.id && p.category.trim() == category)
            .take(8)
            .toList();
        if (similar.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const SectionHeader(title: 'منتجات مشابهة'),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: similar.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
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
          ],
        );
      },
    );
  }

  Widget _bottomBar(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        boxShadow: [BoxShadow(color: context.softShadow, blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  CartService.instance.addProduct(product, quantity: _quantity);
                  final messenger = ScaffoldMessenger.of(context);
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: const Text('تمت الإضافة للسلة'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'عرض السلة',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          ),
                        ),
                      ),
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
    bool submitting = false;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
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
                maxLength: 500,
                decoration: const InputDecoration(hintText: 'اكتب تعليقك (اختياري)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(88, 44)),
              onPressed: submitting
                  ? null
                  : () async {
                      setDialogState(() => submitting = true);
                      final messenger = ScaffoldMessenger.of(context);
                      String message;
                      try {
                        final added = await ReviewService()
                            .addReview(productId, rating: rating, comment: commentController.text.trim());
                        message = added ? 'شكراً لتقييمك' : 'سبق لك تقييم هذا المنتج';
                      } catch (_) {
                        message = 'تعذّر إرسال التقييم، حاول مرة ثانية';
                      }
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      messenger.showSnackBar(SnackBar(content: Text(message)));
                    },
              child: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}
