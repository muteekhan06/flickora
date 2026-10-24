import 'package:flutter_test/flutter_test.dart';
import 'package:flickora/models/media_item.dart';
import 'package:flickora/models/episode.dart';
import 'package:flickora/models/actor.dart';
import 'package:flickora/core/constants.dart';

void main() {
  test('MediaItem model parses JSON correctly', () {
    final sample = {
      'id': 101,
      'title': 'Test Movie',
      'overview': 'Test Overview',
      'vote_average': 8.5,
      'vote_count': 1200,
      'release_date': '2024-05-10',
      'genre_ids': [28, 878],
      'media_type': 'movie',
      'direct_stream_url': 'https://sample.com/video.mp4',
    };

    final item = MediaItem.fromJson(sample);

    expect(item.id, 101);
    expect(item.title, 'Test Movie');
    expect(item.releaseYear, '2024');
    expect(item.formattedRating, '8.5');
    expect(item.hasDirectStream, isTrue);
  });

  test('Episode model formats duration and titles correctly', () {
    final ep = Episode(
      id: 1,
      name: 'Pilot Episode',
      overview: 'First episode description',
      voteAverage: 8.9,
      episodeNumber: 1,
      seasonNumber: 1,
      runtime: 52,
      airDate: '2024-01-01',
    );

    expect(ep.formattedDuration, '52m');
    expect(ep.episodeNumber, 1);
  });

  test('ActorDetail model parses correctly', () {
    final actor = ActorDetail(
      id: 10,
      name: 'Zendaya',
      biography: 'Award-winning actress',
    );

    expect(actor.name, 'Zendaya');
    expect(actor.knownForDepartment, 'Acting');
  });

  test('FlickoraConstants has freeCinemaMedia and fallbackMedia', () {
    expect(FlickoraConstants.freeCinemaMedia.isNotEmpty, isTrue);
    expect(FlickoraConstants.fallbackMedia.isNotEmpty, isTrue);
    expect(FlickoraConstants.appName, 'Flickora');
  });
}
