import 'package:flutter/foundation.dart';

class FavoritesService {
  FavoritesService._internal();
  static final FavoritesService instance = FavoritesService._internal();

  final ValueNotifier<Set<String>> favoriteIds = ValueNotifier({});

  void toggle(String productId) {
    final set = Set<String>.from(favoriteIds.value);
    if (set.contains(productId)) {
      set.remove(productId);
    } else {
      set.add(productId);
    }
    favoriteIds.value = set;
  }
}