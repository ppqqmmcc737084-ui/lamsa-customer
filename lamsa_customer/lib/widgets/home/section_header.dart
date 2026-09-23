import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.dark)),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text('عرض الكل',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ],
    );
  }
}