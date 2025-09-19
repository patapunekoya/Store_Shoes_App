import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../widgets/main_scaffold.dart';
import '../../core/api.dart';

final _dio = ApiClient.dio;

class UsersAdminPage extends ConsumerStatefulWidget {
  const UsersAdminPage({super.key});
  @override
  ConsumerState<UsersAdminPage> createState() => _UsersAdminPageState();
}

class _UsersAdminPageState extends ConsumerState<UsersAdminPage> {
  late Future<List<dynamic>> _future;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    final res = await _dio.get('/users', queryParameters: {'q': _q});
    return (res.data as List);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Người dùng & phân quyền',
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm theo email, tên...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) {
                  _q = v;
                  _refresh();
                },
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<dynamic>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
                  final users = snap.data ?? [];
                  if (users.isEmpty) return const Center(child: Text('Không có user.'));

                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final u = users[i] as Map<String, dynamic>;
                      final role = (u['role'] as String?) ?? 'user';
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(child: Text((u['fullName'] ?? u['email']).toString().substring(0, 1).toUpperCase())),
                          title: Text(u['fullName'] ?? u['email']),
                          subtitle: Text(u['email']),
                          trailing: DropdownButton<String>(
                            value: role,
                            items: const [
                              DropdownMenuItem(value: 'user', child: Text('user')),
                              DropdownMenuItem(value: 'staff', child: Text('staff')),
                              DropdownMenuItem(value: 'admin', child: Text('admin')),
                            ],
                            onChanged: (v) => _changeRole(u['id'] as String, v!),
                          ),
                        ),
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

  Future<void> _changeRole(String id, String role) async {
    await _dio.patch('/users/$id/role', data: {'role': role});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã đổi role thành $role')));
      _refresh();
    }
  }
}
