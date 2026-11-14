// lib/core/providers/umkm_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/providers/input_provider.dart';
import 'package:karsa/core/services/dio_client.dart';

class Umkm {
  final String id;
  final String nama;
  final String? deskripsi;
  final String lokasi;
  final List<String> bahanBaku;
  final String? produkDibuat;
  final String? kontak;
  final String? gambarUrl;

  const Umkm({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.bahanBaku,
    this.deskripsi,
    this.produkDibuat,
    this.kontak,
    this.gambarUrl,
  });

  factory Umkm.fromJson(Map<String, dynamic> j) => Umkm(
        id: j['id'] as String,
        nama: j['nama'] as String? ?? '-',
        deskripsi: j['deskripsi'] as String?,
        lokasi: j['lokasi'] as String? ?? '-',
        bahanBaku: List<String>.from(j['bahan_baku'] as List? ?? const []),
        produkDibuat: j['produk_dibuat'] as String?,
        kontak: j['kontak'] as String?,
        gambarUrl: j['gambar_url'] as String?,
      );
}

/// GET /umkm?tipe_sampah=plastik,kertas. Error dilempar sebagai String.
final umkmListProvider =
    FutureProvider.autoDispose.family<List<Umkm>, String>((ref, tipe) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get(
      ApiUrls.umkm,
      queryParameters: {'tipe_sampah': tipe},
    );
    return (res.data['umkm'] as List? ?? const [])
        .map((e) => Umkm.fromJson(e as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw handleDioError(e);
  }
});

/// GET /umkm/:id
final umkmDetailProvider =
    FutureProvider.autoDispose.family<Umkm, String>((ref, id) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get(ApiUrls.umkmById(id));
    return Umkm.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw handleDioError(e);
  }
});

// ─── Submit (POST /submissions) ─────────────────────────────────
class SubmitState {
  final bool isLoading;
  final String? error;
  const SubmitState({this.isLoading = false, this.error});
}

class SubmitNotifier extends StateNotifier<SubmitState> {
  final Dio _dio;
  final Ref _ref;
  SubmitNotifier(this._dio, this._ref) : super(const SubmitState());

  /// Return id submission jika sukses (201), null jika gagal.
  Future<String?> submit(String umkmId) async {
    state = const SubmitState(isLoading: true);
    try {
      final payload = {
        ..._ref.read(inputProvider).toPayload(),
        'umkm_id': umkmId,
      };
      final res = await _dio.post(ApiUrls.submissions, data: payload);
      final id = (res.data as Map<String, dynamic>)['id'] as String;
      _ref.read(inputProvider.notifier).reset();
      state = const SubmitState();
      return id;
    } on DioException catch (e) {
      state = SubmitState(error: handleDioError(e));
      return null;
    } catch (_) {
      state = const SubmitState(
        error: 'Ada yang gak beres nih. Coba lagi dalam beberapa saat.',
      );
      return null;
    }
  }

  void clearError() => state = const SubmitState();
}

final submitProvider =
    StateNotifierProvider.autoDispose<SubmitNotifier, SubmitState>((ref) {
  return SubmitNotifier(ref.watch(dioProvider), ref);
});

