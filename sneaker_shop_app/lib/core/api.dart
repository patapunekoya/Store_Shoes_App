import 'package:dio/dio.dart';
import 'config.dart';
import 'storage.dart';

class ApiClient {
  ApiClient._();
  static final Dio dio = Dio(BaseOptions(
    baseUrl: '${AppConfig.baseUrl}/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.get();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
}
