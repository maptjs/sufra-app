import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../services/storage_service.dart';

class FamilyProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<FamilyMember> _members = [];
  bool _loaded = false;

  List<FamilyMember> get members => List.unmodifiable(_members);
  bool get loaded => _loaded;
  bool get isEmpty => _members.isEmpty;

  Future<void> load() async {
    _members = await _storage.loadFamily();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setAll(List<FamilyMember> members) async {
    _members = members;
    notifyListeners();
    await _storage.saveFamily(_members);
  }

  Future<void> upsert(FamilyMember member) async {
    final idx = _members.indexWhere((m) => m.id == member.id);
    if (idx >= 0) {
      _members = [..._members]..[idx] = member;
    } else {
      _members = [..._members, member];
    }
    notifyListeners();
    await _storage.saveFamily(_members);
  }

  Future<void> remove(String id) async {
    _members = _members.where((m) => m.id != id).toList();
    notifyListeners();
    await _storage.saveFamily(_members);
  }
}
