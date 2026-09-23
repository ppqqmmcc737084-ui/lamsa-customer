import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/payment_type.dart';

class ProductService {
  final _collection = FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> streamProducts() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map(_fromDoc).toList();
    });
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  Product _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Product(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      category: data['category'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: (data['images'] as List?)?.cast<String>() ?? const [],
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discountPrice: data['discountPrice'] != null
          ? (data['discountPrice']).toDouble()
          : null,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      soldCount: data['soldCount'] ?? 0,
      isBestSeller: data['isBestSeller'] ?? false,
      allowedPayments: _parsePayments(data['allowedPayments']),
      depositPercent: (data['depositPercent'] ?? 0.2).toDouble(),
    );
  }

  List<PaymentType> _parsePayments(List? raw) {
    if (raw == null) return const [PaymentType.cashOnDelivery];
    final parsed = raw
        .map((e) => PaymentType.values.asNameMap()[e])
        .whereType<PaymentType>()
        .toList();
    return parsed.isEmpty ? const [PaymentType.cashOnDelivery] : parsed;
  }
}