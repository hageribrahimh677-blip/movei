import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    final bool isLast = _currentPage == onboardingItems.length - 1;
    if (!isLast) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    // TODO: لما نظبط نظام الدخول، هنحدد هنا Login ولا Home
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        itemCount: onboardingItems.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          final item = onboardingItems[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              // خلفية الصورة
              Image.asset(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: AppColors.surface);
                },
              ),

              // تغميق تدريجي فوق الصورة - بلون مطابق لكل خلفية
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      item.overlayColor.withOpacity(0),
                      item.overlayColor,
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),

              // الـ Bottom Sheet (العنوان + الوصف + الأزرار) - لون ثابت موحّد لكل الشاشات
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title ?? '',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // الوصف بيظهر بس لو موجود (آخر شاشة مفيهاش وصف)
                      if (item.description != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          item.description!,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _goNext,
                        child: Text(item.buttonLabel),
                      ),

                      // زرار الـ Back بيظهر بس لو الشاشة محتاجاه
                      if (item.showBackButton) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _goBack,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}