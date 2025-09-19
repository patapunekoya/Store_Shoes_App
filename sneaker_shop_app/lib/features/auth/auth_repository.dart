import 'package:dio/dio.dart';
import '../../core/api.dart';
import '../../core/storage.dart';
import '../../models/user.dart';

class AuthRepository {
  final _dio = ApiClient.dio;

  Future<User> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final token = res.data['token'] as String;
    await TokenStorage.save(token);
    final user = User.fromJson(res.data['user']);
    return user;
  }

  Future<User> register(String email, String password, {String? fullName}) async {
    final res = await _dio.post('/auth/register', data: {'email': email, 'password': password, 'fullName': fullName});
    final token = res.data['token'] as String;
    await TokenStorage.save(token);
    return User.fromJson(res.data['user']);
  }

  Future<void> logout() => TokenStorage.clear();
}
