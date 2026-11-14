// lib/core/providers/riwayat_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/services/dio_client.dart';

class RecapStats {
  final double totalKg;
  final int totalSubmissions;
  final int totalSubmissionsDone;
  final int totalUmkmHelped;
  final double co2Saved;

  const RecapStats({
    required this.totalKg,
    required this.totalSubmissions,
    required this.totalSubmissionsDone,
    required this.totalUmkmHelped,
    required this.co2Saved,
  });

  factory RecapStats.fromJson(Map<String, dynamic> j) => RecapStats(
        totalKg: (j['total_kg'] as num?)?.toDouble() ?? 0,
        totalSubmissions: (j['total_submissions'] as num?)?.toInt() ?? 0,
        totalSubmissionsDone: (j['total_submissions_done'] as num?)?.toInt() ?? 0,
        totalUmkmHelped: (j['total_umkm_helped'] as num?)?.toInt() ?? 0,
        co2Saved: (j['co2_saved'] as num?)?.toDouble() ?? 0,
      );
}

class RecapSubmission {
  final String id;
  final List<String> tipeSampah;
  final double beratKg;
  final String status;
  final String umkmNama;
  final String tanggal;

  const RecapSubmission({
    required this.id,
    required this.tipeSampah,
    required this.beratKg,
    required this.status,
    required this.umkmNama,
    required this.tanggal,
  });

  factory RecapSubmission.fromJson(Map<String, dynamic> j) {
    final rawDate =
        (j['tanggal_pickup'] ?? j['created_at'])?.toString() ?? '';
    return RecapSubmission(
      id: j['id'] as String,
      tipeSampah: List<String>.from(j['tipe_sampah'] as List? ?? const []),
      beratKg: (j['berat_kg'] as num?)?.toDouble() ?? 0,
      status: j['status'] as String? ?? 'pending',
      umkmNama:
          (j['umkm'] as Map<String, dynamic>?)?['nama'] as String? ?? '-',
      tanggal: rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate,
    );
  }

  bool get isDone => status == 'done';
  bool get isActive => !isDone;
}

class RecapData {
  final RecapStats stats;
  final List<RecapSubmission> submissions;

  const RecapData({required this.stats, required this.submissions});

  factory RecapData.fromJson(Map<String, dynamic> j) => RecapData(
        stats: RecapStats.fromJson(
          (j['stats'] as Map<String, dynamic>?) ?? const {},
        ),
        submissions: (j['submissions'] as List? ?? const [])
            .map((e) => RecapSubmission.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class RiwayatNotifier extends StateNotifier<AsyncValue<RecapData>> {
  final Dio _dio;

  RiwayatNotifier(this._dio) : super(const AsyncValue.loading());

  Future<void> fetchRecap() async {
    try {
      final res = await _dio.get(ApiUrls.recap);
      state = AsyncValue.data(
        RecapData.fromJson(res.data as Map<String, dynamic>),
      );
    } on DioException catch (e, st) {
      state = AsyncValue.error(handleDioError(e), st);
    } catch (_, st) {
      state = AsyncValue.error(
        'Gagal memuat data. Tarik ke bawah untuk refresh.',
        st,
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await fetchRecap();
  }
}

final riwayatProvider =
    StateNotifierProvider<RiwayatNotifier, AsyncValue<RecapData>>((ref) {
  final notifier = RiwayatNotifier(ref.watch(dioProvider));
  notifier.fetchRecap();
  return notifier;
});

