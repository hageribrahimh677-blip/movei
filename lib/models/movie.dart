/// عضو في طاقم التمثيل (بيجي بس لما نطلب with_cast=true من الـ API)
class CastMember {
  final String name;
  final String characterName;
  final String imageUrl;

  const CastMember({
    required this.name,
    required this.characterName,
    required this.imageUrl,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] as String? ?? '',
      characterName: json['character_name'] as String? ?? '',
      imageUrl: json['url_small_image'] as String? ?? '',
    );
  }
}

/// موديل الفيلم - بيطابق شكل الداتا اللي راجعة من YTS API
/// (list_movies.json, movie_details.json)
class Movie {
  final int id;
  final String title;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String summary;
  final String backgroundImage;
  final String mediumCoverImage;
  final String largeCoverImage;
  final String mpaRating;
  final String ytTrailerCode;

  final List<String> screenshots;
  final List<CastMember> cast;

  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.genres,
    required this.summary,
    required this.backgroundImage,
    required this.mediumCoverImage,
    required this.largeCoverImage,
    required this.mpaRating,
    this.ytTrailerCode = '',
    this.screenshots = const [],
    this.cast = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final screenshots = <String>[];
    for (final key in [
      'medium_screenshot_image1',
      'medium_screenshot_image2',
      'medium_screenshot_image3',
    ]) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        screenshots.add(value.toString());
      }
    }

    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      runtime: json['runtime'] as int? ?? 0,
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      summary: (json['summary'] as String?)?.isNotEmpty == true
          ? json['summary'] as String
          : (json['description_full'] as String? ?? ''),
      backgroundImage: json['background_image'] as String? ?? '',
      mediumCoverImage: json['medium_cover_image'] as String? ?? '',
      largeCoverImage: json['large_cover_image'] as String? ?? '',
      mpaRating: json['mpa_rating'] as String? ?? '',
      ytTrailerCode: json['yt_trailer_code'] as String? ?? '',
      screenshots: screenshots,
      cast: (json['cast'] as List<dynamic>? ?? [])
          .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// ------------------- إضافة جديدة لتفعيل الـ History -------------------

  /// بيبني Movie من الـ snapshot البسيط اللي متخزن في Firestore جوه
  /// حقل `history` (id, title, year, rating, mediumCoverImage).
  factory Movie.fromHistorySnapshot(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      year: map['year'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      runtime: 0,
      genres: const [],
      summary: '',
      backgroundImage: '',
      mediumCoverImage: map['mediumCoverImage'] as String? ?? '',
      largeCoverImage: '',
      mpaRating: '',
    );
  }

  /// بيحوّل الفيلم لـ snapshot بسيط جاهز يتخزن في Firestore
  Map<String, dynamic> toHistorySnapshot() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'rating': rating,
      'mediumCoverImage': mediumCoverImage,
    };
  }
}