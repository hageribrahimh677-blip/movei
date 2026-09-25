import 'package:flutter/material.dart';

class OnboardingItem {
  final String image;
  final String? title;
  final String? description;
  final String buttonLabel;
  final bool showBackButton;
  final Color overlayColor;

  const OnboardingItem({
    required this.image,
    this.title,
    this.description,
    required this.buttonLabel,
    required this.showBackButton,
    required this.overlayColor,
  });
}

final List<OnboardingItem> onboardingItems = [
  const OnboardingItem(
    image: 'assets/images/onboarding_1.png',
    title: 'Find Your Next Favorite Movie Here',
    description:
    'Get access to a huge library of movies to suit all tastes. You will surely like it.',
    buttonLabel: 'Explore Now',
    showBackButton: false,
    overlayColor: Color(0xFF1A1A1A),
  ),
  const OnboardingItem(
    image: 'assets/images/onboarding_2.png',
    title: 'Discover Movies',
    description:
    'Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.',
    buttonLabel: 'Next',
    showBackButton: false,
    overlayColor: Color(0xFF084250),
  ),
  const OnboardingItem(
    image: 'assets/images/onboarding_3.png',
    title: 'Explore All Genres',
    description:
    'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.',
    buttonLabel: 'Next',
    showBackButton: true,
    overlayColor: Color(0xFF85210E),
  ),
  const OnboardingItem(
    image: 'assets/images/onboarding_4.png',
    title: 'Create Watchlists',
    description:
    'Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various qualities and genres.',
    buttonLabel: 'Next',
    showBackButton: true,
    overlayColor: Color(0xFF4C2471),
  ),
  const OnboardingItem(
    image: 'assets/images/onboarding_5.png',
    title: 'Rate, Review, and Learn',
    description:
    "Share your thoughts on the movies you've watched. Dive deep into film details and help others discover great movies with your reviews.",
    buttonLabel: 'Next',
    showBackButton: true,
    overlayColor: Color(0xFF601321),
  ),
  const OnboardingItem(
    image: 'assets/images/onboarding_6.png',
    title: 'Start Watching Now',
    description: null,
    buttonLabel: 'Finish',
    showBackButton: true,
    overlayColor: Color(0xFF2A2C30),
  ),
];