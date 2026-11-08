import 'payment_type.dart';

class Product {
  final String id;
  final String sellerId;
  final String category;
  final String name;
  final String storeName; // ✅ تمت الإضافة لحل أخطاء الشاشات
  final String? walletName;
  final String? walletNumber;
  final double deliveryFee;
  final String imageUrl;
  final List<String> images;
  final String description;
  final double price;
  final double? discountPrice;
  final double rating;
  final int reviewsCount;
  final int soldCount;
  final bool isBestSeller;
  final bool isFeatured;
  final List<PaymentType> allowedPayments;
  final double depositPercent;

  const Product({
    required this.id,
    this.sellerId = '',
    this.category = '',
    required this.name,
    this.storeName = '', // ✅ تمت الإضافة للـ Constructor
    required this.imageUrl,
    this.images = const [],
    this.description = '',
    required this.price,
    this.discountPrice,
    this.rating = 0,
    this.reviewsCount = 0,
    this.soldCount = 0,
    this.isBestSeller = false,
    this.isFeatured = false,
    this.allowedPayments = const [PaymentType.cashOnDelivery],
    this.depositPercent = 0.2,
    this.walletName, // ✅ تمت الإضافة للـ Constructor لحل خطأ التهيئة
    this.walletNumber, // ✅ تمت الإضافة للـ Constructor لحل خطأ التهيئة
    this.deliveryFee = 0,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  
  double get finalPrice => hasDiscount ? discountPrice! : price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((price - discountPrice!) / price) * 100).round();
  }

  List<String> get allImages => images.isNotEmpty ? images : [imageUrl];
}