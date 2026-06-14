import 'package:flutter/material.dart';
import 'package:kitoapp/features/admin/services/users_management_store.dart';

class UsersManagementStoreProvider
    extends InheritedNotifier<UsersManagementStore> {
  const UsersManagementStoreProvider({
    super.key,
    required UsersManagementStore super.notifier,
    required super.child,
  });

  static UsersManagementStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<UsersManagementStoreProvider>();
    assert(provider != null, 'UsersManagementStoreProvider not found');
    return provider!.notifier!;
  }
}
