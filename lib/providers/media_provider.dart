import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../services/tmdb_service.dart';

class MediaProvider with ChangeNotifier {
  final TmdbService _service;

  MediaProvider(this._service);

  bool _isLoading = false;
  String? _errorMessage;

  List<MediaItem> _heroItems = [];
  List<MediaItem> _trending = [];
  List<MediaItem> _popularMovies = [];
  List<MediaItem> _topRatedMovies = [];
  List<MediaItem> _popularTV = [];
  List<MediaItem> _anime = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MediaItem> get heroItems => _heroItems;
  List<MediaItem> get trending => _trending;
  List<MediaItem> get popularMovies => _popularMovies;
  List<MediaItem> get topRatedMovies => _topRatedMovies;
  List<MediaItem> get popularTV => _popularTV;
  List<MediaItem> get anime => _anime;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getTrending(),
        _service.getPopularMovies(),
        _service.getTopRatedMovies(),
        _service.getPopularTVShows(),
        _service.getAnime(),
      ]);

      _trending = results[0];
      _popularMovies = results[1];
      _topRatedMovies = results[2];
      _popularTV = results[3];
      _anime = results[4];

      if (_trending.isNotEmpty) {
        _heroItems = _trending.take(5).toList();
      } else if (_popularMovies.isNotEmpty) {
        _heroItems = _popularMovies.take(5).toList();
      }
    } catch (e) {
      _errorMessage = 'Failed to load media catalog: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}
