import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/movie.dart';
import '../../services/auth_service.dart';
import '../../services/history_service.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/movie_poster_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final HistoryService _historyService = HistoryService();

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('تسجيل الخروج',
            style: TextStyle(color: AppColors.textWhite)),
        content: const Text('متأكدة إنك عايزة تسجلي خروج؟',
            style: TextStyle(color: AppColors.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('لأ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('أيوة، خروج',
                style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService().logout();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: user == null
            ? const Center(
          child: Text('لازم تسجلي دخول الأول',
              style: TextStyle(color: AppColors.textGrey)),
        )
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data();
            final name = data?['name'] as String? ?? 'مستخدم';
            final email = data?['email'] as String? ?? user.email ?? '';
            final avatar = data?['avatar'] as String?;
            final wishlistCount =
                (data?['wishlist'] as List<dynamic>?)?.length ?? 0;

            final historyMovies =
            (data?['history'] as List<dynamic>? ?? [])
                .cast<Map<String, dynamic>>()
                .map(Movie.fromHistorySnapshot)
                .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.surface,
                        backgroundImage: avatar != null
                            ? AssetImage('assets/avatars/$avatar')
                            : null,
                        child: avatar == null
                            ? const Icon(Icons.person,
                            size: 40, color: AppColors.textGrey)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatChip(
                            count: wishlistCount,
                            label: 'Wish List',
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            count: historyMovies.length,
                            label: 'History',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed('/update-profile');
                              },
                              child: const Text('Edit Profile'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _handleLogout(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryRed,
                                side: const BorderSide(
                                    color: AppColors.primaryRed),
                              ),
                              child: const Text('Logout'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryYellow,
                  labelColor: AppColors.textWhite,
                  unselectedLabelColor: AppColors.textGrey,
                  tabs: const [
                    Tab(icon: Icon(Icons.bookmark_border), text: 'Watch List'),
                    Tab(icon: Icon(Icons.history), text: 'History'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const Center(
                        child: Text(
                          'حطي هنا محتوى wishlist_screen.dart',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                      _HistoryGrid(
                        movies: historyMovies,
                        onRemove: (id) =>
                            _historyService.removeFromHistory(id),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;

  const _StatChip({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primaryYellow,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
        ],
      ),
    );
  }
}

class _HistoryGrid extends StatelessWidget {
  final List<Movie> movies;
  final void Function(int movieId) onRemove;

  const _HistoryGrid({required this.movies, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text('لسه معملتيش أي مشاهدة',
            style: TextStyle(color: AppColors.textGrey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 10,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MoviePosterCard(
          movie: movie,
          onTap: () {
            Navigator.of(context).pushNamed(
              '/movie-details',
              arguments: movie.id,
            );
          },
          onLongPress: () => onRemove(movie.id),
        );
      },
    );
  }
}