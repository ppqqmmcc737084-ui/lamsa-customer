import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class AddressService {
  final _collection = FirebaseFirestore.instance.collection('addresses');

  Stream<QuerySnapshot> streamMyAddresses() {
    final customerId = AuthService.instance.currentUserId ?? '';
    return _collection.where('customerId', isEqualTo: customerId).snapshots();
  }

  Future<void> addAddress({
    required String label,
    required String governorate,
    required String city,
    required String landmark,
    required String phone,
  }) async {
    final customerId = AuthService.instance.currentUserId ?? '';
    final fullAddress = '$governorate - $city - قرب $landmark';
    await _collection.add({
      'customerId': customerId,
      'label': label,
      'governorate': governorate,
      'city': city,
      'landmark': landmark,
      'fullAddress': fullAddress,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAddress(String id) => _collection.doc(id).delete();
}