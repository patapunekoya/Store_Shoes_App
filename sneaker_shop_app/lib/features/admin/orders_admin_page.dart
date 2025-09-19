import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../widgets/main_scaffold.dart';
import '../../core/api.dart';

final _dio = ApiClient.dio;

class OrdersAdminPage extends ConsumerStatefulWidget {
  const OrdersAdminPage({super.key});
  @override
  ConsumerState<OrdersAdminPage> createState() => _OrdersAdminPageState();
}

class _OrdersAdminPageState extends ConsumerState<OrdersAdminPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final res = await _dio.get('/orders', queryParameters: {'all': true});
    return (res.data as List);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Đơn hàng',
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Lỗi: ${snap.error}'));
            }
            final items = snap.data ?? [];
            if (items.isEmpty) return const Center(child: Text('Chưa có đơn.'));
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final o = items[i] as Map<String, dynamic>;
                final status = (o['status'] as String?) ?? 'pending';
                final total = (o['total'] as num?)?.toDouble() ?? 0;
                final user = o['user'] as Map<String, dynamic>?;
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text('Đơn #${o['id'].toString().substring(0, 8)} • ${user?['email'] ?? 'guest'}'),
                    subtitle: Row(
                      children: [
                        _StatusChip(status: status),
                        const SizedBox(width: 8),
                        Text('Tổng ${total.toStringAsFixed(0)}'),
                      ],
                    ),
                    trailing: FilledButton(
                      onPressed: status == 'paid' ? null : () => _confirmPayment(o['id'] as String),
                      child: const Text('Xác nhận TT'),
                    ),
                    onTap: () => _openDetail(o),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmPayment(String id) async {
    await _dio.post('/orders/$id/confirm-payment');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xác nhận thanh toán')));
      _refresh();
    }
  }

  void _openDetail(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Material(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Chi tiết đơn', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text('ID: ${order['id']}'),
                Text('User: ${(order['user']?['email']) ?? 'guest'}'),
                Text('Status: ${order['status']}'),
                Text('Total: ${(order['total'] as num?)?.toDouble().toString()}'),
                const SizedBox(height: 8),
                const Divider(),
                const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...((order['items'] as List?) ?? []).map((it) {
                  final m = it as Map<String, dynamic>;
                  return ListTile(
                    dense: true,
                    title: Text('x${m['quantity']}  •  ${(m['unitPrice'] as num).toString()}'),
                    subtitle: Text('VariantSize: ${m['variantSizeId']}'),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  Color _baseColor() {
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
    final c = _baseColor();
    return Chip(
      label: Text(status),
      backgroundColor: c.withOpacity(0.15),
      side: BorderSide(color: c.withOpacity(0.4)),
      labelStyle: TextStyle(color: c),
      visualDensity: VisualDensity.compact,
    );
  }
}
