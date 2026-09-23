import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ReviewService {
  Future<void> addReview(String productId, {required double rating, required String comment}) async {
    final customerId = AuthService.instance.currentUserId ?? '';
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);

    await productRef.collection('reviews').add({
      'customerId': customerId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);
      final currentRating = (snapshot.data()?['rating'] ?? 0).toDouble();
      final currentCount = (snapshot.data()?['reviewsCount'] ?? 0) as int;

      final newCount = currentCount + 1;
      final newRating = ((currentRating * currentCount) + rating) / newCount;

      transaction.update(productRef, {
        'rating': newRating,
        'reviewsCount': newCount,
      });
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