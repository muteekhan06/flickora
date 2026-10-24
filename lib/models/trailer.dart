class VideoTrailer {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  VideoTrailer({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    this.official = false,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$key/hqdefault.jpg';

  factory VideoTrailer.fromJson(Map<String, dynamic> json) {
    return VideoTrailer(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? 'Trailer',
      site: json['site'] ?? 'YouTube',
      type: json['type'] ?? 'Trailer',
      official: json['official'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'site': site,
      'type': type,
      'official': official,
    };
  }
}
