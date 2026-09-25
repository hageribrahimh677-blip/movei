import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Bottom Nav مشترك بين كل الشاشات الرئيسية (Home, Search, Wishlist, Profile)
/// عشان التنقل بينهم يبقى موحّد، ومش محتاجين نكرر نفس الكود في كل شاشة.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/search');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/wishlist');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primaryYellow,
      unselectedItemColor: AppColors.textGrey,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border), label: 'Wishlist'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}