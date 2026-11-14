// lib/core/services/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/services/storage_service.dart';

// ─── Error helper (sesuai karsa-copywriting) ────────────────────
String handleDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return 'Koneksi bermasalah. Cek internet kamu dulu.';
  }

  if (e.type == DioExceptionType.connectionError) {
    return 'Koneksi bermasalah. Cek internet kamu dulu.';
  }

  switch (e.response?.statusCode) {
    case 400:
      return e.response?.data?['error'] ?? 'Eh, ada yang kelewatan nih — cek lagi ya.';
    case 401:
      return 'Ups, email atau password-nya kurang tepat. Coba lagi ya!';
    case 404:
      return 'Data tidak ditemukan.';
    case 500:
      return 'Server lagi bermasalah. Coba lagi sebentar ya.';
    default:
      return 'Ada yang gak beres nih. Coba lagi dalam beberapa saat.';
  }
}

// ─── Dio factory ────────────────────────────────────────────────
Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiUrls.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Inject token dari secure storage ke setiap request
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Auto-logout jika 401
        if (error.response?.statusCode == 401) {
          await StorageService.clearAll();
          // Note: navigasi ke login akan dihandle oleh auth-aware routing di main.dart
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}

// ─── Riverpod provider ──────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) => _createDio());

