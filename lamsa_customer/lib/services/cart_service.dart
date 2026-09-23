import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  CartService._internal();
  static final CartService instance = CartService._internal();

  final ValueNotifier<List<CartItem>> items = ValueNotifier([]);

  void addProduct(Product product, {int quantity = 1}) {
    final list = List<CartItem>.from(items.value);
    final index = list.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      list[index].quantity += quantity;
    } else {
      list.add(CartItem(product: product, quantity: quantity));
    }
    items.value = list;
  }

  void updateQuantity(String productId, int quantity) {
    final list = List<CartItem>.from(items.value);
    final index = list.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        list.removeAt(index);
      } else {
        list[index].quantity = quantity;
      }
    }
    items.value = list;
  }

  void clear() => items.value = [];

  int get totalCount => items.value.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => items.value.fold(0, (sum, item) => sum + item.totalPrice);
}