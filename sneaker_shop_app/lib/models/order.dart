class Order {
  final String id;
  final String status;
  final double subtotal;
  final double shipping;
  final double total;
  final DateTime placedAt;
  final List<OrderItem> items;

  Order({required this.id, required this.status, required this.subtotal, required this.shipping, required this.total, required this.placedAt, required this.items});

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: j['id'],
    status: j['status'],
    subtotal: (j['subtotal'] as num).toDouble(),
    shipping: (j['shipping'] as num).toDouble(),
    total: (j['total'] as num).toDouble(),
    placedAt: DateTime.parse(j['placedAt']),
    items: (j['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
  );
}

class OrderItem {
  final String id;
  final String variantSizeId;
  final int quantity;
  final double unitPrice;

  OrderItem({required this.id, required this.variantSizeId, required this.quantity, required this.unitPrice});

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id: j['id'],
    variantSizeId: j['variantSizeId'],
    quantity: j['quantity'],
    unitPrice: (j['unitPrice'] as num).toDouble(),
  );
}
