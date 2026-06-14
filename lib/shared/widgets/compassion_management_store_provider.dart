import 'package:flutter/material.dart';
import 'package:kitoapp/features/admin/services/compassion_management_store.dart';

class CompassionManagementStoreProvider
    extends InheritedNotifier<CompassionManagementStore> {
  const CompassionManagementStoreProvider({
    super.key,
    required CompassionManagementStore super.notifier,
    required super.child,
  });

  static CompassionManagementStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<CompassionManagementStoreProvider>();
    assert(provider != null, 'CompassionManagementStoreProvider not found');
    return provider!.notifier!;
  }
}
