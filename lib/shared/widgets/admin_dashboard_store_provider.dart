import 'package:flutter/material.dart';
import 'package:kitoapp/features/dashboard/services/admin_dashboard_store.dart';

class AdminDashboardStoreProvider
    extends InheritedNotifier<AdminDashboardStore> {
  const AdminDashboardStoreProvider({
    super.key,
    required AdminDashboardStore super.notifier,
    required super.child,
  });

  static AdminDashboardStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AdminDashboardStoreProvider>();
    assert(provider != null, 'AdminDashboardStoreProvider not found');
    return provider!.notifier!;
  }
}
