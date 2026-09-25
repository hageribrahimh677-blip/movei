import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

/// كل الاتصال بـ API الأفلام (YTS) بيمر من هنا بس
/// عشان لو الـ API اتغيّر يوم، نعدل في مكان واحد بس.
class MovieService {
  static const String _baseUrl = 'https://movies-api.accel.li/api/v2';

  /// بيرجع قايمة أفلام - تستخدم في الـ Home والـ Search
  Future<List<Movie>> getMovies({
    String? query,
    String? genre,
    String sortBy = 'date_added',
    int limit = 20,
    int page = 1,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
      'sort_by': sortBy,
      'order_by': 'desc',
    };
    if (query != null && query.isNotEmpty) params['query_term'] = query;
    if (genre != null && genre.isNotEmpty) params['genre'] = genre;

    final uri = Uri.parse('$_baseUrl/list_movies.json')
        .replace(queryParameters: params);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('فشل تحميل الأفلام (كود ${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (body['status'] != 'ok') {
      throw Exception(body['status_message'] ?? 'حصل خطأ في الـ API');
    }

    final data = body['data'] as Map<String, dynamic>;
    final moviesJson = data['movies'] as List<dynamic>? ?? [];

    return moviesJson
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// بيرجع تفاصيل فيلم واحد بالكامل (للـ Movie Details screen)
  Future<Movie> getMovieDetails(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie_details.json').replace(
      queryParameters: {
        'movie_id': movieId.toString(),
        'with_images': 'true',
        'with_cast': 'true',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('فشل تحميل تفاصيل الفيلم');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final movieJson = data['movie'] as Map<String, dynamic>;

    return Movie.fromJson(movieJson);
  }

  /// بيرجع 4 أفلام مشابهة (لقسم "Similar" في Movie Details)
  Future<List<Movie>> getSuggestions(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie_suggestions.json').replace(
      queryParameters: {'movie_id': movieId.toString()},
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('فشل تحميل الاقتراحات');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final moviesJson = data['movies'] as List<dynamic>? ?? [];

    return moviesJson
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}