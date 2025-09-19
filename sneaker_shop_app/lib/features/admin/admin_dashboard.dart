import 'package:flutter/material.dart';
import 'orders_admin_page.dart';
import 'products_admin_page.dart';
import 'users_admin_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late final TabController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin/Staff'),
        bottom: TabBar(
          controller: _ctl,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Orders'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _ctl,
        children: const [
          ProductsAdminPage(),
          OrdersAdminPage(),
          UsersAdminPage(),
        ],
      ),
    );
  }
}
