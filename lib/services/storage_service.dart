import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';

class ContinueWatchingItem {
  final MediaItem media;
  final double progress; // 0.0 to 1.0
  final int positionSeconds;
  final int totalSeconds;

  ContinueWatchingItem({
    required this.media,
    required this.progress,
    required this.positionSeconds,
    required this.totalSeconds,
  });

  Map<String, dynamic> toJson() => {
    'media': media.toJson(),
    'progress': progress,
    'positionSeconds': positionSeconds,
    'totalSeconds': totalSeconds,
  };

  factory ContinueWatchingItem.fromJson(Map<String, dynamic> json) => ContinueWatchingItem(
    media: MediaItem.fromJson(json['media']),
    progress: (json['progress'] as num).toDouble(),
    positionSeconds: json['positionSeconds'] ?? 0,
    totalSeconds: json['totalSeconds'] ?? 0,
  );
}

class StorageService {
  static const String _watchlistKey = 'flickora_watchlist';
  static const String _favoritesKey = 'flickora_favorites';
  static const String _continueWatchingKey = 'flickora_continue_watching';
  static const String _searchHistoryKey = 'flickora_search_history';
  static const String _apiKeyKey = 'flickora_custom_api_key';
  static const String _qualityKey = 'flickora_stream_quality';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Watchlist ---
  List<MediaItem> getWatchlist() {
    final raw = _prefs.getStringList(_watchlistKey) ?? [];
    return raw.map((item) => MediaItem.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveWatchlist(List<MediaItem> items) async {
    final raw = items.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_watchlistKey, raw);
  }

  // --- Favorites ---
  List<MediaItem> getFavorites() {
    final raw = _prefs.getStringList(_favoritesKey) ?? [];
    return raw.map((item) => MediaItem.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveFavorites(List<MediaItem> items) async {
    final raw = items.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_favoritesKey, raw);
  }

  // --- Continue Watching ---
  List<ContinueWatchingItem> getContinueWatching() {
    final raw = _prefs.getStringList(_continueWatchingKey) ?? [];
    return raw.map((item) => ContinueWatchingItem.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveContinueWatching(List<ContinueWatchingItem> items) async {
    final raw = items.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_continueWatchingKey, raw);
  }

  // --- Search History ---
  List<String> getSearchHistory() {
    return _prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> addSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final history = getSearchHistory();
    history.remove(query);
    history.insert(0, query);
    if (history.length > 15) {
      history.removeRange(15, history.length);
    }
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  // --- Settings ---
  String? getCustomApiKey() {
    return _prefs.getString(_apiKeyKey);
  }

  Future<void> setCustomApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      await _prefs.remove(_apiKeyKey);
    } else {
      await _prefs.setString(_apiKeyKey, key.trim());
    }
  }

  String getStreamQuality() {
    return _prefs.getString(_qualityKey) ?? '1080p Ultra HD';
  }

  Future<void> setStreamQuality(String quality) async {
    await _prefs.setString(_qualityKey, quality);
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
