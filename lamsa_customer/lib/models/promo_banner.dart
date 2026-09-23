import 'package:flutter/material.dart';

class PromoBanner {
  final String title;
  final String subtitle;
  final String buttonText;
  final List<Color> gradientColors;

  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradientColors,
  });
}