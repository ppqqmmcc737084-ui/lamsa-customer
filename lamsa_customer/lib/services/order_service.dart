import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import 'auth_service.dart';

class OrderService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('orders');

  Future<String> submitOrder(
    OrderModel order, {
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    String? transferReference,
    String? couponId,
  }) async {
    final customerId = AuthService.instance.currentUserId ?? '';

    final doc = await _collection.add({
      'customerId': customerId,
      'sellerId': order.product.sellerId,
      'productId': order.product.id,
      'productName': order.product.name,
      'productImage': order.product.imageUrl,
      'quantity': order.quantity,
      'paymentType': order.paymentType.name,
      'totalAmount': order.totalAmount,
      'paidAmount': order.paidAmount,
      'remainingAmount': order.remainingAmount,
      'status': order.status.name,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'transferReference': transferReference,
      'createdAt': FieldValue.serverTimestamp(),
      'deliveryFee': order.deliveryFee,
      'couponId': couponId,
    });

    return doc.id;
  }

  Future<void> cancelOrder(String orderId) {
    return _collection.doc(orderId).update({'status': 'cancelledByCustomer'});
  }
}
