import 'package:flutter/material.dart';
import 'package:kitoapp/features/prayer_requests/services/prayer_requests_store.dart';

class PrayerRequestsStoreProvider
    extends InheritedNotifier<PrayerRequestsStore> {
  const PrayerRequestsStoreProvider({
    super.key,
    required PrayerRequestsStore super.notifier,
    required super.child,
  });

  static PrayerRequestsStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<PrayerRequestsStoreProvider>();
    assert(provider != null, 'PrayerRequestsStoreProvider not found');
    return provider!.notifier!;
  }
}
