import 'media_item.dart';

class CinemaStack {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String curator;
  final bool isEditorial;
  final List<MediaItem> items;
  final DateTime createdAt;

  CinemaStack({
    required this.id,
    required this.title,
    required this.description,
    this.emoji = '🎬',
    this.curator = 'Flickora Editorial',
    this.isEditorial = false,
    required this.items,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'curator': curator,
    'isEditorial': isEditorial,
    'items': items.map((i) => i.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory CinemaStack.fromJson(Map<String, dynamic> json) => CinemaStack(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    emoji: json['emoji'] ?? '🎬',
    curator: json['curator'] ?? 'You',
    isEditorial: json['isEditorial'] ?? false,
    items: (json['items'] as List<dynamic>?)
            ?.map((i) => MediaItem.fromJson(i))
            .toList() ??
        [],
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );

  CinemaStack copyWith({
    String? title,
    String? description,
    String? emoji,
    List<MediaItem>? items,
  }) {
    return CinemaStack(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      curator: curator,
      isEditorial: isEditorial,
      items: items ?? this.items,
      createdAt: createdAt,
    );
  }
}
