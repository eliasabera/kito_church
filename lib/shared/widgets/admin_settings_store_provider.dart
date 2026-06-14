import 'package:flutter/material.dart';
import 'package:kitoapp/features/admin/services/admin_settings_store.dart';

class AdminSettingsStoreProvider extends InheritedNotifier<AdminSettingsStore> {
  const AdminSettingsStoreProvider({
    super.key,
    required AdminSettingsStore super.notifier,
    required super.child,
  });

  static AdminSettingsStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AdminSettingsStoreProvider>();
    assert(provider != null, 'AdminSettingsStoreProvider not found');
    return provider!.notifier!;
  }
}
