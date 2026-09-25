import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forget_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/update_profile/update_profile_screen.dart';
import 'screens/browse/browse_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        ForgetPasswordScreen.routeName: (context) => const ForgetPasswordScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        SearchScreen.routeName: (context) => const SearchScreen(),
        WishlistScreen.routeName: (context) => const WishlistScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        UpdateProfileScreen.routeName: (context) => const UpdateProfileScreen(),
        BrowseScreen.routeName: (context) => const BrowseScreen(),
      },
    );
  }
}

class _TempPlaceholder extends StatelessWidget {
  final String title;
  const _TempPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          '$title\nجاية قريب 🚀',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 16),
        ),
      ),
    );
  }
}