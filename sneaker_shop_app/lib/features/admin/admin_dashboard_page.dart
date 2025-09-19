import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/main_scaffold.dart';
import '../auth/auth_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final role = user?.role?.toLowerCase(); // 'admin' | 'staff' | 'user'

    return MainScaffold(
      title: 'Bảng điều khiển',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Xin chào ${user?.fullName ?? user?.email ?? 'Admin'}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Hàng “tác vụ nhanh”
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AdminTile(
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                  title: 'Quản lý sản phẩm',
                  subtitle: 'Thêm/sửa/xóa, ảnh, size, tồn kho',
                  onTap: () => Navigator.pushNamed(context, '/admin/products'),
                ),
                _AdminTile(
                  icon: Icons.receipt_long,
                  color: Colors.green,
                  title: 'Đơn hàng',
                  subtitle: 'Xác nhận thanh toán, trạng thái',
                  onTap: () => Navigator.pushNamed(context, '/admin/orders'),
                ),
                // Staff cũng thấy 2 mục trên. Các mục dưới chỉ admin thấy
                if (role == 'admin')
                  _AdminTile(
                    icon: Icons.category,
                    color: Colors.orange,
                    title: 'Brand & Category',
                    subtitle: 'Thêm/sửa/xóa nhãn hàng & danh mục',
                    onTap: () => Navigator.pushNamed(context, '/admin/meta'),
                  ),
                if (role == 'admin')
                  _AdminTile(
                    icon: Icons.group,
                    color: Colors.purple,
                    title: 'Người dùng & Phân quyền',
                    subtitle: 'Nâng quyền staff/admin',
                    onTap: () => Navigator.pushNamed(context, '/admin/users'),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Gợi ý quy trình
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Quy trình thường dùng', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    _Bullet('Tạo Brand/Category trước khi tạo Product'),
                    _Bullet('Tạo Product → Variant (ảnh) → Size (SKU, giá, tồn)'),
                    _Bullet('Khi khách đặt: xác nhận thanh toán để trừ tồn thực'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    );
  }
}
