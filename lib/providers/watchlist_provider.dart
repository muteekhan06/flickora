import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';

class WatchlistProvider with ChangeNotifier {
  final StorageService _storage;

  List<MediaItem> _watchlist = [];
  List<MediaItem> _favorites = [];
  List<ContinueWatchingItem> _continueWatching = [];
  List<DiaryEntry> _diary = [];

  WatchlistProvider(this._storage) {
    loadSavedData();
  }

  List<MediaItem> get watchlist => _watchlist;
  List<MediaItem> get favorites => _favorites;
  List<ContinueWatchingItem> get continueWatching => _continueWatching;
  List<DiaryEntry> get diary => _diary;

  void loadSavedData() {
    _watchlist = _storage.getWatchlist();
    _favorites = _storage.getFavorites();
    _continueWatching = _storage.getContinueWatching();
    _diary = _storage.getDiary();
    notifyListeners();
  }

  // --- Watchlist ---
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

  // --- Favorites ---
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

  // --- Continue Watching ---
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

  // --- Cinema Diary & Personal Stats ---
  bool isLogged(int mediaId) {
    return _diary.any((entry) => entry.media.id == mediaId);
  }

  DiaryEntry? getEntry(int mediaId) {
    try {
      return _diary.firstWhere((entry) => entry.media.id == mediaId);
    } catch (_) {
      return null;
    }
  }

  Future<void> logFilm({
    required MediaItem media,
    required double rating,
    required String reviewText,
    required DateTime watchedDate,
    bool rewatch = false,
  }) async {
    final entry = DiaryEntry(
      id: '${media.id}_${DateTime.now().millisecondsSinceEpoch}',
      media: media,
      watchedDate: watchedDate,
      rating: rating,
      reviewText: reviewText,
      rewatch: rewatch,
    );

    _diary.removeWhere((e) => e.media.id == media.id);
    _diary.insert(0, entry);
    notifyListeners();
    await _storage.saveDiary(_diary);
  }

  Future<void> deleteDiary(String id) async {
    _diary.removeWhere((e) => e.id == id);
    notifyListeners();
    await _storage.deleteDiaryEntry(id);
  }

  // Calculated Stats
  int get totalMinutesLogged {
    int total = 0;
    for (var d in _diary) {
      total += d.media.runtime ?? 110;
    }
    return total;
  }

  String get totalHoursLoggedString {
    final hours = totalMinutesLogged ~/ 60;
    final mins = totalMinutesLogged % 60;
    if (hours > 24) {
      final days = (hours / 24).toStringAsFixed(1);
      return '$days Days ($hours hrs)';
    }
    return '$hours hrs $mins m';
  }

  double get averageDiaryRating {
    if (_diary.isEmpty) return 0.0;
    final sum = _diary.fold<double>(0.0, (prev, e) => prev + e.rating);
    return sum / _diary.length;
  }

  String get topGenre {
    if (_diary.isEmpty) return 'Cinema';
    final Map<String, int> counts = {};
    for (var d in _diary) {
      for (var g in d.media.genreNames) {
        counts[g] = (counts[g] ?? 0) + 1;
      }
    }
    var topG = 'Action';
    var maxCount = 0;
    counts.forEach((g, c) {
      if (c > maxCount) {
        maxCount = c;
        topG = g;
      }
    });
    return topG;
  }
}
