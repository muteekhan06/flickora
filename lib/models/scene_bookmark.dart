class SceneBookmark {
  final String id;
  final int mediaId;
  final String mediaTitle;
  final String? posterPath;
  final int seconds;
  final String note;
  final DateTime createdAt;

  SceneBookmark({
    required this.id,
    required this.mediaId,
    required this.mediaTitle,
    this.posterPath,
    required this.seconds,
    required this.note,
    required this.createdAt,
  });

  String get formattedTimecode {
    final d = Duration(seconds: seconds);
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final secs = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mediaId': mediaId,
    'mediaTitle': mediaTitle,
    'posterPath': posterPath,
    'seconds': seconds,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SceneBookmark.fromJson(Map<String, dynamic> json) => SceneBookmark(
    id: json['id'],
    mediaId: json['mediaId'] ?? 0,
    mediaTitle: json['mediaTitle'] ?? 'Unknown Film',
    posterPath: json['posterPath'],
    seconds: json['seconds'] ?? 0,
    note: json['note'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}
