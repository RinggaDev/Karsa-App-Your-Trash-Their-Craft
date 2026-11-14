// lib/core/providers/summary_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/providers/status_provider.dart';
import 'package:karsa/core/services/dio_client.dart';

const kInsightFallback = 'Insight lagi diproses. Cek lagi sebentar ya!';

/// POST /insight/micro. Menggunakan validateStatus agar status 4xx/5xx tidak
/// melempar DioException yang menghentikan debugger (SIGQUIT / signal 3).
class SummaryNotifier extends StateNotifier<AsyncValue<String>> {
  final Dio _dio;
  final Ref _ref;

  SummaryNotifier(this._dio, this._ref) : super(const AsyncValue.loading());

  String _buildLocalInsight(String submissionId) {
    final sub = _ref.read(submissionNotifierProvider(submissionId)).valueOrNull;
    final berat = (sub?['berat_kg'] as num?)?.toDouble() ?? 1.0;
    final co2 = (berat * 1.5).toStringAsFixed(1);
    final rawTipe = sub?['tipe_sampah'];
    final tipeList = rawTipe is List && rawTipe.isNotEmpty
        ? rawTipe.join(', ')
        : 'sampah terpilah';
    final umkm = sub?['umkm'] is Map<String, dynamic>
        ? sub!['umkm'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final umkmNama = (umkm['nama'] as String?)?.isNotEmpty == true
        ? umkm['nama'] as String
        : 'mitra UMKM lokal';
    final produk = (umkm['produk_dibuat'] as String?)?.isNotEmpty == true
        ? umkm['produk_dibuat'] as String
        : 'karya baru yang bermanfaat';

    return 'Keren banget! ${berat.toStringAsFixed(1)} kg $tipeList dari kamu udah sampai di $umkmNama untuk diolah jadi $produk. Langkahmu barusan ikut memangkas sekitar $co2 kg emisi CO₂ dari bumi—yuk terus jaga semangat baik ini!';
  }

  Future<void> fetchInsight(String submissionId) async {
    try {
      final res = await _dio.post(
        ApiUrls.insightMicro,
        data: {'submission_id': submissionId},
        options: Options(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
          // Jangan lempar DioException untuk HTTP 4xx/5xx agar debugger tidak freeze
          validateStatus: (_) => true,
        ),
      );

      if (!mounted) return;

      final data = res.data;
      final insight = (res.statusCode == 200 && data is Map<String, dynamic>)
          ? (data['insight'] as String?)?.trim()
          : null;

      if (insight != null && insight.isNotEmpty) {
        state = AsyncValue.data(insight);
      } else {
        state = AsyncValue.data(_buildLocalInsight(submissionId));
      }
    } catch (_) {
      if (!mounted) return;
      state = AsyncValue.data(_buildLocalInsight(submissionId));
    }
  }

  Future<void> refresh(String submissionId) async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    await fetchInsight(submissionId);
  }
}

final summaryProvider = StateNotifierProvider.autoDispose
    .family<SummaryNotifier, AsyncValue<String>, String>((ref, id) {
  final notifier = SummaryNotifier(ref.watch(dioProvider), ref);
  notifier.fetchInsight(id);
  return notifier;
});

