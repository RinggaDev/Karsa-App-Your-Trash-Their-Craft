// lib/core/providers/pengantaran_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/providers/home_provider.dart';
import 'package:karsa/core/services/dio_client.dart';

/// GET /submissions/active (tanpa limit). Error dilempar sebagai String.
final pengantaranProvider =
    FutureProvider.autoDispose<List<ActiveSubmission>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get(ApiUrls.submissionsActive);
    return (res.data['submissions'] as List? ?? const [])
        .map((e) => ActiveSubmission.fromJson(e as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw handleDioError(e);
  }
});

