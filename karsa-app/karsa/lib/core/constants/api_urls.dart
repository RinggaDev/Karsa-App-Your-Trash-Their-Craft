// lib/core/constants/api_urls.dart

class ApiUrls {
  ApiUrls._();

  // ─── Base URL ───────────────────────────────────────────────
  // Android emulator → host localhost via bridge IP
  static const String _emulatorBase = 'http://10.0.2.2:3000/api/v1';

  // Physical device → LAN IP mesin yang menjalankan Docker
  // Ganti IP ini sesuai jaringan kamu (cek dengan `ipconfig` di mesin Person 1)
  static const String physicalBase = 'http://192.168.1.10:3000/api/v1';

  // ⚠️ Ganti ke physicalBase saat test di HP fisik
  static const String baseUrl = _emulatorBase;

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

