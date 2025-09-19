double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

class Product {
  final String id;
  final String name;
  final double basePrice;            // giữ double
  final bool isActive;
  final String? description;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.isActive,
    this.description,
    required this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] as String,
    name: j['name'] as String,
    basePrice: _asDouble(j['basePrice']) ?? 0,   // <<< đổi ở đây
    isActive: (j['isActive'] as bool?) ?? true,
    variants: ((j['variants'] as List?) ?? [])
        .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
        .toList(),
  );
}

class ProductVariant {
  final String id;
  final String? color;
  final List<dynamic> images;
  final List<VariantSize> sizes;

  ProductVariant({
    required this.id,
    this.color,
    required this.images,
    required this.sizes,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
    id: j['id'] as String,
    color: j['color'] as String?,
    images: (j['images'] as List?) ?? const [],
    sizes: ((j['sizes'] as List?) ?? [])
        .map((s) => VariantSize.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

class VariantSize {
  final String id;
  final double? sizeUS;
  final int? sizeEU;
  final double? sizeCM;
  final String? sku;
  final double? price;               // có thể null

  VariantSize({
    required this.id,
    this.sizeUS,
    this.sizeEU,
    this.sizeCM,
    this.sku,
    this.price,
  });

  factory VariantSize.fromJson(Map<String, dynamic> j) => VariantSize(
    id: j['id'] as String,
    sizeUS: _asDouble(j['sizeUS']),
    sizeEU: j['sizeEU'] as int?,
    sizeCM: _asDouble(j['sizeCM']),
    sku: j['sku'] as String?,
    price: _asDouble(j['price']),                 // <<< đổi ở đây
  );
}
