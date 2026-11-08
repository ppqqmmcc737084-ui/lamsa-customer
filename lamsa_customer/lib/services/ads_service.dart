import 'package:cloud_firestore/cloud_firestore.dart';

class AdsService {
  Stream<List<Map<String, dynamic>>> streamActiveAds() {
    return FirebaseFirestore.instance
        .collection('ads')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      return snap.docs
          .map((d) => d.data())
          .where((data) {
            final endDate = (data['endDate'] as Timestamp?)?.toDate();
            return endDate != null && endDate.isAfter(now);
          })
          .toList();
    });
  }
}