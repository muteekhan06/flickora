import 'package:flutter_test/flutter_test.dart';
import 'package:flickora/models/media_item.dart';
import 'package:flickora/models/episode.dart';
import 'package:flickora/models/actor.dart';
import 'package:flickora/models/diary_entry.dart';
import 'package:flickora/models/cinema_stack.dart';
import 'package:flickora/models/subtitle_cue.dart';
import 'package:flickora/models/scene_bookmark.dart';
import 'package:flickora/models/trivia_question.dart';
import 'package:flickora/models/cinematic_universe.dart';
import 'package:flickora/models/director_profile.dart';
import 'package:flickora/models/release_reminder.dart';
import 'package:flickora/models/festival_award.dart';
import 'package:flickora/models/cinema_quote.dart';
import 'package:flickora/models/cinematography_technique.dart';
import 'package:flickora/models/cinephile_achievement.dart';
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

  test('CinemaStack model serializes and clones correctly', () {
    final stack = CinemaStack(
      id: 'stack_test',
      title: 'Neon Cyberpunk',
      description: 'Futuristic nightscapes and synths',
      emoji: '🌃',
      isEditorial: true,
      items: [
        MediaItem(
          id: 999,
          title: 'Blade Runner 2049',
          overview: 'Denis Villeneuve masterpiece',
          posterPath: '/path.jpg',
          backdropPath: '/back.jpg',
          voteAverage: 8.5,
          voteCount: 15000,
          releaseDate: '2017-10-06',
          genreIds: [878],
          mediaType: 'movie',
        ),
      ],
    );

    final json = stack.toJson();
    final restored = CinemaStack.fromJson(json);

    expect(restored.id, 'stack_test');
    expect(restored.title, 'Neon Cyberpunk');
    expect(restored.items.length, 1);
    expect(restored.items.first.title, 'Blade Runner 2049');

    final updated = stack.copyWith(title: 'Cyberpunk Classics');
    expect(updated.title, 'Cyberpunk Classics');
    expect(updated.items.length, 1);
  });

  test('FlickoraConstants has freeCinemaMedia and fallbackMedia', () {
    expect(FlickoraConstants.freeCinemaMedia.isNotEmpty, isTrue);
    expect(FlickoraConstants.fallbackMedia.isNotEmpty, isTrue);
    expect(FlickoraConstants.appName, 'Flickora');
    expect(FlickoraConstants.appVersion, '1.6.0');
  });

  test('SubtitleCue and SubtitleTrack cue matching works accurately', () {
    final cue = SubtitleCue(
      start: const Duration(seconds: 5),
      end: const Duration(seconds: 10),
      text: 'Cinema is life.',
    );

    expect(cue.isActiveAt(const Duration(seconds: 4)), isFalse);
    expect(cue.isActiveAt(const Duration(seconds: 5)), isTrue);
    expect(cue.isActiveAt(const Duration(seconds: 7)), isTrue);
    expect(cue.isActiveAt(const Duration(seconds: 10)), isTrue);
    expect(cue.isActiveAt(const Duration(seconds: 11)), isFalse);

    final tracks = SubtitleTrack.getMockTracksFor('Oppenheimer');
    expect(tracks.length, greaterThanOrEqualTo(3));
    expect(tracks.any((t) => t.id == 'en'), isTrue);
  });

  test('SceneBookmark formats timecode and serializes correctly', () {
    final bm = SceneBookmark(
      id: 'bm_1',
      mediaId: 157336,
      mediaTitle: 'Interstellar',
      seconds: 4462, // 1h 14m 22s
      note: 'Docking sequence climax',
      createdAt: DateTime.now(),
    );

    expect(bm.formattedTimecode, '01:14:22');
    final json = bm.toJson();
    final restored = SceneBookmark.fromJson(json);
    expect(restored.id, 'bm_1');
    expect(restored.seconds, 4462);
    expect(restored.note, contains('Docking'));
  });

  test('TriviaQuestion deck has valid multiple-choice questions', () {
    final deck = TriviaQuestion.getDailyDeck();
    expect(deck.length, greaterThanOrEqualTo(5));
    for (var q in deck) {
      expect(q.options.length, 4);
      expect(q.correctIndex >= 0 && q.correctIndex < 4, isTrue);
      expect(q.explanation.isNotEmpty, isTrue);
    }
  });

  test('CinematicUniverse release vs chronological orders sort properly', () {
    final universes = CinematicUniverse.getUniverses();
    expect(universes.isNotEmpty, isTrue);

    final mcu = universes.firstWhere((u) => u.id == 'marvel');
    final release = mcu.inReleaseOrder;
    final chrono = mcu.inChronologicalOrder;

    expect(release.first.media.title, contains('Iron Man'));
    expect(chrono.first.media.title, contains('Captain America'));
  });

  test('DirectorProfile masterworks and hallmarks are structured', () {
    final directors = DirectorProfile.getDirectors();
    expect(directors.length, greaterThanOrEqualTo(3));
    final nolan = directors.firstWhere((d) => d.id == 'nolan');
    expect(nolan.hallmarks.isNotEmpty, isTrue);
    expect(nolan.filmography.length, greaterThanOrEqualTo(3));
  });

  test('ReleaseReminder serializes correctly', () {
    final reminder = ReleaseReminder(
      mediaId: 9999,
      title: 'Avatar 3',
      releaseDate: '2025-12-19',
      posterPath: '/path.jpg',
      addedAt: DateTime.now(),
    );

    final json = reminder.toJson();
    final restored = ReleaseReminder.fromJson(json);
    expect(restored.mediaId, 9999);
    expect(restored.title, 'Avatar 3');
  });

  test('FestivalAward vault has Cannes, Venice, and Berlin winners', () {
    final awards = FestivalAward.getFestivalVault();
    expect(awards.length, greaterThanOrEqualTo(4));
    expect(awards.any((a) => a.festivalName.contains('Cannes')), isTrue);
    expect(awards.any((a) => a.awardName.contains('Palme d\'Or')), isTrue);
  });

  test('CinemaQuote library contains verified famous lines', () {
    final quotes = CinemaQuote.getIconicQuotes();
    expect(quotes.length, greaterThanOrEqualTo(5));
    expect(quotes.any((q) => q.movieTitle == 'Interstellar'), isTrue);
    expect(quotes.any((q) => q.quote.contains('gentle into that good night')), isTrue);
  });

  test('CinematographyTechnique contains Dolly Zoom and Long Take', () {
    final techs = CinematographyTechnique.getMasterTechniques();
    expect(techs.length, greaterThanOrEqualTo(4));
    expect(techs.any((t) => t.id == 'dolly_zoom'), isTrue);
    expect(techs.any((t) => t.id == 'long_take'), isTrue);
  });

  test('CinephileAchievement serializes correctly', () {
    final ach = CinephileAchievement(
      id: 'test_ach',
      title: 'First Review',
      description: 'Logged your first review',
      icon: '🏆',
      tier: 'Gold',
      xpReward: 100,
      isUnlocked: true,
    );

    final json = ach.toJson();
    final restored = CinephileAchievement.fromJson(json);
    expect(restored.id, 'test_ach');
    expect(restored.xpReward, 100);
    expect(restored.isUnlocked, isTrue);
  });
}
