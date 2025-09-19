import 'package:dio/dio.dart';
import '../../core/api.dart';
import '../../models/product.dart';

class ProductService {
  final Dio _dio = ApiClient.dio;

  Future<List<Product>> list({
    String? q,
    String? brandId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final res = await _dio.get('/products', queryParameters: {
      if (q != null && q.isNotEmpty) 'q': q,
      if (brandId != null && brandId.isNotEmpty) 'brandId': brandId,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
    });
    final data = res.data as List;
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> getById(String id) async {
    final res = await _dio.get('/products/$id');
    return Product.fromJson(res.data as Map<String, dynamic>);
  }
}
