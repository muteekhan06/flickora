import 'media_item.dart';

class DiaryEntry {
  final String id;
  final MediaItem media;
  final DateTime watchedDate;
  final double rating; // 1.0 to 5.0 stars
  final String reviewText;
  final bool rewatch;

  DiaryEntry({
    required this.id,
    required this.media,
    required this.watchedDate,
    required this.rating,
    this.reviewText = '',
    this.rewatch = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'media': media.toJson(),
    'watchedDate': watchedDate.toIso8601String(),
    'rating': rating,
    'reviewText': reviewText,
    'rewatch': rewatch,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    media: MediaItem.fromJson(json['media']),
    watchedDate: DateTime.tryParse(json['watchedDate'] ?? '') ?? DateTime.now(),
    rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    reviewText: json['reviewText'] ?? '',
    rewatch: json['rewatch'] ?? false,
  );
}
