import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../../widgets/app_bottom_nav.dart';
import '../movie_details/movie_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  static const routeName = '/wishlist';

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final MovieService _movieService = MovieService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? get _userDocStream {
    final user = _currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  Future<List<Movie>> _fetchMoviesByIds(List<int> ids) async {
    final futures = ids.map((id) => _movieService.getMovieDetails(id));
    final results = await Future.wait(futures, eagerError: false);
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Wishlist'),
      ),
      body: _userDocStream == null
          ? const _EmptyState(message: 'لازم تسجلي دخول الأول')
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userDocStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryYellow,
              ),
            );
          }

          final wishlistRaw =
              (snapshot.data?.data()?['wishlist'] as List<dynamic>?) ??
                  [];
          final wishlistIds =
          wishlistRaw.map((e) => e as int).toList();

          if (wishlistIds.isEmpty) {
            return const _EmptyState(
              message: 'مفيش أفلام في المفضلة لسه\nضيفي أفلام تحبيها',
            );
          }

          return FutureBuilder<List<Movie>>(
            future: _fetchMoviesByIds(wishlistIds),
            builder: (context, moviesSnapshot) {
              if (moviesSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryYellow,
                  ),
                );
              }

              final movies = moviesSnapshot.data ?? [];
              if (movies.isEmpty) {
                return const _EmptyState(
                  message: 'مفيش أفلام في المفضلة لسه',
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.62,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MovieDetailsScreen(movie: movie),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        movie.mediumCoverImage,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.movie_outlined,
                              color: AppColors.textGrey),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/illustration_empty_state.png',
            width: 100,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.bookmark_border,
              color: AppColors.textGrey,
              size: 60,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}