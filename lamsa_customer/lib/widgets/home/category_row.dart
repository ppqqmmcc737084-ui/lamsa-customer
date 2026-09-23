import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/store_category.dart';

class CategoryRow extends StatelessWidget {
  final List<StoreCategory> categories;
  final String? selectedName;
  final ValueChanged<String> onSelect;

  const CategoryRow({
    super.key,
    required this.categories,
    required this.selectedName,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedName == cat.name;
          return GestureDetector(
            onTap: () => onSelect(cat.name),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Icon(cat.icon, color: isSelected ? Colors.white : AppColors.primary, size: 28),
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.primary : AppColors.dark,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                  ),
                  child: Text(cat.name),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}