import 'package:flutter/material.dart';
import 'package:kitoapp/features/admin/services/admin_reports_store.dart';

class AdminReportsStoreProvider extends InheritedNotifier<AdminReportsStore> {
  const AdminReportsStoreProvider({
    super.key,
    required AdminReportsStore super.notifier,
    required super.child,
  });

  static AdminReportsStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AdminReportsStoreProvider>();
    assert(provider != null, 'AdminReportsStoreProvider not found');
    return provider!.notifier!;
  }
}
