import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/password_item.dart';
import 'storage_service.dart';

/// V1 Local persistence implementation using [SharedPreferences]
/// with support for active credentials, soft delete (Bin), and batch operations.
class LocalStorageService implements StorageService {
  static const String _storageKey = 'password_vault_items_v1';
  final SharedPreferences? _prefsInstance;

  LocalStorageService({SharedPreferences? prefs}) : _prefsInstance = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  Future<List<PasswordItem>> _getAllRawItems() async {
    try {
      final prefs = await _getPrefs();
      final rawData = prefs.getString(_storageKey);
      if (rawData == null || rawData.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(rawData) as List<dynamic>;
      final List<PasswordItem> items = [];

      for (final element in decodedList) {
        if (element is Map<String, dynamic>) {
          try {
            items.add(PasswordItem.fromJson(element));
          } catch (_) {
            // Skip individually corrupted entries
          }
        }
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveRawItems(List<PasswordItem> items) async {
    final prefs = await _getPrefs();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  @override
  Future<List<PasswordItem>> getCredentials() async {
    final all = await _getAllRawItems();
    final active = all.where((item) => !item.isDeleted).toList();
    active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active;
  }

  @override
  Future<List<PasswordItem>> getDeletedCredentials() async {
    final all = await _getAllRawItems();
    final deleted = all.where((item) => item.isDeleted).toList();
    deleted.sort((a, b) {
      final aDate = a.deletedAt ?? a.createdAt;
      final bDate = b.deletedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    return deleted;
  }

  @override
  Future<void> saveCredential(PasswordItem item) async {
    final all = await _getAllRawItems();
    final existingIndex = all.indexWhere((element) => element.id == item.id);
    if (existingIndex >= 0) {
      all[existingIndex] = item;
    } else {
      all.insert(0, item);
    }
    await _saveRawItems(all);
  }

  @override
  Future<void> moveToBin(String id) async {
    await moveToBinBatch([id]);
  }

  @override
  Future<void> moveToBinBatch(List<String> ids) async {
    final all = await _getAllRawItems();
    final idSet = ids.toSet();
    final now = DateTime.now();

    for (int i = 0; i < all.length; i++) {
      if (idSet.contains(all[i].id)) {
        all[i] = all[i].copyWith(isDeleted: true, deletedAt: now);
      }
    }
    await _saveRawItems(all);
  }

  @override
  Future<void> restoreCredential(String id) async {
    await restoreBatch([id]);
  }

  @override
  Future<void> restoreBatch(List<String> ids) async {
    final all = await _getAllRawItems();
    final idSet = ids.toSet();

    for (int i = 0; i < all.length; i++) {
      if (idSet.contains(all[i].id)) {
        all[i] = all[i].copyWith(isDeleted: false, clearDeletedAt: true);
      }
    }
    await _saveRawItems(all);
  }

  @override
  Future<void> deletePermanently(String id) async {
    final all = await _getAllRawItems();
    all.removeWhere((element) => element.id == id);
    await _saveRawItems(all);
  }

  @override
  Future<void> deleteCredential(String id) async {
    await moveToBin(id);
  }

  @override
  Future<void> emptyBin() async {
    final all = await _getAllRawItems();
    all.removeWhere((element) => element.isDeleted);
    await _saveRawItems(all);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
  }
}
