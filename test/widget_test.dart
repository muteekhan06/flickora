import 'package:flutter_test/flutter_test.dart';
import 'package:flickora/models/media_item.dart';
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
    };

    final item = MediaItem.fromJson(sample);

    expect(item.id, 101);
    expect(item.title, 'Test Movie');
    expect(item.releaseYear, '2024');
    expect(item.formattedRating, '8.5');
    expect(item.genreNames.contains('Action'), isTrue);
  });

  test('FlickoraConstants has fallback catalog', () {
    expect(FlickoraConstants.fallbackMedia.isNotEmpty, isTrue);
    expect(FlickoraConstants.appName, 'Flickora');
  });
}
