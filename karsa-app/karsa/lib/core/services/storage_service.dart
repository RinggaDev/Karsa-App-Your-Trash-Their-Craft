// lib/core/services/storage_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // In-memory fallback agar gagal baca/tulis Keystore di Android/Emulator tidak memutus alur login
  static final Map<String, String> _memoryCache = <String, String>{};

  static Future<void> _safeWrite(String key, String value) async {
    _memoryCache[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('StorageService write warning ($key): $e');
      try {
        await _storage.deleteAll();
        await _storage.write(key: key, value: value);
      } catch (_) {}
    }
  }

  static Future<String?> _safeRead(String key) async {
    try {
      final val = await _storage.read(key: key);
      if (val != null) {
        _memoryCache[key] = val;
        return val;
      }
    } catch (e) {
      debugPrint('StorageService read warning ($key): $e');
    }
    return _memoryCache[key];
  }

  // ─── Keys ────────────────────────────────────────────────────
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserKota = 'user_kota';
  static const String _keyOnboardingDone = 'onboarding_done';

  // ─── Token ──────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _safeWrite(_keyAuthToken, token);
  }

  static Future<String?> getToken() async {
    return await _safeRead(_keyAuthToken);
  }

  static Future<bool> hasToken() async {
    final token = await _safeRead(_keyAuthToken);
    return token != null && token.isNotEmpty;
  }

  // ─── User info ──────────────────────────────────────────────
  static Future<void> saveUserId(String id) async {
    await _safeWrite(_keyUserId, id);
  }

  static Future<String?> getUserId() async {
    return await _safeRead(_keyUserId);
  }

  static Future<void> saveUserName(String nama) async {
    await _safeWrite(_keyUserName, nama);
  }

  static Future<String?> getUserName() async {
    return await _safeRead(_keyUserName);
  }

  static Future<void> saveUserEmail(String email) async {
    await _safeWrite(_keyUserEmail, email);
  }

  static Future<String?> getUserEmail() async {
    return await _safeRead(_keyUserEmail);
  }

  static Future<void> saveUserKota(String kota) async {
    await _safeWrite(_keyUserKota, kota);
  }

  static Future<String?> getUserKota() async {
    return await _safeRead(_keyUserKota);
  }

  // ─── Onboarding flag ────────────────────────────────────────
  static Future<void> setOnboardingDone(bool done) async {
    await _safeWrite(_keyOnboardingDone, done.toString());
  }

  static Future<bool> isOnboardingDone() async {
    return await _safeRead(_keyOnboardingDone) == 'true';
  }

  // ─── Logout ─────────────────────────────────────────────────
  static Future<void> clearAll() async {
    _memoryCache.clear();
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('StorageService clearAll warning: $e');
    }
  }
}
