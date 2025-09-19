import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';

class CartItem {
  final VariantSize size;
  final int quantity;
  CartItem({required this.size, required this.quantity});
}

class CartState {
  final List<CartItem> items;
  const CartState(this.items);
  double get subtotal {
    double s = 0;
    for (final it in items) {
      final price = it.size.price ?? 0;
      s += price * it.quantity;
    }
    return s;
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState([]));

  void add(VariantSize size, {int qty = 1}) {
    final list = [...state.items];
    final idx = list.indexWhere((e) => e.size.id == size.id);
    if (idx >= 0) {
      list[idx] = CartItem(size: list[idx].size, quantity: list[idx].quantity + qty);
    } else {
      list.add(CartItem(size: size, quantity: qty));
    }
    state = CartState(list);
  }

  void remove(String variantSizeId) {
    state = CartState(state.items.where((e) => e.size.id != variantSizeId).toList());
  }

  void clear() => state = const CartState([]);
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());
