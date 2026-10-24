import '../core/constants.dart';

class Episode {
  final int id;
  final String name;
  final String overview;
  final String? stillPath;
  final double voteAverage;
  final int episodeNumber;
  final int seasonNumber;
  final int? runtime;
  final String airDate;
  final String? streamUrl;

  Episode({
    required this.id,
    required this.name,
    required this.overview,
    this.stillPath,
    required this.voteAverage,
    required this.episodeNumber,
    required this.seasonNumber,
    this.runtime,
    required this.airDate,
    this.streamUrl,
  });

  String get stillUrl {
    if (stillPath == null || stillPath!.isEmpty) {
      return 'https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85?w=600&auto=format&fit=crop&q=80';
    }
    return FlickoraConstants.getBackdropUrl(stillPath);
  }

  String get formattedDuration {
    if (runtime == null || runtime == 0) return '45m';
    final hours = runtime! ~/ 60;
    final mins = runtime! % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  factory Episode.fromJson(Map<String, dynamic> json, int seasonNum) {
    return Episode(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Episode ${json['episode_number'] ?? 1}',
      overview: json['overview'] ?? 'No overview available for this episode.',
      stillPath: json['still_path'],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 8.0,
      episodeNumber: json['episode_number'] ?? 1,
      seasonNumber: seasonNum,
      runtime: json['runtime'],
      airDate: json['air_date'] ?? '',
      streamUrl: json['stream_url'],
    );
  }
}
