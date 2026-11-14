// lib/core/providers/summary_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/services/dio_client.dart';

const kInsightFallback = 'Insight lagi diproses. Cek lagi sebentar ya!';

/// POST /insight/micro. Semua error jadi pesan fallback ramah.
class SummaryNotifier extends StateNotifier<AsyncValue<String>> {
  final Dio _dio;

  SummaryNotifier(this._dio) : super(const AsyncValue.loading());

  Future<void> fetchInsight(String submissionId) async {
    try {
      final res = await _dio.post(
        ApiUrls.insightMicro,
        data: {'submission_id': submissionId},
        // Gemini bisa lambat, longgarkan timeout baca
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );
      final insight = (res.data as Map<String, dynamic>)['insight'] as String?;
      if (insight == null || insight.trim().isEmpty) {
        state = AsyncValue.error(kInsightFallback, StackTrace.current);
      } else {
        state = AsyncValue.data(insight.trim());
      }
    } on DioException catch (_) {
      state = AsyncValue.error(kInsightFallback, StackTrace.current);
    } catch (_) {
      state = AsyncValue.error(kInsightFallback, StackTrace.current);
    }
  }

  Future<void> refresh(String submissionId) async {
    state = const AsyncValue.loading();
    await fetchInsight(submissionId);
  }
}

final summaryProvider = StateNotifierProvider.autoDispose
    .family<SummaryNotifier, AsyncValue<String>, String>((ref, id) {
  final notifier = SummaryNotifier(ref.watch(dioProvider));
  notifier.fetchInsight(id);
  return notifier;
});

