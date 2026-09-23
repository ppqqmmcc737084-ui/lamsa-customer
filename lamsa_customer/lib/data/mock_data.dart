import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/store_category.dart';
import '../models/promo_banner.dart';
import '../models/payment_type.dart';

final mockBanners = [
  const PromoBanner(
    title: 'خصم يصل إلى 50%',
    subtitle: 'على مجموعة مختارة من المنتجات',
    buttonText: 'تسوقي الآن',
    gradientColors: [Color(0xFFE63946), Color(0xFFF4A261)],
  ),
  const PromoBanner(
    title: 'وصل حديثاً',
    subtitle: 'أحدث المنتجات بانتظارك',
    buttonText: 'اكتشف الجديد',
    gradientColors: [Color(0xFF1D1D1F), Color(0xFF3A3A3C)],
  ),
  const PromoBanner(
    title: 'شحن مجاني',
    subtitle: 'لجميع الطلبات فوق 200 ريال',
    buttonText: 'ابدأ التسوق',
    gradientColors: [Color(0xFF2A9D8F), Color(0xFF264653)],
  ),
];

final mockCategories = [
  const StoreCategory(id: '1', name: 'إلكترونيات', icon: Icons.devices_other_rounded),
  const StoreCategory(id: '2', name: 'أزياء', icon: Icons.checkroom_rounded),
  const StoreCategory(id: '3', name: 'منزل', icon: Icons.chair_rounded),
  const StoreCategory(id: '4', name: 'جمال', icon: Icons.face_retouching_natural_rounded),
  const StoreCategory(id: '5', name: 'رياضة', icon: Icons.sports_soccer_rounded),
  const StoreCategory(id: '6', name: 'إكسسوارات', icon: Icons.watch_rounded),
];

final mockProducts = List.generate(8, (i) {
  final prices = [149.0, 89.0, 320.0, 55.0, 210.0, 99.0, 175.0, 60.0];
  final discounts = <double?>[99.0, null, 250.0, null, 159.0, null, 129.0, 45.0];
  final names = [
    'سماعة لاسلكية عصرية',
    'حقيبة يد جلدية',
    'ساعة ذكية رياضية',
    'نظارة شمسية أنيقة',
    'حذاء رياضي مريح',
    'عطر فاخر',
    'كاميرا فورية',
    'محفظة جلدية',
  ];
  final descriptions = [
    'سماعة لاسلكية بجودة صوت عالية وعزل ضوضاء ممتاز، بطارية تدوم طوال اليوم، ومريحة للاستخدام الطويل.',
    'حقيبة يد جلدية أصلية بتصميم عصري أنيق، متعددة الجيوب، تناسب الاستخدام اليومي والمناسبات.',
    'ساعة ذكية بمزايا رياضية متكاملة: قياس النبض، تتبع الخطوات، ومقاومة للماء.',
    'نظارة شمسية بتصميم عصري تحمي من الأشعة فوق البنفسجية مع إطار خفيف الوزن.',
    'حذاء رياضي مريح مصمم للجري والاستخدام اليومي، بمواد قابلة للتهوية.',
    'عطر فاخر بتركيبة تدوم طويلاً، رائحة مميزة تناسب جميع المناسبات.',
    'كاميرا فورية تطبع صورك مباشرة، مثالية للحفلات والذكريات.',
    'محفظة جلدية أنيقة بجيوب متعددة للبطاقات والنقود.',
  ];
  final paymentsList = [
    [PaymentType.cashOnDelivery, PaymentType.fullOnline],
    [PaymentType.cashOnDelivery],
    [PaymentType.cashOnDelivery, PaymentType.deposit, PaymentType.fullOnline],
    [PaymentType.fullOnline],
    [PaymentType.cashOnDelivery, PaymentType.deposit],
    [PaymentType.cashOnDelivery, PaymentType.fullOnline],
    [PaymentType.deposit, PaymentType.fullOnline],
    [PaymentType.cashOnDelivery],
  ];
  return Product(
    id: 'p$i',
    name: names[i],
    imageUrl: 'https://picsum.photos/seed/lamsa$i/400/400',
    images: [
      'https://picsum.photos/seed/lamsa$i/600/600',
      'https://picsum.photos/seed/lamsa${i}b/600/600',
      'https://picsum.photos/seed/lamsa${i}c/600/600',
    ],
    description: descriptions[i],
    price: prices[i],
    discountPrice: discounts[i],
    rating: 3.5 + (i % 3) * 0.5,
    reviewsCount: 20 + i * 7,
    soldCount: 50 + i * 23,
    isBestSeller: i % 3 == 0,
    allowedPayments: paymentsList[i],
    depositPercent: 0.25,
  );
});