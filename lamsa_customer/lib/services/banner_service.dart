import 'package:cloud_firestore/cloud_firestore.dart';

class BannerService {
  Stream<QuerySnapshot> streamBanners() {
    return FirebaseFirestore.instance
        .collection('banners')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }
}