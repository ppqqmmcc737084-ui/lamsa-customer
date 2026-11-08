import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/address_service.dart';

class AddressesScreen extends StatelessWidget {
  final bool selectMode;
  const AddressesScreen({super.key, this.selectMode = false});

  static const _governorates = [
    'أمانة العاصمة', 'صنعاء', 'عدن', 'تعز', 'الحديدة', 'إب', 'ذمار',
    'حضرموت', 'صعدة', 'حجة', 'عمران', 'البيضاء', 'لحج', 'أبين',
    'الضالع', 'شبوة', 'المهرة', 'مأرب', 'الجوف', 'ريمة', 'المحويت', 'سقطرى',
  ];

  void _showAddDialog(BuildContext context) {
    final labelController = TextEditingController();
    final cityController = TextEditingController();
    final landmarkController = TextEditingController();
    final phoneController = TextEditingController();
    String governorate = _governorates.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('عنوان جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: labelController, decoration: const InputDecoration(hintText: 'اسم العنوان (مثل: المنزل، العمل)')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: governorate,
                  decoration: const InputDecoration(hintText: 'المحافظة'),
                  items: _governorates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (value) => setDialogState(() => governorate = value!),
                ),
                const SizedBox(height: 10),
                TextField(controller: cityController, decoration: const InputDecoration(hintText: 'المدينة / الحي')),
                const SizedBox(height: 10),
                TextField(controller: landmarkController, decoration: const InputDecoration(hintText: 'أقرب معلم (مسجد، مدرسة، محل معروف...)')),
                const SizedBox(height: 10),
                TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'رقم التواصل')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (labelController.text.trim().isEmpty ||
                    cityController.text.trim().isEmpty ||
                    landmarkController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  return;
                }
                await AddressService().addAddress(
                  label: labelController.text.trim(),
                  governorate: governorate,
                  city: cityController.text.trim(),
                  landmark: landmarkController.text.trim(),
                  phone: phoneController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(selectMode ? 'اختر عنوان التوصيل' : 'عناويني')),
      body: StreamBuilder<QuerySnapshot>(
        stream: AddressService().streamMyAddresses(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off_outlined, size: 56, color: AppColors.grey),
                  SizedBox(height: 12),
                  Text('ما سويت أي عنوان بعد', style: TextStyle(color: AppColors.grey)),
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
              return GestureDetector(
                onTap: selectMode
                    ? () => Navigator.pop(context, {'fullAddress': data['fullAddress'], 'phone': data['phone']})
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.medium)),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('${data['governorate'] ?? ''} - ${data['city'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                            Text('قرب ${data['landmark'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                            Text(data['phone'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                          ],
                        ),
                      ),
                      if (!selectMode)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.grey),
                          onPressed: () => AddressService().deleteAddress(docs[index].id),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('عنوان جديد'),
      ),
    );
  }
}