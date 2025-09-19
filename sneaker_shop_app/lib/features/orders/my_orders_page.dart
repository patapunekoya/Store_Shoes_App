import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'order_repository.dart';
import 'package:intl/intl.dart';
import '../../widgets/main_scaffold.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = OrderRepository();
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return MainScaffold(
      title: 'Đơn hàng của tôi',
      body: FutureBuilder<List<Order>>(
        future: repo.myOrders(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('Chưa có đơn hàng nào.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final o = orders[i];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text('Đơn #${o.id.substring(0, 8)}'),
                  subtitle: Row(
                    children: [
                      _StatusChip(status: o.status),
                      const SizedBox(width: 8),
                      Text(df.format(o.placedAt)),
                    ],
                  ),
                  trailing: Text('₫${o.total.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  Color _c() {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.orange;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _c();
    return Chip(
      label: Text(status),
      backgroundColor: c.withOpacity(0.15),
      side: BorderSide(color: c.withOpacity(0.4)),
      labelStyle: TextStyle(color: c),
      visualDensity: VisualDensity.compact,
    );
  }
}
