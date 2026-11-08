import 'product.dart';
import 'payment_type.dart';

enum OrderStatus { pendingApproval, confirmed, preparing, shipped, delivered, rejected, cancelledByCustomer }

class OrderModel {
  final String id;
  final Product product;
  final int quantity;
  final PaymentType paymentType;
  final String? transferReference;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final double deliveryFee;

  OrderModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.paymentType,
    this.transferReference, // ✅ تمت الإضافة للـ Constructor لحل خطأ التهيئة
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.createdAt,
    this.deliveryFee = 0,
  });
}