import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../addresses/addresses_screen.dart';
import '../notifications/notifications_screen.dart';
import '../orders/my_orders_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.lightGrey,
            child: Icon(Icons.person_rounded, size: 36, color: AppColors.grey),
          ),
          const SizedBox(height: 12),
          const Text('زائر', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          _menuItem(context, Icons.receipt_long_outlined, 'طلباتي', () => _open(context, const MyOrdersScreen())),
          _menuItem(context, Icons.location_on_outlined, 'عناويني', () => _open(context, const AddressesScreen())),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: AuthService.instance.currentUserId ?? '')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unread = snapshot.data?.docs.length ?? 0;
              return _menuItem(
                context,
                Icons.notifications_outlined,
                'الإشعارات',
                () => _open(context, const NotificationsScreen()),
                badge: unread,
              );
            },
          ),
          _menuItem(context, Icons.settings_outlined, 'الإعدادات', () => _open(context, const SettingsScreen())),
          _menuItem(context, Icons.help_outline_rounded, 'المساعدة والدعم', null),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback? onTap, {int badge = 0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                if (badge > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                    child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ],
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}