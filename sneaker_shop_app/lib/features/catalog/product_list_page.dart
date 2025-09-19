import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/main_scaffold.dart';
import 'product_detail_page.dart';
import '../../core/config.dart';
import '../../models/product.dart';
import 'product_service.dart' as ps;   // service sản phẩm
import 'meta_service.dart' as ms;     // service brand/meta
import '../cart/cart_provider.dart';

final _productSvcProvider = Provider((ref) => ps.ProductService());
final _metaSvcProvider = Provider((ref) => ms.MetaService());

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});
  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage>
    with AutomaticKeepAliveClientMixin {
  // state lọc
  String? _brandId;
  String _q = '';
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  // debounce search
  Timer? _debounce;

  // cache brands 1 lần
  late Future<List<Map<String, dynamic>>> _brandsFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _brandsFuture = ref.read(_metaSvcProvider).brands();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _q = v);
    });
  }

  Future<void> _refresh() async => setState(() {});

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final productSvc = ref.read(_productSvcProvider);
    final minVal = double.tryParse(_minCtrl.text);
    final maxVal = double.tryParse(_maxCtrl.text);

    final future = productSvc.list(
      q: _q,
      brandId: _brandId,
      minPrice: minVal,
      maxPrice: maxVal,
    );

    return MainScaffold(
      title: 'Sản phẩm',
      body: Column(
        children: [
          // FILTER BAR
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                children: [
                  // Search
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm theo tên hoặc slug...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: _onQueryChanged,
                  ),
                  const SizedBox(height: 8),

                  // Brand
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _brandsFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const SizedBox.shrink();
                      }
                      if (snap.hasError) {
                        return Text(
                          'Lỗi tải brand: ${snap.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      final brands = snap.data ?? const [];
                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _brandId, // dùng initialValue (mới)
                              isExpanded: true,
                              hint: const Text('Tất cả brand'),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Tất cả'),
                                ),
                                ...brands.map((b) => DropdownMenuItem(
                                  value: b['id'] as String,
                                  child: Text(b['name'] as String),
                                )),
                              ],
                              onChanged: (v) => setState(() => _brandId = v),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Min/Max + Lọc
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.currency_exchange),
                            labelText: 'Min',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.currency_exchange),
                            labelText: 'Max',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.tune),
                        label: const Text('Lọc'),
                      ),
                    ],
                  ),

                  // Chips trạng thái hiện tại
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (_brandId != null)
                        InputChip(
                          label: const Text('Brand'),
                          onDeleted: () => setState(() => _brandId = null),
                        ),
                      if (_minCtrl.text.isNotEmpty || _maxCtrl.text.isNotEmpty)
                        InputChip(
                          label: Text('Giá ${_minCtrl.text} - ${_maxCtrl.text}'),
                          onDeleted: () {
                            _minCtrl.clear();
                            _maxCtrl.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // GRID SẢN PHẨM
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Product>>(
                future: future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Lỗi: ${snap.error}'));
                  }
                  final items = snap.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text('Không có sản phẩm khớp bộ lọc.'));
                  }

                  final cross = MediaQuery.of(context).size.width > 600 ? 3 : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: .78,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final p = items[i];
                      final variant = p.variants.isNotEmpty ? p.variants.first : null;

                      String? img;
                      if (variant != null && variant.images.isNotEmpty) {
                        final anyUrl = variant.images.first;
                        if (anyUrl is String) img = anyUrl;
                      }

                      final firstSize =
                      (variant != null && variant.sizes.isNotEmpty) ? variant.sizes.first : null;
                      final price = firstSize?.price ?? p.basePrice;

                      return _ProductCard(
                        name: p.name,
                        price: price.toStringAsFixed(0),
                        imageUrl: img == null ? null : '${AppConfig.baseUrl}$img',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetailPage(id: p.id)),
                          );
                        },
                        onAdd: firstSize == null
                            ? null
                            : () {
                          ref.read(cartProvider.notifier).add(firstSize, qty: 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã thêm vào giỏ')),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    required this.price,
    required this.onTap,
    required this.onAdd,
    this.imageUrl,
  });

  final String name;
  final String price;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), // tránh deprecated withOpacity
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: imageUrl == null
                    ? const ColoredBox(color: Color(0xFFEDEDED))
                    : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  cacheWidth: 600,                // decode nhỏ để mượt
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('₫$price', style: Theme.of(context).textTheme.titleMedium),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Thêm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
