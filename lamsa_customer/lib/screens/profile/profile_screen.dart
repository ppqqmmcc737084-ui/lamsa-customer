import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../orders/my_orders_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const CircleAvatar(radius: 36, backgroundColor: AppColors.lightGrey, child: Icon(Icons.person_rounded, size: 36, color: AppColors.grey)),
          const SizedBox(height: 12),
          const Text('زائر', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
            child: _menuItem(Icons.receipt_long_outlined, 'طلباتي'),
          ),
          _menuItem(Icons.location_on_outlined, 'عناويني'),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            child: _menuItem(Icons.notifications_outlined, 'الإشعارات'),
          ),
          _menuItem(Icons.settings_outlined, 'الإعدادات'),
          _menuItem(Icons.help_outline_rounded, 'المساعدة والدعم'),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const Spacer(),
          const Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.grey),
        ],
      ),
    );
  }
}