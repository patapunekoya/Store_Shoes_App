import 'package:dio/dio.dart';
import '../../core/api.dart';

class MetaService {
  final Dio _dio = ApiClient.dio;

  Future<List<Map<String, dynamic>>> brands() async {
    final res = await _dio.get('/meta/brands'); // => http://10.0.2.2:8080/api/meta/brands
    final data = res.data as List;
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> categories() async {
    final res = await _dio.get('/meta/categories'); // => http://10.0.2.2:8080/api/meta/categories
    final data = res.data as List;
    return data.cast<Map<String, dynamic>>();
  }
}
