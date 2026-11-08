import 'package:cloud_firestore/cloud_firestore.dart';

class CouponResult {
  final int discountPercent;
  final String couponId;
  CouponResult({required this.discountPercent, required this.couponId});
}

class CouponService {
  Future<CouponResult?> validate(String code, String sellerId, String productId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('coupons')
        .where('sellerId', isEqualTo: sellerId)
        .where('code', isEqualTo: code.toUpperCase().trim())
        .where('active', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    final restrictedProductId = data['productId'];
    if (restrictedProductId != null && restrictedProductId != productId) return null;

    return CouponResult(discountPercent: data['discountPercent'] ?? 0, couponId: snapshot.docs.first.id);
  }
}