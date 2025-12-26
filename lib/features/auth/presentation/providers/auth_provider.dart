import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// [FIX] Absolute Imports
import 'package:umrah_app/core/network/api_client.dart';
// Note: Double check if your repo is in 'home' or 'auth'. Standard is 'auth'.
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
  final String? userId; 
  final String? groupId;
  final String? error;
  final String? phoneNumber; // Used for Chat "isMe" check

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role,
    this.userId,
    this.groupId,
    this.error,
    this.phoneNumber,
  });

  AuthState copyWith({
    bool? isLoading, 
    bool? isAuthenticated, 
    String? role, 
    String? userId, 
    String? groupId, 
    String? error,
    String? phoneNumber, // <--- [FIX] Added parameter
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      error: error ?? this.error,
      phoneNumber: phoneNumber ?? this.phoneNumber, // <--- [FIX] Added assignment
    );
  }
}

// 3. Auth Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    checkSession(); 
    return AuthState(); 
  }

  Future<void> checkSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'token');
    
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);
      
      final id = decoded['user_id'] ?? decoded['sub'] ?? decoded['id']; 
      final gId = decoded['group_id']; 
      final phone = decoded['phone_number']; // <--- [FIX] Extract phone

      state = AuthState(
        isAuthenticated: true, 
        role: decoded['role'],
        userId: id.toString(),
        groupId: gId?.toString(),
        phoneNumber: phone?.toString(), // <--- [FIX] Store phone
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