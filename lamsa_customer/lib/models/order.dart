import 'product.dart';
import 'payment_type.dart';

enum OrderStatus { pendingApproval, confirmed, rejected, completed }

class OrderModel {
  final String id;
  final Product product;
  final int quantity;
  final PaymentType paymentType;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final OrderStatus status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.paymentType,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.createdAt,
  });
}
