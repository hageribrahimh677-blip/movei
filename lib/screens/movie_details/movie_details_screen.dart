import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../../services/history_service.dart';
import '../../utils/trailer_launcher.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final MovieService _movieService = MovieService();
  final HistoryService _historyService = HistoryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<Movie>> _similarMoviesFuture;
  late Future<Movie> _fullDetailsFuture;

  bool _isInWishlist = false;
  bool _wishlistLoading = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _historyService.addToHistory(widget.movie);
    _similarMoviesFuture = _movieService.getSuggestions(widget.movie.id);
    _fullDetailsFuture = _movieService.getMovieDetails(widget.movie.id);
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final user = _currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final wishlist = (doc.data()?['wishlist'] as List<dynamic>?) ?? [];

    if (mounted) {
      setState(() => _isInWishlist = wishlist.contains(widget.movie.id));
    }
  }

  Future<void> _toggleWishlist() async {
    final user = _currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لازم تسجلي دخول الأول')),
      );
      return;
    }

    setState(() => _wishlistLoading = true);

    final userDoc = _firestore.collection('users').doc(user.uid);
    try {
      if (_isInWishlist) {
        await userDoc.update({
          'wishlist': FieldValue.arrayRemove([widget.movie.id]),
        });
      } else {
        await userDoc.update({
          'wishlist': FieldValue.arrayUnion([widget.movie.id]),
        });
      }
      if (mounted) setState(() => _isInWishlist = !_isInWishlist);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حصل خطأ، حاولي تاني')),
        );
      }
    } finally {
      if (mounted) setState(() => _wishlistLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroSection(
              movie: movie,
              isInWishlist: _isInWishlist,
              wishlistLoading: _wishlistLoading,
              onWishlistTap: _toggleWishlist,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${movie.year}',
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                      if (movie.runtime > 0) ...[
                        const Text(' • ',
                            style: TextStyle(color: AppColors.textGrey)),
                        Text(
                          '${movie.runtime} min',
                          style: const TextStyle(color: AppColors.textGrey),
                        ),
                      ],
                      const Spacer(),
                      const Icon(Icons.star,
                          color: AppColors.primaryYellow, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        launchTrailer(context, movie.ytTrailerCode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Watch'),
                  ),
                ],
              ),
            ),
          ),

          _SectionTitle('Screen Shots'),
          SliverToBoxAdapter(
            child: FutureBuilder<Movie>(
              future: _fullDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryYellow,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                final screenshots = snapshot.data?.screenshots ?? [];
                if (screenshots.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: screenshots.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          screenshots[index],
                          width: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(width: 160, color: AppColors.surface),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          _SectionTitle('Similar'),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Movie>>(
              future: _similarMoviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 190,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryYellow,
                      ),
                    ),
                  );
                }
                final similar = snapshot.data ?? [];
                if (similar.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: similar.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final m = similar[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => MovieDetailsScreen(movie: m),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            m.mediumCoverImage,
                            width: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(width: 110, color: AppColors.surface),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (movie.summary.isNotEmpty) ...[
                    const Text(
                      'Summary',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      movie.summary,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          _SectionTitle('Cast'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: FutureBuilder<Movie>(
                future: _fullDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryYellow,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  final cast = snapshot.data?.cast ?? [];
                  if (cast.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: cast.map((member) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.surface,
                              backgroundImage: member.imageUrl.isNotEmpty
                                  ? NetworkImage(member.imageUrl)
                                  : null,
                              child: member.imageUrl.isEmpty
                                  ? const Icon(Icons.person,
                                  color: AppColors.textGrey)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name: ${member.name}',
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Character: ${member.characterName}',
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),

          if (movie.genres.isNotEmpty)
            SliverPadding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Genres',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.genres.map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            genre,
                            style:
                            const TextStyle(color: AppColors.textWhite),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Movie movie;
  final bool isInWishlist;
  final bool wishlistLoading;
  final VoidCallback onWishlistTap;

  const _HeroSection({
    required this.movie,
    required this.isInWishlist,
    required this.wishlistLoading,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            movie.largeCoverImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: AppColors.surface),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.background],
                stops: [0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: _CircleIconButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: _CircleIconButton(
                icon: isInWishlist ? Icons.bookmark : Icons.bookmark_border,
                iconColor: isInWishlist ? AppColors.primaryYellow : null,
                onTap: wishlistLoading ? null : onWishlistTap,
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/ic_play_circle.png',
              width: 64,
              height: 64,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.play_circle_fill,
                color: AppColors.primaryYellow,
                size: 64,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.icon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? AppColors.textWhite, size: 20),
      ),
    );
  }
}