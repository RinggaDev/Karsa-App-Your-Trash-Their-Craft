// lib/core/providers/auth_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/api_urls.dart';
import 'package:karsa/core/services/dio_client.dart';
import 'package:karsa/core/services/storage_service.dart';

// ─── User Model ─────────────────────────────────────────────────
class UserModel {
  final String id;
  final String email;
  final String nama;
  final String kota;

  const UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.kota,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      nama: (json['nama'] as String?) ?? '',
      kota: (json['kota'] as String?) ?? '',
    );
  }
}

// ─── Auth State ─────────────────────────────────────────────────
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? welcomeMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.welcomeMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? welcomeMessage,
    bool clearWelcomeMessage = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      welcomeMessage: clearWelcomeMessage
          ? null
          : (welcomeMessage ?? this.welcomeMessage),
    );
  }
}

// ─── Auth Notifier ──────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;

  AuthNotifier(this._dio) : super(const AuthState());

  /// Cek token saat app startup
  Future<bool> checkAuthStatus() async {
    final hasToken = await StorageService.hasToken();
    if (!hasToken) {
      state = const AuthState(isAuthenticated: false);
      return false;
    }

    // Token ada — restore user info dari storage
    final userId = await StorageService.getUserId();
    final userName = await StorageService.getUserName();
    final userEmail = await StorageService.getUserEmail();
    final userKota = await StorageService.getUserKota();

    if (userId != null) {
      state = AuthState(
        isAuthenticated: true,
        welcomeMessage: 'Selamat datang kembali! Impact-mu menanti.',
        user: UserModel(
          id: userId,
          email: userEmail ?? '',
          nama: userName ?? '',
          kota: userKota ?? '',
        ),
      );
      // Jika email atau kota belum tersimpan di storage lokal, sinkronkan dari backend
      if ((userEmail == null || userEmail.isEmpty) ||
          (userKota == null || userKota.isEmpty)) {
        fetchProfile();
      }
      return true;
    }

    return false;
  }

  /// Sinkronisasi profil user dari GET /users/profile
  Future<void> fetchProfile() async {
    try {
      final response = await _dio.get(ApiUrls.userProfile);
      final data = response.data as Map<String, dynamic>;
      final rawUser = (data['user'] as Map<String, dynamic>?) ?? data;
      final old = state.user;
      final updated = UserModel(
        id: (rawUser['id'] as String?) ?? old?.id ?? '',
        email: (rawUser['email'] as String?) ?? old?.email ?? '',
        nama: (rawUser['nama'] as String?) ?? old?.nama ?? '',
        kota: (rawUser['kota'] as String?) ?? old?.kota ?? '',
      );
      await StorageService.saveUserName(updated.nama);
      await StorageService.saveUserEmail(updated.email);
      await StorageService.saveUserKota(updated.kota);
      state = state.copyWith(user: updated);
    } catch (_) {
      // Abaikan jika gagal koneksi saat background sync
    }
  }

  /// Login dengan email & password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.post(
        ApiUrls.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      // Simpan ke secure storage
      await StorageService.saveToken(token);
      await StorageService.saveUserId(user.id);
      await StorageService.saveUserName(user.nama);
      await StorageService.saveUserEmail(user.email);
      await StorageService.saveUserKota(user.kota);
      // User lama yang login sudah lewat onboarding
      await StorageService.setOnboardingDone(true);

      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
        welcomeMessage:
            'Berhasil login kembali! Apa yang mau kamu angkut hari ini?',
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: handleDioError(e),
        isAuthenticated: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ada yang gak beres nih. Coba lagi ya!',
        isAuthenticated: false,
      );
      return false;
    }
  }

  /// Register user baru (email, password, nama, kota)
  Future<bool> register({
    required String email,
    required String password,
    required String nama,
    required String kota,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.post(
        ApiUrls.register,
        data: {
          'email': email,
          'password': password,
          'nama': nama,
          'kota': kota,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      // Simpan ke secure storage
      await StorageService.saveToken(token);
      await StorageService.saveUserId(user.id);
      await StorageService.saveUserName(user.nama);
      await StorageService.saveUserEmail(user.email);
      await StorageService.saveUserKota(user.kota);
      await StorageService.setOnboardingDone(true);

      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
        welcomeMessage: 'Akun berhasil dibuat! Yuk mulai angkut.',
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: handleDioError(e),
        isAuthenticated: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ada yang gak beres nih. Coba lagi ya!',
        isAuthenticated: false,
      );
      return false;
    }
  }

  /// Simpan nama & kota dari onboarding / profil (PUT /users/profile)
  Future<bool> updateProfile({
    required String nama,
    required String kota,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.put(
        ApiUrls.userProfile,
        data: {'nama': nama, 'kota': kota},
      );
      final data = response.data as Map<String, dynamic>;
      final old = state.user;
      final user = UserModel(
        id: data['id'] as String? ?? old?.id ?? '',
        email: old?.email ?? '',
        nama: data['nama'] as String? ?? nama,
        kota: data['kota'] as String? ?? kota,
      );
      await StorageService.saveUserName(user.nama);
      await StorageService.saveUserKota(user.kota);
      await StorageService.setOnboardingDone(true);
      state = state.copyWith(isLoading: false, user: user, error: null);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: handleDioError(e));
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ada yang gak beres nih. Coba lagi ya!',
      );
      return false;
    }
  }

  /// Bersihkan welcome message setelah snackbar ditampilkan di HomeScreen
  void clearWelcomeMessage() {
    if (state.welcomeMessage != null) {
      state = state.copyWith(clearWelcomeMessage: true);
    }
  }

  /// Logout — hapus semua data lokal
  Future<void> logout() async {
    await StorageService.clearAll();
    state = const AuthState(isAuthenticated: false);
  }
}

// ─── Providers ──────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthNotifier(dio);
});

// Convenience provider — akses user langsung
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

// Convenience provider — cek apakah sedang loading auth
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});
