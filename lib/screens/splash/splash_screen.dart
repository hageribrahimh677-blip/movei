import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // TODO: لما نظبط نظام تسجيل الدخول، هنحط هنا المنطق ده:
    // - أول مرة يفتح التطبيق؟         -> /onboarding
    // - فيه مستخدم مسجل دخول بالفعل؟   -> /home
    // - غير كده؟                      -> /login
    //
    // دلوقتي بنكمل بشاشات الأفلام الأول، فبنروح على طول للـ Onboarding
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // أيقونة الـ Play في النص
            Center(
              child: Image.asset(
                'assets/images/ic_play_circle.png',
                width: 90,
                height: 90,
              ),
            ),

            const Spacer(flex: 4),

            // لوجو Route
            Image.asset(
              'assets/images/logo.png',
              width: 130,
            ),

            const SizedBox(height: 10),

            const Text(
              'Supervised by Mohamed Nabil',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}