import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ReviewService {
  /// يضيف تقييم العميل ويحدّث متوسط المنتج في عملية واحدة.
  /// مراجعة واحدة لكل عميل لكل منتج (معرّف المراجعة = معرّف العميل).
  /// يرجع false لو العميل قيّم المنتج من قبل.
  Future<bool> addReview(String productId, {required double rating, required String comment}) async {
    final customerId = AuthService.instance.currentUserId;
    if (customerId == null || customerId.isEmpty) return false;

    final value = rating.clamp(1.0, 5.0).toDouble();
    final db = FirebaseFirestore.instance;
    final productRef = db.collection('products').doc(productId);
    final reviewRef = productRef.collection('reviews').doc(customerId);

    return db.runTransaction<bool>((transaction) async {
      final reviewSnap = await transaction.get(reviewRef);
      if (reviewSnap.exists) return false;

      final productSnap = await transaction.get(productRef);
      final data = productSnap.data() ?? <String, dynamic>{};
      final currentRating = ((data['rating'] ?? 0) as num).toDouble();
      final currentCount = ((data['reviewsCount'] ?? 0) as num).toInt();

      final newCount = currentCount + 1;
      final newRating = ((currentRating * currentCount) + value) / newCount;

      transaction.set(reviewRef, {
        'customerId': customerId,
        'rating': value,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(productRef, {
        'rating': newRating,
        'reviewsCount': newCount,
      });
      return true;
    });
  }

  Stream<QuerySnapshot> streamReviews(String productId) {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
