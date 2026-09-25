import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../movie_details/movie_details_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  static const routeName = '/browse';

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final MovieService _movieService = MovieService();

  static const List<String> _genres = [
    'All',
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Sport',
    'Thriller',
    'War',
    'Western',
  ];

  static const Map<String, String> _sortOptions = {
    'Latest': 'date_added',
    'Rating': 'rating',
    'Year': 'year',
    'Title (A-Z)': 'title',
    'Most Downloaded': 'download_count',
  };

  String _selectedGenre = 'All';
  String _selectedSort = 'Latest';

  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _fetchMovies();
  }

  Future<List<Movie>> _fetchMovies() {
    return _movieService.getMovies(
      genre: _selectedGenre == 'All' ? null : _selectedGenre,
      sortBy: _sortOptions[_selectedSort]!,
      limit: 30,
    );
  }

  void _onGenreSelected(String genre) {
    setState(() {
      _selectedGenre = genre;
      _moviesFuture = _fetchMovies();
    });
  }

  void _onSortSelected(String? sort) {
    if (sort == null) return;
    setState(() {
      _selectedSort = sort;
      _moviesFuture = _fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Browse'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppColors.textWhite),
            color: AppColors.surface,
            onSelected: _onSortSelected,
            itemBuilder: (context) => _sortOptions.keys.map((label) {
              return PopupMenuItem<String>(
                value: label,
                child: Text(
                  label,
                  style: TextStyle(
                    color: label == _selectedSort
                        ? AppColors.primaryYellow
                        : AppColors.textWhite,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _genres.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = genre == _selectedGenre;
                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (_) => _onGenreSelected(genre),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primaryYellow,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textWhite,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide.none,
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryYellow),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('حصل خطأ، حاولي تاني',
                        style: TextStyle(color: AppColors.textGrey)),
                  );
                }

                final movies = snapshot.data ?? [];
                if (movies.isEmpty) {
                  return const Center(
                    child: Text('مفيش أفلام بالفلتر ده',
                        style: TextStyle(color: AppColors.textGrey)),
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
            ),
          ),
        ],
      ),
    );
  }
}