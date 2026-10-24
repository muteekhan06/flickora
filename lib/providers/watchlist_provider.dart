import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../services/storage_service.dart';

class WatchlistProvider with ChangeNotifier {
  final StorageService _storage;

  List<MediaItem> _watchlist = [];
  List<MediaItem> _favorites = [];
  List<ContinueWatchingItem> _continueWatching = [];

  WatchlistProvider(this._storage) {
    loadSavedData();
  }

  List<MediaItem> get watchlist => _watchlist;
  List<MediaItem> get favorites => _favorites;
  List<ContinueWatchingItem> get continueWatching => _continueWatching;

  void loadSavedData() {
    _watchlist = _storage.getWatchlist();
    _favorites = _storage.getFavorites();
    _continueWatching = _storage.getContinueWatching();
    notifyListeners();
  }

  bool isWatchlisted(int id) {
    return _watchlist.any((item) => item.id == id);
  }

  Future<void> toggleWatchlist(MediaItem media) async {
    final index = _watchlist.indexWhere((item) => item.id == media.id);
    if (index >= 0) {
      _watchlist.removeAt(index);
    } else {
      _watchlist.insert(0, media);
    }
    notifyListeners();
    await _storage.saveWatchlist(_watchlist);
  }

  bool isFavorite(int id) {
    return _favorites.any((item) => item.id == id);
  }

  Future<void> toggleFavorite(MediaItem media) async {
    final index = _favorites.indexWhere((item) => item.id == media.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.insert(0, media);
    }
    notifyListeners();
    await _storage.saveFavorites(_favorites);
  }

  Future<void> saveProgress(MediaItem media, double progress, int positionSec, int totalSec) async {
    _continueWatching.removeWhere((item) => item.media.id == media.id);
    if (progress < 0.95) {
      _continueWatching.insert(
        0,
        ContinueWatchingItem(
          media: media,
          progress: progress,
          positionSeconds: positionSec,
          totalSeconds: totalSec,
        ),
      );
    }
    notifyListeners();
    await _storage.saveContinueWatching(_continueWatching);
  }

  Future<void> removeContinueWatching(int id) async {
    _continueWatching.removeWhere((item) => item.media.id == id);
    notifyListeners();
    await _storage.saveContinueWatching(_continueWatching);
  }

  Future<void> clearHistory() async {
    _continueWatching.clear();
    notifyListeners();
    await _storage.saveContinueWatching([]);
  }
}
