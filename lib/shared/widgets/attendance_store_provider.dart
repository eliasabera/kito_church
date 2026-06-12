import 'package:flutter/material.dart';
import 'package:kitoapp/features/attendance/services/attendance_store.dart';

class AttendanceStoreProvider extends InheritedNotifier<AttendanceStore> {
  const AttendanceStoreProvider({
    super.key,
    required AttendanceStore super.notifier,
    required super.child,
  });

  static AttendanceStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AttendanceStoreProvider>();
    assert(provider != null, 'AttendanceStoreProvider not found');
    return provider!.notifier!;
  }
}
