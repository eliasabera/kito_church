import 'package:flutter/widgets.dart';
import 'package:kitoapp/features/notifications/services/notifications_store.dart';

class NotificationsStoreProvider
    extends InheritedNotifier<NotificationsStore> {
  const NotificationsStoreProvider({
    super.key,
    required NotificationsStore super.notifier,
    required super.child,
  });

  static NotificationsStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<NotificationsStoreProvider>();
    assert(provider != null, 'NotificationsStoreProvider not found');
    return provider!.notifier!;
  }
}
