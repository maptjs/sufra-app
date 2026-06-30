import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_member.dart';
import '../models/scanned_product.dart';

/// Everything here stays on-device (shared_preferences). Sufra never uploads
/// family or scan data to any server — only the barcode itself is sent to
/// the public Open Food Facts API to look up product info.
class StorageService {
  static const _familyKey = 'sufra_family_members';
  static const _historyKey = 'sufra_scan_history';
  static const _onboardedKey = 'sufra_onboarded';
  static const _darkModeKey = 'sufra_dark_mode';
  static const _soundEnabledKey = 'sufra_sound_enabled';

  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, value);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  Future<List<FamilyMember>> loadFamily() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_familyKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => FamilyMember.fromJson(e)).toList();
  }

  Future<void> saveFamily(List<FamilyMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(members.map((m) => m.toJson()).toList());
    await prefs.setString(_familyKey, raw);
  }

  Future<List<ScannedProduct>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => ScannedProduct.fromJson(e)).toList();
  }

  /// Scan history doubles as an offline-first product cache: if a barcode
  /// was ever looked up before, this returns it instantly with no network
  /// call needed — works even with no internet connection.
  Future<ScannedProduct?> getCachedProduct(String barcode) async {
    final history = await loadHistory();
    for (final p in history) {
      if (p.barcode == barcode) return p;
    }
    return null;
  }

  Future<void> addToHistory(ScannedProduct product) async {
    final history = await loadHistory();
    history.removeWhere((p) => p.barcode == product.barcode);
    history.insert(0, product);
    final trimmed = history.take(100).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(trimmed.map((p) => p.toJson()).toList()));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> clearEverything() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_familyKey);
    await prefs.remove(_onboardedKey);
  }
}
