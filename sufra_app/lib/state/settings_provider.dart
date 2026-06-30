import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool _darkMode = false;
  bool _soundEnabled = true;
  bool _loaded = false;

  bool get darkMode => _darkMode;
  bool get soundEnabled => _soundEnabled;
  bool get loaded => _loaded;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    _darkMode = await _storage.getDarkMode();
    _soundEnabled = await _storage.getSoundEnabled();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await _storage.setDarkMode(value);
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    await _storage.setSoundEnabled(value);
  }
}
