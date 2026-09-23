import 'package:flutter/material.dart';
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
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: CartService.instance.items,
        builder: (context, items, _) {
          final cartCount = CartService.instance.totalCount;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primary.withOpacity(0.1),
            destinations: [
              const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary), label: 'الرئيسية'),
              const NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.primary), label: 'المفضلة'),
              NavigationDestination(
                icon: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: const Icon(Icons.shopping_bag_outlined)),
                selectedIcon: Badge(label: Text('$cartCount'), isLabelVisible: cartCount > 0, child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary)),
                label: 'السلة',
              ),
              const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary), label: 'حسابي'),
            ],
          );
        },
      ),
    );
  }
}