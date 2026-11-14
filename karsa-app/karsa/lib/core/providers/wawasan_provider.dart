// lib/core/providers/wawasan_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/providers/home_provider.dart';
import 'package:karsa/core/services/dio_client.dart';

const kMacroFallback = 'Wawasan lagi diproses. Cek lagi sebentar ya!';
const kMacroEmpty =
    'Selesaikan distribusi pertamamu buat dapetin insight personal!';

class MacroInsightData {
  final UserStats stats;
  final String? insight;
  final String periode;
  final String? generatedAt;
  final bool isEmpty; // true jika belum ada submission done (404)
  final bool hasInsightError; // true jika fetch AI gagal/timeout

  const MacroInsightData({
    required this.stats,
    this.insight,
    this.periode = 'weekly',
    this.generatedAt,
    this.isEmpty = false,
    this.hasInsightError = false,
  });
}

class WawasanNotifier extends StateNotifier<AsyncValue<MacroInsightData>> {
  final Dio _dio;

  WawasanNotifier(this._dio) : super(const AsyncValue.loading());

  Future<UserStats> _fetchStatsSafe() async {
    try {
      final res = await _dio.get(
        ApiUrls.userStats,
        options: Options(validateStatus: (_) => true),
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return UserStats.fromJson(res.data as Map<String, dynamic>);
      }
      return const UserStats(
        totalKg: 0,
        totalSubmissions: 0,
        totalActive: 0,
        totalUmkmHelped: 0,
        co2Saved: 0,
      );
    } catch (_) {
      return const UserStats(
        totalKg: 0,
        totalSubmissions: 0,
        totalActive: 0,
        totalUmkmHelped: 0,
        co2Saved: 0,
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchMacroSafe(String periode) async {
    try {
      final res = await _dio.get(
        ApiUrls.insightMacro,
        queryParameters: {'periode': periode},
        options: Options(
          receiveTimeout: const Duration(seconds: 12),
          validateStatus: (_) => true,
        ),
      );
      if (res.statusCode == 404) {
        return const {'_empty': true};
      }
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Parallel fetch: GET /users/stats dan GET /insight/macro?periode=weekly bersamaan.
  Future<void> fetchMacro({String periode = 'weekly'}) async {
    try {
      final results = await Future.wait([
        _fetchStatsSafe(),
        _fetchMacroSafe(periode),
      ]);

      final stats = results[0] as UserStats;
      final macroRaw = results[1] as Map<String, dynamic>?;

      if (macroRaw == null) {
        state = AsyncValue.data(
          MacroInsightData(
            stats: stats,
            periode: periode,
            hasInsightError: true,
          ),
        );
        return;
      }

      if (macroRaw['_empty'] == true) {
        state = AsyncValue.data(
          MacroInsightData(
            stats: stats,
            periode: periode,
            isEmpty: true,
          ),
        );
        return;
      }

      final text = (macroRaw['insight'] as String?)?.trim();
      if (text == null || text.isEmpty) {
        state = AsyncValue.data(
          MacroInsightData(
            stats: stats,
            periode: periode,
            hasInsightError: true,
          ),
        );
        return;
      }

      state = AsyncValue.data(
        MacroInsightData(
          stats: stats,
          insight: text,
          periode: (macroRaw['periode'] as String?) ?? periode,
          generatedAt: macroRaw['generated_at'] as String?,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(kMacroFallback, st);
    }
  }

  Future<void> refresh({String periode = 'weekly'}) async {
    state = const AsyncValue.loading();
    await fetchMacro(periode: periode);
  }
}

final wawasanProvider =
    StateNotifierProvider<WawasanNotifier, AsyncValue<MacroInsightData>>((ref) {
  final notifier = WawasanNotifier(ref.watch(dioProvider));
  notifier.fetchMacro();
  return notifier;
});
