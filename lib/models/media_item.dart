import '../core/constants.dart';

class MediaItem {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<int> genreIds;
  final String mediaType; // 'movie' or 'tv'
  final int? runtime;
  final String? tagline;
  final String? trailerKey;

  MediaItem({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
    this.mediaType = 'movie',
    this.runtime,
    this.tagline,
    this.trailerKey,
  });

  String get posterUrl => FlickoraConstants.getPosterUrl(posterPath);
  String get backdropUrl => FlickoraConstants.getBackdropUrl(backdropPath);

  String get formattedRating => voteAverage.toStringAsFixed(1);

  String get releaseYear {
    if (releaseDate.isEmpty) return 'N/A';
    try {
      return releaseDate.split('-').first;
    } catch (_) {
      return 'N/A';
    }
  }

  List<String> get genreNames {
    return genreIds.map((id) => FlickoraConstants.genres[id] ?? 'Cinema').toList();
  }

  String get formattedRuntime {
    if (runtime == null || runtime == 0) return '2h 15m';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  factory MediaItem.fromJson(Map<String, dynamic> json, {String defaultMediaType = 'movie'}) {
    final title = json['title'] ?? json['name'] ?? 'Untitled';
    final releaseDate = json['release_date'] ?? json['first_air_date'] ?? '';
    final mediaType = json['media_type'] ?? defaultMediaType;

    List<int> genreIdsList = [];
    if (json['genre_ids'] != null) {
      genreIdsList = List<int>.from(json['genre_ids']);
    } else if (json['genres'] != null) {
      genreIdsList = (json['genres'] as List).map((g) => (g['id'] as int)).toList();
    }

    return MediaItem(
      id: json['id'] ?? 0,
      title: title,
      overview: json['overview'] ?? 'No synopsis available for this title.',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 7.5,
      voteCount: json['vote_count'] ?? 100,
      releaseDate: releaseDate,
      genreIds: genreIdsList,
      mediaType: mediaType,
      runtime: json['runtime'],
      tagline: json['tagline'],
      trailerKey: json['trailer_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'media_type': mediaType,
      'runtime': runtime,
      'tagline': tagline,
      'trailer_key': trailerKey,
    };
  }

  MediaItem copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    List<int>? genreIds,
    String? mediaType,
    int? runtime,
    String? tagline,
    String? trailerKey,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      genreIds: genreIds ?? this.genreIds,
      mediaType: mediaType ?? this.mediaType,
      runtime: runtime ?? this.runtime,
      tagline: tagline ?? this.tagline,
      trailerKey: trailerKey ?? this.trailerKey,
    );
  }
}
