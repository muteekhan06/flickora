import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';
import '../models/diary_entry.dart';
import '../models/cinema_stack.dart';
import '../models/scene_bookmark.dart';
import '../models/release_reminder.dart';
import '../core/constants.dart';

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
  static const String _diaryKey = 'flickora_cinema_diary';
  static const String _stacksKey = 'flickora_cinema_stacks';
  static const String _sceneBookmarksKey = 'flickora_scene_bookmarks';
  static const String _remindersKey = 'flickora_release_reminders';
  static const String _cinephileXpKey = 'flickora_cinephile_xp';
  static const String _triviaStreakKey = 'flickora_trivia_streak';

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

  // --- Cinema Diary ---
  List<DiaryEntry> getDiary() {
    final raw = _prefs.getStringList(_diaryKey) ?? [];
    return raw.map((item) => DiaryEntry.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveDiary(List<DiaryEntry> entries) async {
    final raw = entries.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList(_diaryKey, raw);
  }

  Future<void> addDiaryEntry(DiaryEntry entry) async {
    final list = getDiary();
    list.removeWhere((e) => e.media.id == entry.media.id);
    list.insert(0, entry);
    await saveDiary(list);
  }

  Future<void> deleteDiaryEntry(String id) async {
    final list = getDiary();
    list.removeWhere((e) => e.id == id);
    await saveDiary(list);
  }

  // --- Cinema Stacks (Custom Curated Collections) ---
  List<CinemaStack> getStacks() {
    final raw = _prefs.getStringList(_stacksKey);
    if (raw == null || raw.isEmpty) {
      return _generateDefaultEditorialStacks();
    }
    try {
      return raw.map((item) => CinemaStack.fromJson(jsonDecode(item))).toList();
    } catch (_) {
      return _generateDefaultEditorialStacks();
    }
  }

  Future<void> saveStacks(List<CinemaStack> stacks) async {
    final raw = stacks.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs.setStringList(_stacksKey, raw);
  }

  Future<void> addStack(CinemaStack stack) async {
    final list = getStacks();
    list.insert(0, stack);
    await saveStacks(list);
  }

  Future<void> deleteStack(String stackId) async {
    final list = getStacks();
    list.removeWhere((s) => s.id == stackId && !s.isEditorial);
    await saveStacks(list);
  }

  List<CinemaStack> _generateDefaultEditorialStacks() {
    final allMedia = FlickoraConstants.fallbackMedia.map((json) => MediaItem.fromJson(json)).toList();
    final freeCinema = FlickoraConstants.freeCinemaMedia.map((json) => MediaItem.fromJson(json)).toList();

    return [
      CinemaStack(
        id: 'editorial_sci_fi',
        title: 'Hard Sci-Fi & Mindbenders',
        description: 'Atmospheric cosmic odysseys, dystopian realities, and intricate quantum puzzles.',
        emoji: '🌌',
        curator: 'Flickora Editorial',
        isEditorial: true,
        items: allMedia.where((m) => m.genreIds.contains(878) || m.id == 157336 || m.id == 27205).toList(),
      ),
      CinemaStack(
        id: 'editorial_a24',
        title: 'Modern Visionary Essentials',
        description: 'Bold filmmaking, unforgettable character depth, and boundary-pushing cinema.',
        emoji: '🏆',
        curator: 'Flickora Editorial',
        isEditorial: true,
        items: allMedia.where((m) => m.voteAverage >= 8.0).toList(),
      ),
      CinemaStack(
        id: 'editorial_free_vault',
        title: 'The Open Vault (Free Full Cinema)',
        description: 'Complete full-length legendary movies streamable directly in-app with zero ads.',
        emoji: '🎞️',
        curator: 'Flickora Archives',
        isEditorial: true,
        items: freeCinema,
      ),
      CinemaStack(
        id: 'editorial_comfort',
        title: 'Late Night Comfort Cinema',
        description: 'Warm lighting, nostalgic atmospheres, and comforting episodic storytelling.',
        emoji: '🍿',
        curator: 'Flickora Editorial',
        isEditorial: true,
        items: allMedia.where((m) => m.mediaType == 'tv' || m.genreIds.contains(16) || m.genreIds.contains(35)).toList(),
      ),
    ];
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

  // --- Letterboxd CSV Export ---
  String exportLetterboxdCsv() {
    final diary = getDiary();
    final buffer = StringBuffer();
    buffer.writeln('Title,Year,Rating10,WatchedDate,Rewatch,Review');
    for (var entry in diary) {
      final title = '"${entry.media.title.replaceAll('"', '""')}"';
      final year = entry.media.releaseYear;
      final rating10 = (entry.rating * 2).toInt();
      final date = entry.watchedDate.toIso8601String().substring(0, 10);
      final rewatch = entry.rewatch ? 'Yes' : 'No';
      final review = '"${entry.reviewText.replaceAll('"', '""')}"';
      buffer.writeln('$title,$year,$rating10,$date,$rewatch,$review');
    }
    return buffer.toString();
  }

  // --- Scene Bookmarks ---
  List<SceneBookmark> getSceneBookmarks([int? mediaId]) {
    final raw = _prefs.getStringList(_sceneBookmarksKey) ?? [];
    final all = raw.map((item) => SceneBookmark.fromJson(jsonDecode(item))).toList();
    if (mediaId != null) {
      return all.where((b) => b.mediaId == mediaId).toList();
    }
    return all;
  }

  Future<void> saveSceneBookmark(SceneBookmark bookmark) async {
    final all = getSceneBookmarks();
    all.insert(0, bookmark);
    final raw = all.map((b) => jsonEncode(b.toJson())).toList();
    await _prefs.setStringList(_sceneBookmarksKey, raw);
  }

  Future<void> deleteSceneBookmark(String bookmarkId) async {
    final all = getSceneBookmarks();
    all.removeWhere((b) => b.id == bookmarkId);
    final raw = all.map((b) => jsonEncode(b.toJson())).toList();
    await _prefs.setStringList(_sceneBookmarksKey, raw);
  }

  // --- Release Reminders ---
  List<ReleaseReminder> getReminders() {
    final raw = _prefs.getStringList(_remindersKey) ?? [];
    return raw.map((r) => ReleaseReminder.fromJson(jsonDecode(r))).toList();
  }

  bool isReminderSet(int mediaId) {
    final reminders = getReminders();
    return reminders.any((r) => r.mediaId == mediaId);
  }

  Future<bool> toggleReminder(ReleaseReminder reminder) async {
    final reminders = getReminders();
    final index = reminders.indexWhere((r) => r.mediaId == reminder.mediaId);
    bool added;
    if (index >= 0) {
      reminders.removeAt(index);
      added = false;
    } else {
      reminders.insert(0, reminder);
      added = true;
    }
    final raw = reminders.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(_remindersKey, raw);
    return added;
  }

  // --- Cinephile XP & Streak ---
  int getCinephileXp() {
    return _prefs.getInt(_cinephileXpKey) ?? 150;
  }

  Future<void> addCinephileXp(int xp) async {
    final current = getCinephileXp();
    await _prefs.setInt(_cinephileXpKey, current + xp);
  }

  int getTriviaStreak() {
    return _prefs.getInt(_triviaStreakKey) ?? 1;
  }

  Future<void> incrementTriviaStreak() async {
    final current = getTriviaStreak();
    await _prefs.setInt(_triviaStreakKey, current + 1);
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
