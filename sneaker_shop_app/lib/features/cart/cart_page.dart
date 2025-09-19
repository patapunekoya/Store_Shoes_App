import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_provider.dart';
import '../orders/order_repository.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final orderRepo = OrderRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final it = cart.items[i];
                return ListTile(
                  title: Text(it.size.sku ?? it.size.id),
                  subtitle: Text('SL: ${it.quantity}'),
                  trailing: Text((it.size.price ?? 0).toStringAsFixed(0)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Tạm tính'),
                  Text('${cart.subtotal.toStringAsFixed(0)}'),
                ]),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () async {
                      final items = cart.items
                          .map((e) => (variantSizeId: e.size.id, quantity: e.quantity, unitPrice: e.size.price ?? 0))
                          .toList();
                      try {
                        final orderId = await orderRepo.placeOrder(items);
                        ref.read(cartProvider.notifier).clear();
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đặt hàng thành công: $orderId')));
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đặt hàng: $e')));
                      }
                    },
                    child: const Text('Đặt hàng'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
