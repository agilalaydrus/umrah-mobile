import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// [FIX] Absolute Imports: No more "../../" guessing games
import 'package:umrah_app/core/network/api_client.dart';
import 'package:umrah_app/features/home/data/auth_repository.dart';

// 1. Core Providers
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});

// 2. Auth State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? role;
  final String? userId; // <--- NEW FIELD
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role,
    this.userId, // <--- NEW
    this.error,
  });

  AuthState copyWith({
    bool? isLoading, 
    bool? isAuthenticated, 
    String? role, 
    String? userId, // <--- NEW
    String? error
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      userId: userId ?? this.userId, // <--- NEW
      error: error ?? this.error,
    );
  }
}

// 3. Auth Notifier (Modern Riverpod 2.0)
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    checkSession(); // Fire and forget check on startup
    return AuthState(); // Initial state
  }

  Future<void> checkSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'token');
    
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);
      final id = decoded['user_id'] ?? decoded['sub'] ?? decoded['id']; 

      state = AuthState(
        isAuthenticated: true, 
        role: decoded['role'],
        userId: id.toString(), // <--- STORE IT
      );
    } else {
      state = AuthState(isAuthenticated: false);
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(phone: phone, password: password);
      await checkSession();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = AuthState(isAuthenticated: false);
  }
}

// 4. The Final Provider
final authControllerProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);