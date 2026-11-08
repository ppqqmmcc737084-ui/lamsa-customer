import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/orders/order_timeline.dart';
import '../../services/order_service.dart'; // ✅ تأكد من وجود هذا الاستيراد

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerId = AuthService.instance.currentUserId ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerId', isEqualTo: customerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.grey),
                  SizedBox(height: 12),
                  Text('ما عندك أي طلبات بعد', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final orderId = docs[index].id; // ✅ جلب الـ ID هنا بشكل نظيف
              return _orderCard(context, orderId, data);
            },
          );
        },
      ),
    );
  }

  Widget _orderCard(BuildContext context, String orderId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'pendingApproval';
    
    Color statusColor = AppColors.accent;
    String statusText = 'بانتظار الموافقة';
    
    if (status == 'confirmed') {
      statusColor = AppColors.success;
      statusText = 'مؤكد';
    } else if (status == 'preparing') {
      statusColor = AppColors.primary;
      statusText = 'قيد التجهيز';
    } else if (status == 'shipped') {
      statusColor = AppColors.accent;
      statusText = 'تم الشحن';
    } else if (status == 'delivered' || status == 'completed') {
      statusColor = AppColors.success;
      statusText = 'تم التسليم';
    } else if (status == 'rejected') {
      statusColor = AppColors.primary;
      statusText = 'مرفوض';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  data['productImage'] ?? '', 
                  width: 56, 
                  height: 56, 
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.lightGrey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['productName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('الكمية: ${data['quantity'] ?? 1}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الإجمالي', style: TextStyle(fontSize: 12, color: AppColors.grey)),
              Text('${data['totalAmount'] ?? 0} ر.س', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          
          const SizedBox(height: 14),
          OrderTimeline(status: status),
          
          // ✅ زر إلغاء الطلب يظهر فقط إذا كانت الحالة "بانتظار الموافقة"
          if (status == 'pendingApproval') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancel(context, orderId), // ✅ تمرير الـ orderId مباشرة وبشكل نظيف
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('إلغاء الطلب'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary, 
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ دالة تأكيد الإلغاء
  void _confirmCancel(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد إنك تبي تلغي هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () async {
              await OrderService().cancelOrder(orderId);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('نعم، ألغِ الطلب', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}