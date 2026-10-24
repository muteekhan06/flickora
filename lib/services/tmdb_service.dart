import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/media_item.dart';
import '../models/cast.dart';
import '../models/trailer.dart';
import '../models/episode.dart';
import '../models/actor.dart';
import '../models/watch_provider.dart';

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

  // --- Free Full Cinema (Full-length playable movies) ---
  List<MediaItem> getFreeCinema() {
    return FlickoraConstants.freeCinemaMedia.map((json) => MediaItem.fromJson(json)).toList();
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
        'with_keywords': '210024|287501|284004',
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

    // Check free cinema first
    final freeMatch = FlickoraConstants.freeCinemaMedia.firstWhere(
      (m) => m['id'] == id,
      orElse: () => {},
    );
    if (freeMatch.isNotEmpty) {
      return MediaItem.fromJson(freeMatch);
    }

    final match = FlickoraConstants.fallbackMedia.firstWhere(
      (m) => m['id'] == id,
      orElse: () => FlickoraConstants.fallbackMedia.first,
    );
    return MediaItem.fromJson(match);
  }

  // --- TV Show Season Episodes ---
  Future<List<Episode>> getSeasonEpisodes(int tvId, int seasonNumber) async {
    try {
      final uri = _buildUri('/tv/$tvId/season/$seasonNumber');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final episodesList = data['episodes'] as List? ?? [];
        return episodesList.map((ep) => Episode.fromJson(ep, seasonNumber)).toList();
      }
    } catch (_) {}

    // High quality mock episodes fallback
    return List.generate(8, (index) {
      final epNum = index + 1;
      return Episode(
        id: tvId * 100 + epNum,
        name: 'Episode $epNum: The Genesis Arc',
        overview: 'Tensions peak as the faction embarks on a dangerous reconnaissance mission across enemy territory.',
        stillPath: null,
        voteAverage: 8.4 + (index % 5) * 0.1,
        episodeNumber: epNum,
        seasonNumber: seasonNumber,
        runtime: 48 + (index * 2),
        airDate: '2024-03-${10 + epNum}',
        streamUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      );
    });
  }

  // --- Actor Details ---
  Future<ActorDetail> getActorDetails(int actorId) async {
    try {
      final uri = _buildUri('/person/$actorId', {'append_to_response': 'combined_credits'});
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<MediaItem> filmography = [];
        if (data['combined_credits'] != null && data['combined_credits']['cast'] != null) {
          final castCredits = data['combined_credits']['cast'] as List;
          filmography = castCredits
              .take(15)
              .map((c) => MediaItem.fromJson(c, defaultMediaType: c['media_type'] ?? 'movie'))
              .toList();
        }
        return ActorDetail.fromJson(data, credits: filmography);
      }
    } catch (_) {}

    return ActorDetail(
      id: actorId,
      name: 'Featured Artist',
      biography: 'Acclaimed international performer known for visionary acting and dramatic character portrayals across blockbuster cinema and award-winning television series.',
      birthday: '1995-12-27',
      placeOfBirth: 'New York City, USA',
      profilePath: null,
      knownForDepartment: 'Acting',
      filmography: _getFallbackItems(),
    );
  }

  // --- Where to Watch (Watch Providers) ---
  Future<List<WatchProvider>> getWatchProviders(int id, String mediaType) async {
    try {
      final uri = _buildUri('/$mediaType/$id/watch/providers');
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as Map<String, dynamic>? ?? {};
        final us = results['US'] as Map<String, dynamic>? ?? results.values.firstOrNull as Map<String, dynamic>?;

        if (us != null) {
          final List<WatchProvider> providers = [];
          if (us['free'] != null) {
            for (var p in (us['free'] as List)) {
              providers.add(WatchProvider.fromJson(p, type: 'Stream Free'));
            }
          }
          if (us['flatrate'] != null) {
            for (var p in (us['flatrate'] as List)) {
              providers.add(WatchProvider.fromJson(p, type: 'Subscription'));
            }
          }
          if (us['ads'] != null) {
            for (var p in (us['ads'] as List)) {
              providers.add(WatchProvider.fromJson(p, type: 'Free with Ads'));
            }
          }
          if (providers.isNotEmpty) return providers;
        }
      }
    } catch (_) {}

    // Default streaming providers badge fallback
    return [
      WatchProvider(id: 1, name: 'Tubi TV', type: 'Stream Free', logoPath: null),
      WatchProvider(id: 2, name: 'Pluto TV', type: 'Stream Free', logoPath: null),
      WatchProvider(id: 3, name: 'Freevee', type: 'Free with Ads', logoPath: null),
    ];
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
      CastMember(id: 1190668, name: 'Timothée Chalamet', character: 'Paul Atreides'),
      CastMember(id: 505710, name: 'Zendaya', character: 'Chani'),
      CastMember(id: 93425, name: 'Rebecca Ferguson', character: 'Lady Jessica'),
      CastMember(id: 3810, name: 'Javier Bardem', character: 'Stilgar'),
      CastMember(id: 1373737, name: 'Austin Butler', character: 'Feyd-Rautha Harkonnen'),
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
