// lib/core/services/dio_client.dart

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/services/storage_service.dart';

// ─── Error helper (sesuai karsa-copywriting) ────────────────────
String handleDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.connectionError ||
      (e.type == DioExceptionType.unknown && e.response == null)) {
    return 'Koneksi bermasalah. Cek internet kamu dulu.';
  }

  final rawData = e.response?.data;
  final serverMessage = rawData is Map ? rawData['error']?.toString() : null;

  switch (e.response?.statusCode) {
    case 400:
      return serverMessage ?? 'Eh, ada yang kelewatan nih — cek lagi ya.';
    case 401:
      return 'Ups, email atau password-nya kurang tepat. Coba lagi ya!';
    case 404:
      return 'Data tidak ditemukan.';
    case 500:
      return serverMessage ?? 'Server lagi bermasalah. Coba lagi sebentar ya.';
    default:
      return serverMessage ?? 'Ada yang gak beres nih. Coba lagi dalam beberapa saat.';
  }
}

// ─── Auto-discovery Base URL ────────────────────────────────────
String? _resolvedBaseUrl;
Future<String?>? _resolvingFuture;

/// Mencari Base URL backend yang aktif secara paralel (Emulator `10.0.2.2`,
/// LAN Wi-Fi `172.20.3.200`, atau `localhost` / `adb reverse`) melalui `/health`.
Future<String?> _probeWorkingBaseUrl() {
  if (_resolvingFuture != null) return _resolvingFuture!;

  final completer = Completer<String?>();
  final candidates = ApiUrls.candidateBaseUrls;
  var remaining = candidates.length;

  final probeDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(milliseconds: 4000),
      receiveTimeout: const Duration(milliseconds: 4000),
    ),
  );

  for (final candidate in candidates) {
    final healthUrl = candidate.replaceFirst('/api/v1', '/health');
    probeDio.get(healthUrl).then((res) {
      if (res.statusCode == 200 && !completer.isCompleted) {
        _resolvedBaseUrl = candidate;
        completer.complete(candidate);
      } else {
        remaining--;
        if (remaining == 0 && !completer.isCompleted) {
          completer.complete(null);
        }
      }
    }).catchError((_) {
      remaining--;
      if (remaining == 0 && !completer.isCompleted) {
        completer.complete(null);
      }
    });
  }

  _resolvingFuture = completer.future.whenComplete(() {
    _resolvingFuture = null;
  });
  return _resolvingFuture!;
}

// ─── Dio factory ────────────────────────────────────────────────
Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: _resolvedBaseUrl ?? ApiUrls.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Auto-resolve baseUrl pada request pertama jika belum terhubung
        if (_resolvedBaseUrl == null) {
          final detected = await _probeWorkingBaseUrl();
          if (detected != null) {
            dio.options.baseUrl = detected;
            options.baseUrl = detected;
          }
        } else {
          options.baseUrl = _resolvedBaseUrl!;
        }

        // Inject token dari secure storage ke setiap request
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Jika koneksi putus/gagal, reset cache baseUrl agar request berikutnya re-probe
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout) {
          _resolvedBaseUrl = null;
        }

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

