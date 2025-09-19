import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import 'auth_repository.dart';
import 'package:dio/dio.dart';

final authRepoProvider = Provider((ref) => AuthRepository());

class AuthState {
  final User? user;
  final bool loading;
  final String? error;
  const AuthState({this.user, this.loading = false, this.error});
  AuthState copyWith({User? user, bool? loading, String? error}) =>
      AuthState(user: user ?? this.user, loading: loading ?? this.loading, error: error);
}

class ApiClient {
  static final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/api'));
  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
  static void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}


class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());
  final AuthRepository _repo;

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final u = await _repo.login(email, password);
      state = AuthState(user: u);
    } catch (e) {
      state = AuthState(user: null, error: 'Login failed: $e');
    }
  }

  Future<void> register(String email, String password, {String? fullName}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final u = await _repo.register(email, password, fullName: fullName);
      state = AuthState(user: u);
    } catch (e) {
      state = AuthState(user: null, error: 'Register failed: $e');
    }
  }

  Future<void> logout() async {
    // xóa token ở ApiClient nếu bạn set trong header
    ApiClient.clearToken();
    state = const AuthState(); // reset về chưa đăng nhập
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref.read(authRepoProvider)));
