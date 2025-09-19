import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/login_page.dart';
import 'features/catalog/product_list_page.dart';
import 'features/cart/cart_page.dart';
import 'features/orders/my_orders_page.dart';

// Admin pages
// GỠ import thừa: import 'features/admin/admin_dashboard.dart';
import 'features/admin/admin_dashboard_page.dart';
import 'features/admin/orders_admin_page.dart';
import 'features/admin/users_admin_page.dart';
import 'features/admin/products_admin_page.dart';
import 'features/admin/meta_admin_page.dart'; // <<< THÊM CÁI NÀY

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sneaker Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.black),

      // Khai báo routes đầy đủ
      routes: {
        // alias để MainScaffold logout về /login không văng
        '/login': (_) => const LoginPage(),

        '/': (_) => const LoginPage(),
        '/products': (_) => const ProductListPage(),
        '/cart': (_) => const CartPage(),
        '/orders': (_) => const MyOrdersPage(),

        '/admin': (_) => const AdminDashboardPage(),
        '/admin/products': (_) => const ProductsAdminPage(),
        '/admin/orders': (_) => const OrdersAdminPage(),
        '/admin/meta': (_) => const MetaAdminPage(),
        '/admin/users': (_) => const UsersAdminPage(),
      },

      // Nếu muốn vào app luôn thì giữ '/', còn thích rõ ràng thì đặt '/login'
      initialRoute: '/',
    );
  }
}
