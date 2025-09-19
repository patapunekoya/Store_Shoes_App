import 'package:dio/dio.dart';
import '../../core/api.dart';
import '../../models/product.dart';

class ProductRepository {
  final _dio = ApiClient.dio;

  Future<List<Product>> list({String? q}) async {
    final res = await _dio.get('/products', queryParameters: {'q': q});
    final data = res.data as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }
}
