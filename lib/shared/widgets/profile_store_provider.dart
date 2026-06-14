import 'package:flutter/material.dart';
import 'package:kitoapp/features/profile/services/profile_store.dart';

class ProfileStoreProvider extends InheritedNotifier<ProfileStore> {
  const ProfileStoreProvider({
    super.key,
    required ProfileStore super.notifier,
    required super.child,
  });

  static ProfileStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ProfileStoreProvider>();
    assert(provider != null, 'ProfileStoreProvider not found');
    return provider!.notifier!;
  }
}
