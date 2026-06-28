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

  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, value);
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
}
