import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../movie_details/movie_details_screen.dart';
import '../../widgets/app_bottom_nav.dart';
import '../browse/browse_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieService _movieService = MovieService();

  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _movieService.getMovies(limit: 20, sortBy: 'download_count');
  }

  Future<void> _refresh() async {
    setState(() {
      _moviesFuture =
          _movieService.getMovies(limit: 20, sortBy: 'download_count');
    });
    await _moviesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Movie>>(
          future: _moviesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryYellow,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off,
                          color: AppColors.textGrey, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'مقدرناش نجيب الأفلام، تأكدي من الإنترنت',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('حاولي تاني'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final movies = snapshot.data ?? [];
            if (movies.isEmpty) {
              return const Center(
                child: Text('مفيش أفلام دلوقتي',
                    style: TextStyle(color: AppColors.textGrey)),
              );
            }

            final featuredMovie = movies.first;
            final restOfMovies = movies.skip(1).toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryYellow,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _FeaturedBanner(movie: featuredMovie),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Popular',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _MoviesRow(movies: restOfMovies),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

/// البانر الكبير فوق - بوستر الفيلم + التدرج + زرار Watch Now + زرار Browse
class _FeaturedBanner extends StatelessWidget {
  final Movie movie;
  const _FeaturedBanner({required this.movie});

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
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(color: AppColors.surface);
            },
            errorBuilder: (context, error, stackTrace) =>
                Container(color: AppColors.surface),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.background],
                stops: [0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Image.asset(
              'assets/images/banner_available_now.png',
              height: 28,
              errorBuilder: (context, error, stackTrace) => const Text(
                'Available Now',
                style: TextStyle(
                    color: AppColors.textWhite,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: SafeArea(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BrowseScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.grid_view_rounded,
                      color: AppColors.textWhite, size: 20),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/banner_watch_now.png',
                  height: 32,
                  errorBuilder: (context, error, stackTrace) => Text(
                    movie.title,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MovieDetailsScreen(movie: movie),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Watch'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// صف أفقي من بوسترات الأفلام
class _MoviesRow extends StatelessWidget {
  final List<Movie> movies;
  const _MoviesRow({required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _MovieCard(movie: movies[index]),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(movie: movie),
          ),
        );
      },
      child: SizedBox(
        width: 130,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                movie.mediumCoverImage,
                width: 130,
                height: 190,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 130,
                    height: 190,
                    color: AppColors.surface,
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 130,
                  height: 190,
                  color: AppColors.surface,
                  child: const Icon(Icons.movie_outlined,
                      color: AppColors.textGrey),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star,
                        color: AppColors.primaryYellow, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}