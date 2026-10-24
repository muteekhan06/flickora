import 'package:flutter_test/flutter_test.dart';
import 'package:flickora/models/media_item.dart';
import 'package:flickora/models/episode.dart';
import 'package:flickora/models/actor.dart';
import 'package:flickora/models/diary_entry.dart';
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

  test('DiaryEntry model parses and formats correctly', () {
    final sample = {
      'id': 'diary_1',
      'media': {
        'id': 500,
        'title': 'Inception',
        'overview': 'Mind-bending dream theft',
        'vote_average': 8.8,
        'runtime': 148,
        'genre_ids': [878, 28],
      },
      'watchedDate': '2026-10-24T12:00:00.000',
      'rating': 4.5,
      'reviewText': 'A cinematic masterpiece by Christopher Nolan.',
      'rewatch': true,
    };

    final entry = DiaryEntry.fromJson(sample);

    expect(entry.id, 'diary_1');
    expect(entry.media.title, 'Inception');
    expect(entry.rating, 4.5);
    expect(entry.rewatch, isTrue);
    expect(entry.reviewText, contains('masterpiece'));
    expect(entry.toJson()['rating'], 4.5);
  });

  test('FlickoraConstants has freeCinemaMedia and fallbackMedia', () {
    expect(FlickoraConstants.freeCinemaMedia.isNotEmpty, isTrue);
    expect(FlickoraConstants.fallbackMedia.isNotEmpty, isTrue);
    expect(FlickoraConstants.appName, 'Flickora');
  });
}
