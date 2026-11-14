// lib/core/services/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ─── Keys ────────────────────────────────────────────────────
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserKota = 'user_kota';
  static const String _keyOnboardingDone = 'onboarding_done';

  // ─── Token ──────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _keyAuthToken);
    return token != null && token.isNotEmpty;
  }

  // ─── User info ──────────────────────────────────────────────
  static Future<void> saveUserId(String id) async {
    await _storage.write(key: _keyUserId, value: id);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  static Future<void> saveUserName(String nama) async {
    await _storage.write(key: _keyUserName, value: nama);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  static Future<void> saveUserKota(String kota) async {
    await _storage.write(key: _keyUserKota, value: kota);
  }

  static Future<String?> getUserKota() async {
    return await _storage.read(key: _keyUserKota);
  }

  // ─── Onboarding flag ────────────────────────────────────────
  static Future<void> setOnboardingDone(bool done) async {
    await _storage.write(key: _keyOnboardingDone, value: done.toString());
  }

  static Future<bool> isOnboardingDone() async {
    return await _storage.read(key: _keyOnboardingDone) == 'true';
  }

  // ─── Logout ─────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
