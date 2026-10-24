import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/tmdb_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storage;
  final TmdbService _tmdbService;

  SettingsProvider(this._storage, this._tmdbService) {
    _customApiKey = _storage.getCustomApiKey();
    _streamQuality = _storage.getStreamQuality();
  }

  String? _customApiKey;
  String _streamQuality = '1080p Ultra HD';
  String _audioProfile = 'Dialogue Clarity';
  String _themePreset = 'OLED Midnight';

  String? get customApiKey => _customApiKey;
  String get streamQuality => _streamQuality;
  String get audioProfile => _audioProfile;
  String get themePreset => _themePreset;

  bool get hasCustomApiKey => _customApiKey != null && _customApiKey!.isNotEmpty;

  void setAudioProfile(String profile) {
    _audioProfile = profile;
    notifyListeners();
  }

  void setThemePreset(String preset) {
    _themePreset = preset;
    notifyListeners();
  }

  Future<void> setCustomApiKey(String? key) async {
    _customApiKey = key;
    await _storage.setCustomApiKey(key);
    _tmdbService.updateApiKey(key);
    notifyListeners();
  }

  Future<void> setStreamQuality(String quality) async {
    _streamQuality = quality;
    await _storage.setStreamQuality(quality);
    notifyListeners();
  }

  Future<void> clearAllAppData() async {
    await _storage.clearAllData();
    _customApiKey = null;
    _streamQuality = '1080p Ultra HD';
    _tmdbService.updateApiKey(null);
    notifyListeners();
  }
}
