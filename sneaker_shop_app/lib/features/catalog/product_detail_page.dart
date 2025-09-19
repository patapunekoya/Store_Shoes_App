import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config.dart';
import '../../models/product.dart';
import 'product_service.dart';
import '../cart/cart_provider.dart';
import '../../widgets/main_scaffold.dart';

final _svcProvider = Provider((ref) => ProductService());

class ProductDetailPage extends ConsumerWidget {
  final String id;
  const ProductDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = ref.read(_svcProvider);

    return MainScaffold(
      title: 'Chi tiết sản phẩm',
      body: FutureBuilder<Product>(
        future: svc.getById(id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(child: Text('Lỗi: ${snap.error ?? "Không tìm thấy"}'));
          }
          final p = snap.data!;
          final firstVariant = p.variants.isNotEmpty ? p.variants.first : null;
          final images = (firstVariant?.images ?? []).cast<dynamic>().whereType<String>().toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Gallery
              if (images.isNotEmpty)
                AspectRatio(
                  aspectRatio: 1.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PageView(
                      children: images
                          .map((u) => Image.network('${AppConfig.baseUrl}$u', fit: BoxFit.cover))
                          .toList(),
                    ),
                  ),
                )
              else
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 48),
                ),

              const SizedBox(height: 16),
              Text(p.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Giá từ ${p.basePrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),

              if (p.description != null)
                Text(p.description!, style: Theme.of(context).textTheme.bodyMedium),

              const SizedBox(height: 18),
              Text('Chọn size', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              if (firstVariant == null || firstVariant.sizes.isEmpty)
                const Text('Tạm hết hàng')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: firstVariant.sizes.map((s) {
                    final price = s.price ?? p.basePrice;
                    final label = s.sizeUS ?? s.sizeEU?.toDouble() ?? s.sizeCM ?? 0;
                    return ElevatedButton(
                      onPressed: () {
                        ref.read(cartProvider.notifier).add(s, qty: 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã thêm vào giỏ')),
                        );
                      },
                      child: Text('$label • ${price.toStringAsFixed(0)}'),
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}
