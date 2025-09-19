import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_provider.dart';

class MainScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? floating;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.floating,
  });

  bool _isStaffOrAdmin(String? role) {
    final r = role?.toLowerCase();
    return r == 'staff' || r == 'admin'  || r == 'user';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final role = auth.user?.role; // 'user' | 'staff' | 'admin'

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),

            // Ai cũng thấy
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Sản phẩm'),
              onTap: () => Navigator.pushReplacementNamed(context, '/products'),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Giỏ hàng'),
              onTap: () => Navigator.pushReplacementNamed(context, '/cart'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Đơn của tôi'),
              onTap: () => Navigator.pushReplacementNamed(context, '/orders'),
            ),

            // Chỉ staff/admin mới thấy
            if (_isStaffOrAdmin(role))
              const Divider(),
            if (_isStaffOrAdmin(role))
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Quản trị'),
                onTap: () => Navigator.pushReplacementNamed(context, '/admin'),
              ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                }
              },
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: floating,
    );
  }
}
