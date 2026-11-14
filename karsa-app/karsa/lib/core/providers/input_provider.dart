// lib/core/providers/input_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/services/dio_client.dart';

/// Nilai tipe sampah sesuai CHECK constraint DB.
const kTipeSampah = <String, String>{
  'plastik': 'Plastik',
  'kayu': 'Kayu',
  'kain': 'Kain',
  'kertas': 'Kertas',
  'logam': 'Logam',
  'lainnya': 'Lainnya',
};

const kKondisiBersih = 'bersih';
const kKondisiKotor = 'belum_dibersihkan';

const kUploadFailedMessage = 'Foto gagal diupload. Coba lagi atau skip dulu.';

class InputState {
  final Set<String> tipeSampah;
  final String? fotoPath; // path lokal untuk preview
  final String? fotoUrl; // hasil upload; null = belum / skip
  final bool isUploading;
  final String? uploadError;
  final double? beratKg;
  final String? kondisi;
  final String pickupPoint;
  final DateTime? tanggalPickup;
  final String catatan;

  const InputState({
    this.tipeSampah = const {},
    this.fotoPath,
    this.fotoUrl,
    this.isUploading = false,
    this.uploadError,
    this.beratKg,
    this.kondisi,
    this.pickupPoint = '',
    this.tanggalPickup,
    this.catatan = '',
  });

  /// Semua field wajib terisi. Foto opsional (fallback jika upload gagal).
  bool get isValid =>
      tipeSampah.isNotEmpty &&
      (beratKg ?? 0) > 0 &&
      kondisi != null &&
      pickupPoint.trim().isNotEmpty &&
      tanggalPickup != null &&
      !isUploading;

  /// Query untuk GET /umkm?tipe_sampah=
  String get tipeSampahQuery => tipeSampah.join(',');

  /// Payload POST /submissions (tanpa umkm_id).
  Map<String, dynamic> toPayload() {
    final d = tanggalPickup!;
    final tanggal =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return {
      'tipe_sampah': tipeSampah.toList(),
      'foto_url': fotoUrl,
      'berat_kg': beratKg,
      'kondisi': kondisi,
      'pickup_point': pickupPoint.trim(),
      'tanggal_pickup': tanggal,
      'catatan': catatan.trim().isEmpty ? null : catatan.trim(),
    };
  }

  InputState copyWith({
    Set<String>? tipeSampah,
    String? fotoPath,
    String? fotoUrl,
    bool? isUploading,
    String? uploadError,
    double? beratKg,
    bool clearBerat = false,
    String? kondisi,
    String? pickupPoint,
    DateTime? tanggalPickup,
    String? catatan,
    bool clearFoto = false,
  }) {
    return InputState(
      tipeSampah: tipeSampah ?? this.tipeSampah,
      fotoPath: clearFoto ? null : (fotoPath ?? this.fotoPath),
      fotoUrl: clearFoto ? null : (fotoUrl ?? this.fotoUrl),
      isUploading: isUploading ?? this.isUploading,
      uploadError: uploadError, // selalu di-reset kecuali diisi eksplisit
      beratKg: clearBerat ? null : (beratKg ?? this.beratKg),
      kondisi: kondisi ?? this.kondisi,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      tanggalPickup: tanggalPickup ?? this.tanggalPickup,
      catatan: catatan ?? this.catatan,
    );
  }
}

class InputNotifier extends StateNotifier<InputState> {
  final Dio _dio;
  final ImagePicker _picker = ImagePicker();

  InputNotifier(this._dio) : super(const InputState());

  void toggleTipe(String tipe) {
    final next = {...state.tipeSampah};
    if (!next.remove(tipe)) next.add(tipe);
    state = state.copyWith(tipeSampah: next);
  }

  void setBerat(String raw) {
    final v = double.tryParse(raw.trim().replaceAll(',', '.'));
    if (v == null) {
      state = state.copyWith(clearBerat: true);
    } else {
      state = state.copyWith(beratKg: v);
    }
  }

  void setKondisi(String kondisi) => state = state.copyWith(kondisi: kondisi);
  void setPickupPoint(String v) => state = state.copyWith(pickupPoint: v);
  void setTanggal(DateTime d) => state = state.copyWith(tanggalPickup: d);
  void setCatatan(String v) => state = state.copyWith(catatan: v);

  void removeFoto() => state = state.copyWith(clearFoto: true);

  /// Pilih foto, lalu upload ke POST /upload/photo.
  /// Gagal upload: foto_url tetap null, user boleh lanjut tanpa foto.
  /// Return true jika upload sukses.
  Future<bool> pickAndUpload(ImageSource source) async {
    XFile? image;
    try {
      image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
      );
    } catch (_) {
      state = state.copyWith(uploadError: kUploadFailedMessage);
      return false;
    }
    if (image == null) return false; // user batal

    state = state.copyWith(
      fotoPath: image.path,
      isUploading: true,
      uploadError: null,
    );

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: image.name),
      });
      final res = await _dio.post(
        ApiUrls.uploadPhoto,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final url = (res.data as Map<String, dynamic>)['foto_url'] as String?;
      state = state.copyWith(isUploading: false, fotoUrl: url);
      return url != null;
    } on DioException catch (_) {
      state = state.copyWith(
        isUploading: false,
        clearFoto: true,
        uploadError: kUploadFailedMessage,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isUploading: false,
        clearFoto: true,
        uploadError: kUploadFailedMessage,
      );
      return false;
    }
  }

  void reset() => state = const InputState();
}

/// Tidak autoDispose: form harus bertahan ke UMKM list & konfirmasi.
final inputProvider = StateNotifierProvider<InputNotifier, InputState>((ref) {
  return InputNotifier(ref.watch(dioProvider));
});

