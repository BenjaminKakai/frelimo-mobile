import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/models/user_model.dart';
import '../data/auth_model.dart';

final secureStorageProvider = Provider((ref) => SecureStorage());

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool isInitializing;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.isInitializing = true,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? isInitializing,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isInitializing: isInitializing ?? this.isInitializing,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorage _storage;
  final ApiClient _api;

  AuthNotifier(this._storage, this._api) : super(const AuthState()) {
    _api.onSessionExpired =
        () => state = const AuthState(isInitializing: false);
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    try {
      final hasToken = await _storage.hasToken();
      if (!hasToken) {
        state = state.copyWith(isInitializing: false);
        return;
      }
      final userData = await _storage.getUser();
      if (userData != null) {
        state = state.copyWith(
          user: UserModel.fromJson(userData),
          isAuthenticated: true,
          isInitializing: false,
        );
        // Background refresh — the cached user gives instant boot, then the
        // fresh profile overwrites once the network responds. Silent on
        // failure so offline launches still show the digital card.
        _refreshProfile();
      } else {
        // Token present but no cached user — call /profile/me to populate.
        await refreshProfile();
        state = state.copyWith(isInitializing: false);
      }
    } catch (_) {
      state = state.copyWith(isInitializing: false);
    }
  }

  Future<void> _refreshProfile() async {
    try {
      await refreshProfile();
    } catch (_) { /* keep cached */ }
  }

  /// Calls `/profile/me` and writes the result to both secure storage (full)
  /// and the profile cache (for offline card render).
  Future<UserModel?> refreshProfile() async {
    try {
      final res = await _api.get('/profile/me');
      final body = res.data;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      if (data is Map<String, dynamic>) {
        final fresh = UserModel.fromJson(data);
        await _storage.saveUser(fresh.toJson());
        await _storage.saveProfileCache(data);
        if (mounted) {
          state = state.copyWith(user: fresh, isAuthenticated: true);
        }
        return fresh;
      }
    } catch (_) { /* swallow */ }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.post('/auth/login',
          data: LoginRequest(email: email, password: password).toJson());
      final envelope = res.data as Map<String, dynamic>;
      final auth =
          AuthResponse.fromJson(envelope['data'] as Map<String, dynamic>);
      await _storage.saveAccessToken(auth.accessToken);
      if (auth.refreshToken != null) {
        await _storage.saveRefreshToken(auth.refreshToken!);
      }
      await _storage.saveUser(auth.user.toJson());
      state = state.copyWith(
        user: auth.user,
        isAuthenticated: true,
        isLoading: false,
      );
      // Pull the canonical profile so the role flags (isAdmin / isMember)
      // are guaranteed fresh — login response may not include all of them.
      await refreshProfile();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await _api.post('/auth/forgot-password', data: {'email': email});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState(isInitializing: false);
  }

  void updateUser(UserModel user) {
    _storage.saveUser(user.toJson());
    state = state.copyWith(user: user);
  }

  String _parseError(dynamic e) {
    try {
      final data = (e as dynamic).response?.data;
      if (data is Map) {
        final err = data['error'];
        if (err is Map) {
          final m = err['message']?.toString();
          if (m != null && m.isNotEmpty) return m;
        }
        final flat = data['message']?.toString();
        if (flat != null && flat.isNotEmpty) return flat;
      }
    } catch (_) {}
    try {
      final m = (e as dynamic).message?.toString();
      if (m != null && m.isNotEmpty && m != 'null') return m;
    } catch (_) {}
    return 'Erro de autenticação';
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final api = ref.watch(apiClientProvider);
  return AuthNotifier(storage, api);
});
