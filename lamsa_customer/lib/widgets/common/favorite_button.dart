import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/favorites_service.dart';

class FavoriteButton extends StatelessWidget {
  final String productId;
  final double size;
  const FavoriteButton({super.key, required this.productId, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoritesService.instance.favoriteIds,
      builder: (context, favorites, _) {
        final isFav = favorites.contains(productId);
        return GestureDetector(
          onTap: () => FavoritesService.instance.toggle(productId),
          child: CircleAvatar(
            radius: 13,
            backgroundColor: Colors.white,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(isFav),
                size: size,
                color: isFav ? AppColors.primary : AppColors.dark,
              ),
            ),
          ),
        );
      },
    );
  }
}