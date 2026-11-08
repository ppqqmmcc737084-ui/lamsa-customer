import 'package:flutter/material.dart';
import 'package:lamsa_customer/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../services/cart_service.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: CartService.instance.items,
        builder: (context, items, _) {
          final cartCount = CartService.instance.totalCount;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: Theme.of(context).cardColor,
            indicatorColor: AppColors.primary.withOpacity(0.1),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primary),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon: const Icon(Icons.favorite_rounded, color: AppColors.primary),
                label: l10n.navFavorites,
              ),
              NavigationDestination(
                icon: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: const Icon(Icons.shopping_bag_outlined)),
                selectedIcon: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary)),
                label: l10n.navCart,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
                label: l10n.navProfile,
              ),
            ],
          );
        },
      ),
    );
  }
}