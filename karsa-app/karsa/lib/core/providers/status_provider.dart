// lib/core/providers/status_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/services/dio_client.dart';

class SubmissionNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Dio _dio;

  SubmissionNotifier(this._dio) : super(const AsyncValue.loading());

  Future<void> fetchData(String id) async {
    debugPrint('🔥 Fetching data for $id...');
    try {
      final res = await _dio.get(ApiUrls.submissionById(id));
      debugPrint('✅ Data received: ${(res.data as Map<String, dynamic>?)?['status']}');
      state = AsyncValue.data(res.data as Map<String, dynamic>);
    } on DioException catch (e, st) {
      debugPrint(
        '❌ DioException: ${e.response?.statusCode} ${e.type} ${e.message}',
      );
      state = AsyncValue.error(handleDioError(e), st);
    } catch (e, st) {
      debugPrint('❌ Unexpected error: $e');
      state = AsyncValue.error(
        'Gagal memuat status. Tarik ke bawah untuk refresh.',
        st,
      );
    }
  }

  Future<void> refresh(String id) async {
    debugPrint('🔄 Refreshing...');
    state = const AsyncValue<Map<String, dynamic>>.loading()
        .copyWithPrevious(state);
    await fetchData(id);
    debugPrint('✨ Refresh done. New status: ${state.value?['status']}');
  }
}

final submissionNotifierProvider = StateNotifierProvider.family<
    SubmissionNotifier, AsyncValue<Map<String, dynamic>>, String>((ref, id) {
  final dio = ref.watch(dioProvider);
  final notifier = SubmissionNotifier(dio);
  notifier.fetchData(id);
  return notifier;
});
