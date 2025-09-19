import 'package:dio/dio.dart';
import '../../core/api.dart';
import '../../models/order.dart';

class OrderRepository {
  final _dio = ApiClient.dio;

  Future<String> placeOrder(List<({String variantSizeId, int quantity, double unitPrice})> items, {double shipping = 0}) async {
    final res = await _dio.post('/orders', data: {
      'items': items.map((e) => {
        'variantSizeId': e.variantSizeId,
        'quantity': e.quantity,
        'unitPrice': e.unitPrice
      }).toList(),
      'shipping': shipping
    });
    final orderId = res.data['id'] as String;
    return orderId;
  }

  Future<List<Order>> myOrders() async {
    final res = await _dio.get('/orders/me');
    final data = res.data as List;
    return data.map((e) => Order.fromJson(e)).toList();
  }
}
