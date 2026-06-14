import 'package:flutter/material.dart';
import 'package:kitoapp/features/announcements/services/announcements_store.dart';

class AnnouncementsStoreProvider extends InheritedNotifier<AnnouncementsStore> {
  const AnnouncementsStoreProvider({
    super.key,
    required AnnouncementsStore super.notifier,
    required super.child,
  });

  static AnnouncementsStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AnnouncementsStoreProvider>();
    assert(provider != null, 'AnnouncementsStoreProvider not found');
    return provider!.notifier!;
  }
}
