import '../core/constants.dart';
import 'media_item.dart';

class ActorDetail {
  final int id;
  final String name;
  final String biography;
  final String? birthday;
  final String? placeOfBirth;
  final String? profilePath;
  final String knownForDepartment;
  final List<MediaItem> filmography;

  ActorDetail({
    required this.id,
    required this.name,
    required this.biography,
    this.birthday,
    this.placeOfBirth,
    this.profilePath,
    this.knownForDepartment = 'Acting',
    this.filmography = const [],
  });

  String get profileUrl {
    if (profilePath == null || profilePath!.isEmpty) {
      return 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80';
    }
    return '${FlickoraConstants.imageBaseW500}$profilePath';
  }

  factory ActorDetail.fromJson(Map<String, dynamic> json, {List<MediaItem> credits = const []}) {
    return ActorDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      biography: json['biography'] != null && (json['biography'] as String).isNotEmpty
          ? json['biography']
          : 'No detailed biography available for this artist.',
      birthday: json['birthday'],
      placeOfBirth: json['place_of_birth'],
      profilePath: json['profile_path'],
      knownForDepartment: json['known_for_department'] ?? 'Acting',
      filmography: credits,
    );
  }
}
