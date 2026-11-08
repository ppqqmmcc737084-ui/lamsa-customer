import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class OrderTimeline extends StatelessWidget {
  final String status;
  const OrderTimeline({super.key, required this.status});

  static const _steps = [
    {'key': 'pendingApproval', 'label': 'بانتظار الموافقة', 'icon': Icons.hourglass_top_rounded},
    {'key': 'confirmed', 'label': 'تم التأكيد', 'icon': Icons.check_circle_outline_rounded},
    {'key': 'preparing', 'label': 'قيد التجهيز', 'icon': Icons.inventory_2_outlined},
    {'key': 'shipped', 'label': 'تم الشحن', 'icon': Icons.local_shipping_outlined},
    {'key': 'delivered', 'label': 'تم التسليم', 'icon': Icons.home_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    if (status == 'rejected' || status == 'cancelledByCustomer') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(AppRadius.medium)),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.primary),
            SizedBox(width: 10),
            Text(status == 'rejected' ? 'تم رفض الطلب' : 'تم إلغاء الطلب', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
      );
    }

    final currentIndex = _steps.indexWhere((s) => s['key'] == status);
    final activeIndex = currentIndex < 0 ? 0 : currentIndex;

    return Column(
      children: List.generate(_steps.length, (index) {
        final isDone = index <= activeIndex;
        final isLast = index == _steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.primary : AppColors.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_steps[index]['icon'] as IconData, size: 15, color: isDone ? Colors.white : AppColors.grey),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: index < activeIndex ? AppColors.primary : AppColors.lightGrey),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 4),
                  child: Text(
                    _steps[index]['label'] as String,
                    style: TextStyle(
                      fontWeight: isDone ? FontWeight.w800 : FontWeight.w500,
                      color: isDone ? AppColors.dark : AppColors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}