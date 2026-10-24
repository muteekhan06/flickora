class ReleaseReminder {
  final int mediaId;
  final String title;
  final String releaseDate;
  final String posterPath;
  final DateTime addedAt;

  ReleaseReminder({
    required this.mediaId,
    required this.title,
    required this.releaseDate,
    required this.posterPath,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'mediaId': mediaId,
    'title': title,
    'releaseDate': releaseDate,
    'posterPath': posterPath,
    'addedAt': addedAt.toIso8601String(),
  };

  factory ReleaseReminder.fromJson(Map<String, dynamic> json) => ReleaseReminder(
    mediaId: json['mediaId'] ?? 0,
    title: json['title'] ?? '',
    releaseDate: json['releaseDate'] ?? '',
    posterPath: json['posterPath'] ?? '',
    addedAt: DateTime.tryParse(json['addedAt'] ?? '') ?? DateTime.now(),
  );
}
