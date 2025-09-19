import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/main_scaffold.dart';

class MetaAdminPage extends ConsumerWidget {
  const MetaAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MainScaffold(
      title: 'Brand & Category',
      body: Center(child: Text('TODO: CRUD brand/category')),
    );
  }
}
