import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio; // 👈 cần cho MultipartFile/FormData

import '../../widgets/main_scaffold.dart';
import '../../core/api.dart';
import '../../core/config.dart';
import '../../models/product.dart';

final _dio = ApiClient.dio;

class ProductsAdminPage extends ConsumerStatefulWidget {
  const ProductsAdminPage({super.key});
  @override
  ConsumerState<ProductsAdminPage> createState() => _ProductsAdminPageState();
}

class _ProductsAdminPageState extends ConsumerState<ProductsAdminPage> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Product>> _load() async {
    final res = await _dio.get('/products');
    final data = res.data as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _ProductEditorSheet(),
    ).then((_) => _refresh());
  }

  Future<void> _deleteProduct(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn chắc muốn xóa? Thao tác này không hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true) return;
    await _dio.delete('/products/$id');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa')));
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Quản lý sản phẩm',
      floating: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Lỗi: ${snap.error}'));
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return const Center(child: Text('Chưa có sản phẩm.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = items[i];
                final v = p.variants.isNotEmpty ? p.variants.first : null;

                String? img;
                if (v != null && v.images.isNotEmpty && v.images.first is String) {
                  img = v.images.first as String;
                }

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: img == null
                          ? const SizedBox(
                          width: 56, height: 56, child: ColoredBox(color: Color(0xFFEDEDED)))
                          : Image.network(
                          img.startsWith('http')
                              ? img
                              : '${AppConfig.baseUrl}$img',
                          width: 56, height: 56, fit: BoxFit.cover),
                    ),
                    title: Text(p.name),
                    subtitle: Text('Giá gốc ${p.basePrice.toStringAsFixed(0)} • Variants: ${p.variants.length}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Sửa nhanh',
                          onPressed: () => _openEditSheet(p),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          tooltip: 'Xóa',
                          onPressed: () => _deleteProduct(p.id),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openEditSheet(Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProductEditorSheet(existing: p),
    ).then((_) => _refresh());
  }
}

class _ProductEditorSheet extends StatefulWidget {
  const _ProductEditorSheet({this.existing});
  final Product? existing;

  @override
  State<_ProductEditorSheet> createState() => _ProductEditorSheetState();
}

class _ProductEditorSheetState extends State<_ProductEditorSheet> {
  final _form = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _basePrice = TextEditingController(text: '3000000');
  final _desc = TextEditingController();

  final _sku = TextEditingController();
  final _sizeUs = TextEditingController(text: '9');
  final _price = TextEditingController(text: '3000000');
  final _qty = TextEditingController(text: '5');

  String? _brandId;
  List<Map<String, dynamic>> _brands = [];
  bool _loadingBrands = true;

  final _picker = ImagePicker();
  File? _localImage;
  String? _uploadedUrl;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _name.text = e.name;
      // e.slug có thể không tồn tại trong model => đừng truy cập
      _basePrice.text = e.basePrice.toStringAsFixed(0);
      _desc.text = e.description ?? '';
      // nếu model có brandId thì set ở đây
    }
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final res = await _dio.get('/meta/brands'); // đảm bảo backend có /meta/brands
      _brands = (res.data as List).cast<Map<String, dynamic>>();
    } catch (_) {
      _brands = [];
    } finally {
      if (mounted) setState(() => _loadingBrands = false);
    }
  }

  String _slugify(String name) => name
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')   // thay chuỗi không hợp lệ bằng dấu -
      .replaceAll(RegExp(r'^-+|-+$'), '');      // cắt gạch đầu/cuối (dùng raw string)



  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (x == null) return;
    setState(() {
      _localImage = File(x.path);
      _uploadedUrl = null;
    });
  }

  Future<void> _uploadImageIfNeeded() async {
    if (_uploadedUrl != null || _localImage == null) return;

    final form = dio.FormData.fromMap({
      'image': await dio.MultipartFile.fromFile(
        _localImage!.path,
        filename: _localImage!.path.split(Platform.pathSeparator).last,
      ),
    });

    final res = await _dio.post('/upload', data: form);
    // backend nên trả về { "url": "/uploads/xxx.jpg" } hoặc full URL
    final url = (res.data)['url'] as String;
    _uploadedUrl = url;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => saving = true);
    try {
      // 1) Upload ảnh trước
      await _uploadImageIfNeeded();

      final images = _uploadedUrl == null ? <String>[] : <String>[_uploadedUrl!];

      // 2) Chuẩn bị payload
      final generatedSlug =
      _slug.text.trim().isEmpty ? _slugify(_name.text) : _slug.text.trim();

      final body = {
        "name": _name.text.trim(),
        "slug": generatedSlug, // nếu backend có field này
        "basePrice": double.tryParse(_basePrice.text) ?? 0,
        if (_brandId != null) "brandId": _brandId,
        "description": _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        "variants": [
          {
            "color": "Default",
            "images": images,
            "sizes": [
              {
                "sizeUS": double.tryParse(_sizeUs.text),
                "sku": _sku.text.trim().isEmpty ? null : _sku.text.trim(),
                "price": double.tryParse(_price.text) ?? 0,
                "qtyOnHand": int.tryParse(_qty.text) ?? 0
              }
            ]
          }
        ]
      };

      // 3) Call API
      if (widget.existing == null) {
        await _dio.post('/products', data: body);
      } else {
        // Nếu có endpoint update thì đổi thành PUT/PATCH
        await _dio.post('/products', data: body);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đã lưu sản phẩm')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi lưu: $e')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.existing == null ? 'Tạo sản phẩm' : 'Sửa sản phẩm',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),

                // Ảnh + name + slug
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFEDEDED),
                          image: _localImage != null
                              ? DecorationImage(image: FileImage(_localImage!), fit: BoxFit.cover)
                              : (_uploadedUrl != null
                              ? DecorationImage(
                              image: NetworkImage(
                                _uploadedUrl!.startsWith('http')
                                    ? _uploadedUrl!
                                    : '${AppConfig.baseUrl}${_uploadedUrl!}',
                              ),
                              fit: BoxFit.cover)
                              : null),
                        ),
                        child: _localImage == null && _uploadedUrl == null
                            ? const Icon(Icons.add_a_photo)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(labelText: 'Name'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                            onChanged: (v) {
                              if (_slug.text.trim().isEmpty) {
                                _slug.text = _slugify(v);
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _slug,
                            decoration: const InputDecoration(labelText: 'Slug (tuỳ chọn)'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Brand + Base price
                Row(
                  children: [
                    Expanded(
                      child: _loadingBrands
                          ? const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()))
                          : DropdownButtonFormField<String?>(
                        isExpanded: true,
                        value: _brandId,
                        hint: const Text('Brand (tùy chọn)'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('— Không chọn —'),
                          ),
                          ..._brands.map((b) => DropdownMenuItem<String?>(
                            value: b['id'] as String,
                            child: Text(b['name'] as String),
                          )),
                        ],
                        onChanged: (v) => setState(() => _brandId = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _basePrice,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Base price'),
                        validator: (v) =>
                        (double.tryParse(v ?? '') == null) ? 'Số hợp lệ' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: 'Mô tả (tùy chọn)'),
                  maxLines: 3,
                ),

                const SizedBox(height: 12),
                Text('Biến thể mặc định', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sku,
                        decoration: const InputDecoration(labelText: 'SKU (tùy chọn)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sizeUs,
                        decoration: const InputDecoration(labelText: 'Size US'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                        (double.tryParse(v ?? '') == null) ? 'Số hợp lệ' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        decoration: const InputDecoration(labelText: 'Giá size'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                        (double.tryParse(v ?? '') == null) ? 'Số hợp lệ' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _qty,
                        decoration: const InputDecoration(labelText: 'Tồn kho ban đầu'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                        (int.tryParse(v ?? '') == null) ? 'Số nguyên' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: saving ? null : _save,
                    icon: const Icon(Icons.save),
                    label: Text(saving ? 'Đang lưu...' : 'Lưu sản phẩm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
