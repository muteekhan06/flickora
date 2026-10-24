import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../services/storage_service.dart';

class SearchProvider with ChangeNotifier {
  final TmdbService _service;
  final StorageService _storage;

  SearchProvider(this._service, this._storage) {
    _searchHistory = _storage.getSearchHistory();
  }

  String _query = '';
  int? _selectedGenreId;
  bool _isLoading = false;
  List<MediaItem> _results = [];
  List<String> _searchHistory = [];

  String get query => _query;
  int? get selectedGenreId => _selectedGenreId;
  bool get isLoading => _isLoading;
  List<MediaItem> get results => _results;
  List<String> get searchHistory => _searchHistory;

  Future<void> search(String query) async {
    _query = query;
    _selectedGenreId = null;

    if (query.trim().isEmpty) {
      _results = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _results = await _service.searchMulti(query);
      if (_results.isNotEmpty) {
        await _storage.addSearchHistory(query.trim());
        _searchHistory = _storage.getSearchHistory();
      }
    } catch (_) {
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByGenre(int? genreId) async {
    _selectedGenreId = genreId;
    if (genreId == null) {
      if (_query.isNotEmpty) {
        await search(_query);
      } else {
        _results = [];
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _results = await _service.getByGenre(genreId);
    } catch (_) {
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _query = '';
    _selectedGenreId = null;
    _results = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storage.clearSearchHistory();
    _searchHistory = [];
    notifyListeners();
  }
}
