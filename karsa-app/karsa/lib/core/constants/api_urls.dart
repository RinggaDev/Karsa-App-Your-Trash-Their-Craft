// lib/core/constants/api_urls.dart

import 'package:flutter/foundation.dart';

class ApiUrls {
  ApiUrls._();

  // ─── Base URL ───────────────────────────────────────────────
  // Android emulator → host localhost via bridge IP
  static const String emulatorBase = 'http://10.0.2.2:3000/api/v1';

  // Physical device → LAN IP mesin yang menjalankan backend (`ipconfig` Wi-Fi)
  static const String physicalBase = 'http://172.20.3.200:3000/api/v1';

  // Web / Desktop / iOS Simulator / Android USB (`adb reverse tcp:3000 tcp:3000`)
  static const String localhostBase = 'http://localhost:3000/api/v1';
  static const String loopbackBase = 'http://127.0.0.1:3000/api/v1';

  // Default Base URL berdasarkan platform
  static String get baseUrl {
    if (kIsWeb) return localhostBase;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return emulatorBase;
    }
    return localhostBase;
  }

  // Kandidat URL untuk auto-discovery / fallback di DioClient
  static List<String> get candidateBaseUrls {
    if (kIsWeb) {
      return const [localhostBase, loopbackBase, physicalBase];
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const [
        emulatorBase,
        physicalBase,
        localhostBase,
        loopbackBase,
      ];
    }
    return const [localhostBase, loopbackBase, physicalBase];
  }

  // ─── Auth ────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // ─── Users / Stats ──────────────────────────────────────────
  static const String userProfile = '/users/profile';
  static const String userStats = '/users/stats';

  // ─── Submissions ────────────────────────────────────────────
  static const String submissions = '/submissions';
  static const String submissionsActive = '/submissions/active';

  // Helper: GET /submissions/:id
  static String submissionById(String id) => '/submissions/$id';

  // ─── UMKM ───────────────────────────────────────────────────
  static const String umkm = '/umkm';

  // Helper: GET /umkm/:id
  static String umkmById(String id) => '/umkm/$id';

  // ─── Recap ──────────────────────────────────────────────────
  static const String recap = '/recap';

  // ─── Insight ────────────────────────────────────────────────
  static const String insightMicro = '/insight/micro';
  static const String insightMacro = '/insight/macro';

  // ─── Upload ─────────────────────────────────────────────────
  static const String uploadPhoto = '/upload/photo';
}

