// lib/core/providers/home_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/services/dio_client.dart';

class UserStats {
  final double totalKg;
  final int totalSubmissions;
  final int totalActive;
  final int totalUmkmHelped;
  final double co2Saved;

  const UserStats({
    required this.totalKg,
    required this.totalSubmissions,
    required this.totalActive,
    required this.totalUmkmHelped,
    required this.co2Saved,
  });

  factory UserStats.fromJson(Map<String, dynamic> j) => UserStats(
        totalKg: (j['total_kg'] as num?)?.toDouble() ?? 0,
        totalSubmissions: (j['total_submissions'] as num?)?.toInt() ?? 0,
        totalActive: (j['total_submissions_active'] as num?)?.toInt() ?? 0,
        totalUmkmHelped: (j['total_umkm_helped'] as num?)?.toInt() ?? 0,
        co2Saved: (j['co2_saved'] as num?)?.toDouble() ?? 0,
      );
}

class ActiveSubmission {
  final String id;
  final List<String> tipeSampah;
  final double beratKg;
  final String status;
  final String umkmNama;

  const ActiveSubmission({
    required this.id,
    required this.tipeSampah,
    required this.beratKg,
    required this.status,
    required this.umkmNama,
  });

  factory ActiveSubmission.fromJson(Map<String, dynamic> j) => ActiveSubmission(
        id: j['id'] as String,
        tipeSampah: List<String>.from(j['tipe_sampah'] as List? ?? const []),
        beratKg: (j['berat_kg'] as num?)?.toDouble() ?? 0,
        status: j['status'] as String? ?? 'pending',
        umkmNama: (j['umkm'] as Map<String, dynamic>?)?['nama'] as String? ?? '-',
      );
}

class HomeData {
  final UserStats stats;
  final List<ActiveSubmission> active; // max 3 (PRD 8.3)

  const HomeData({required this.stats, required this.active});
}

/// Fetch stats + active submissions. Error jadi String via handleDioError.
final homeProvider = FutureProvider.autoDispose<HomeData>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final results = await Future.wait([
      dio.get(ApiUrls.userStats),
      dio.get(ApiUrls.submissionsActive),
    ]);
    final stats = UserStats.fromJson(results[0].data as Map<String, dynamic>);
    final list = (results[1].data['submissions'] as List? ?? const [])
        .map((e) => ActiveSubmission.fromJson(e as Map<String, dynamic>))
        .take(3)
        .toList();
    return HomeData(stats: stats, active: list);
  } on DioException catch (e) {
    throw handleDioError(e);
  }
});

