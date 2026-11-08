import 'package:flutter/material.dart';
import '../../core/utils/page_transitions.dart';
import '../main/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // نفس أحمر الشعار وشاشة البداية الأصلية عشان ما يصير وميض عند الانتقال
  static const Color _brandRed = Color(0xFFDC2432);

  late final AnimationController _controller;
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _tagOpacity;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    Animation<double> interval(double begin, double end, Curve curve,
            {double from = 0, double to = 1}) =>
        Tween<double>(begin: from, end: to).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(begin, end, curve: curve),
        ));

    _glowScale = interval(0.0, 0.6, Curves.easeOut, from: 0.5);
    _glowOpacity = interval(0.0, 0.6, Curves.easeOut);
    _logoScale = interval(0.0, 0.55, Curves.easeOutBack, from: 0.6);
    _logoOpacity = interval(0.0, 0.35, Curves.easeIn);
    _textOpacity = interval(0.45, 0.8, Curves.easeOut);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOutCubic),
    ));
    _tagOpacity = interval(0.65, 1.0, Curves.easeOut);
    _progress = interval(0.15, 1.0, Curves.easeInOut);

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          SlideFadeRoute(page: const MainNavigation()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _brandRed,
      body: Stack(
        children: [
          // دوائر زخرفية خفيفة في الخلفية
          Positioned(
            top: -size.width * 0.35,
            right: -size.width * 0.3,
            child: _circle(size.width * 0.9, 0.07),
          ),
          Positioned(
            bottom: -size.width * 0.4,
            left: -size.width * 0.35,
            child: _circle(size.width * 1.0, 0.06),
          ),

          // المحتوى
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  children: [
                    const Spacer(flex: 5),

                    // الشعار مع هالة ضوء خلفه
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: _glowOpacity.value,
                            child: Transform.scale(
                              scale: _glowScale.value,
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.28),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Image.asset(
                                'assets/logo/logo_transparent_1024.png',
                                width: 170,
                                height: 170,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // اسم التطبيق
                    SlideTransition(
                      position: _textSlide,
                      child: Opacity(
                        opacity: _textOpacity.value,
                        child: const Text(
                          'لمسة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // الشعار النصي
                    Opacity(
                      opacity: _tagOpacity.value,
                      child: Text(
                        'كل ما تحتاجه بلمسة',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // شريط تقدم رفيع
                    Opacity(
                      opacity: _tagOpacity.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 110,
                          height: 4,
                          child: LinearProgressIndicator(
                            value: _progress.value,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double diameter, double alpha) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}