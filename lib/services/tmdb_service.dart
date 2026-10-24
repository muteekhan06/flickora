import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/media_item.dart';
import '../models/cast.dart';
import '../models/trailer.dart';

class TmdbService {
  String _apiKey;

  TmdbService({String? apiKey}) : _apiKey = apiKey ?? FlickoraConstants.defaultTmdbApiKey;

  void updateApiKey(String? newKey) {
    _apiKey = (newKey != null && newKey.trim().isNotEmpty)
        ? newKey.trim()
        : FlickoraConstants.defaultTmdbApiKey;
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
  };

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final params = {
      'api_key': _apiKey,
      'language': 'en-US',
      ...?queryParams,
    };
    return Uri.parse('${FlickoraConstants.tmdbBaseUrl}$path').replace(queryParameters: params);
  }

  // --- Fallback generator ---
  List<MediaItem> _getFallbackItems({String mediaType = 'movie', int? genreFilter}) {
    var items = FlickoraConstants.fallbackMedia.map((json) => MediaItem.fromJson(json)).toList();
    if (genreFilter != null) {
      final filtered = items.where((i) => i.genreIds.contains(genreFilter)).toList();
      if (filtered.isNotEmpty) return filtered;
    }
    if (mediaType == 'tv') {
      final tvs = items.where((i) => i.mediaType == 'tv').toList();
      if (tvs.isNotEmpty) return tvs;
    }
    return items;
  }

  // --- Trending ---
  Future<List<MediaItem>> getTrending({String timeWindow = 'day'}) async {
    try {
      final uri = _buildUri('/trending/all/$timeWindow');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results
            .where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv')
            .map((item) => MediaItem.fromJson(item))
            .toList();
      }
    } catch (_) {}
    return _getFallbackItems();
  }

  // --- Popular Movies ---
  Future<List<MediaItem>> getPopularMovies({int page = 1}) async {
    try {
      final uri = _buildUri('/movie/popular', {'page': page.toString()});
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) => MediaItem.fromJson(item, defaultMediaType: 'movie')).toList();
      }
    } catch (_) {}
    return _getFallbackItems(mediaType: 'movie');
  }

  // --- Top Rated Movies ---
  Future<List<MediaItem>> getTopRatedMovies({int page = 1}) async {
    try {
      final uri = _buildUri('/movie/top_rated', {'page': page.toString()});
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) => MediaItem.fromJson(item, defaultMediaType: 'movie')).toList();
      }
    } catch (_) {}
    return _getFallbackItems(mediaType: 'movie');
  }

  // --- Now Playing ---
  Future<List<MediaItem>> getNowPlaying({int page = 1}) async {
    try {
      final uri = _buildUri('/movie/now_playing', {'page': page.toString()});
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) => MediaItem.fromJson(item, defaultMediaType: 'movie')).toList();
      }
    } catch (_) {}
    return _getFallbackItems(mediaType: 'movie');
  }

  // --- Popular TV Shows ---
  Future<List<MediaItem>> getPopularTVShows({int page = 1}) async {
    try {
      final uri = _buildUri('/tv/popular', {'page': page.toString()});
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) => MediaItem.fromJson(item, defaultMediaType: 'tv')).toList();
      }
    } catch (_) {}
    return _getFallbackItems(mediaType: 'tv');
  }

  // --- Top Rated TV Shows ---
  Future<List<MediaItem>> getTopRatedTVShows({int page = 1}) async {
    try {
      final uri = _buildUri('/tv/top_rated', {'page': page.toString()});
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) => MediaItem.fromJson(item, defaultMediaType: 'tv')).toList();
      }
    } catch (_) {}
    return _getFallbackItems(mediaType: 'tv');
  }

  // --- Anime / Animation ---
  Future<List<MediaItem>> getAnime({int page = 1}) async {
    try {
      final uri = _buildUri('/discover/tv', {
        'with_genres': '16',
        'with_keywords': '210024|287501|284004', // Anime keywords
        'sort_by': 'popularity.desc',
        'page': page.toString(),
      });
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) => MediaItem.fromJson(item, defaultMediaType: 'tv')).toList();
      }
    } catch (_) {}
    return _getFallbackItems(mediaType: 'tv', genreFilter: 16);
  }

  // --- Media Details ---
  Future<MediaItem> getMediaDetails(int id, String mediaType) async {
    try {
      final uri = _buildUri('/$mediaType/$id', {'append_to_response': 'videos,credits,similar'});
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        String? trailerKey;
        if (data['videos'] != null && data['videos']['results'] != null) {
          final videos = data['videos']['results'] as List;
          final officialTrailer = videos.firstWhere(
            (v) => (v['type'] == 'Trailer' || v['type'] == 'Teaser') && v['site'] == 'YouTube',
            orElse: () => videos.isNotEmpty ? videos.first : null,
          );
          if (officialTrailer != null) {
            trailerKey = officialTrailer['key'];
          }
        }

        final item = MediaItem.fromJson(data, defaultMediaType: mediaType);
        return item.copyWith(trailerKey: trailerKey);
      }
    } catch (_) {}

    // Fallback search
    final match = FlickoraConstants.fallbackMedia.firstWhere(
      (m) => m['id'] == id,
      orElse: () => FlickoraConstants.fallbackMedia.first,
    );
    return MediaItem.fromJson(match);
  }

  // --- Cast & Crew ---
  Future<List<CastMember>> getCredits(int id, String mediaType) async {
    try {
      final uri = _buildUri('/$mediaType/$id/credits');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final castList = data['cast'] as List? ?? [];
        return castList.take(12).map((c) => CastMember.fromJson(c)).toList();
      }
    } catch (_) {}

    return [
      CastMember(id: 1, name: 'Timothée Chalamet', character: 'Paul Atreides'),
      CastMember(id: 2, name: 'Zendaya', character: 'Chani'),
      CastMember(id: 3, name: 'Rebecca Ferguson', character: 'Lady Jessica'),
      CastMember(id: 4, name: 'Javier Bardem', character: 'Stilgar'),
      CastMember(id: 5, name: 'Austin Butler', character: 'Feyd-Rautha Harkonnen'),
    ];
  }

  // --- Video Trailers ---
  Future<List<VideoTrailer>> getTrailers(int id, String mediaType) async {
    try {
      final uri = _buildUri('/$mediaType/$id/videos');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['results'] as List? ?? [];
        return list
            .where((v) => v['site'] == 'YouTube')
            .map((v) => VideoTrailer.fromJson(v))
            .toList();
      }
    } catch (_) {}

    return [
      VideoTrailer(
        id: '1',
        key: 'Way9Dexny3w',
        name: 'Official Main Trailer',
        site: 'YouTube',
        type: 'Trailer',
        official: true,
      ),
      VideoTrailer(
        id: '2',
        key: 'uYPbbksJxIg',
        name: 'Final Teaser Trailer',
        site: 'YouTube',
        type: 'Teaser',
        official: true,
      ),
    ];
  }

  // --- Similar Recommendations ---
  Future<List<MediaItem>> getSimilar(int id, String mediaType) async {
    try {
      final uri = _buildUri('/$mediaType/$id/similar');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results.take(10).map((item) => MediaItem.fromJson(item, defaultMediaType: mediaType)).toList();
      }
    } catch (_) {}
    return _getFallbackItems();
  }

  // --- Search Multi ---
  Future<List<MediaItem>> searchMulti(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = _buildUri('/search/multi', {'query': query.trim()});
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results
            .where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv')
            .map((item) => MediaItem.fromJson(item))
            .toList();
      }
    } catch (_) {}

    // Mock search filtering
    final lower = query.toLowerCase();
    return FlickoraConstants.fallbackMedia
        .where((m) => (m['title'] as String).toLowerCase().contains(lower) ||
                      (m['overview'] as String).toLowerCase().contains(lower))
        .map((m) => MediaItem.fromJson(m))
        .toList();
  }

  // --- Filter By Genre ---
  Future<List<MediaItem>> getByGenre(int genreId, {String mediaType = 'movie'}) async {
    try {
      final uri = _buildUri('/discover/$mediaType', {
        'with_genres': genreId.toString(),
        'sort_by': 'popularity.desc',
      });
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List? ?? [];
        return results.map((item) => MediaItem.fromJson(item, defaultMediaType: mediaType)).toList();
      }
    } catch (_) {}
    return _getFallbackItems(genreFilter: genreId);
  }
}
