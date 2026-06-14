import 'package:flutter/material.dart';
import 'package:kitoapp/features/dashboard/services/teacher_dashboard_store.dart';

class TeacherDashboardStoreProvider
    extends InheritedNotifier<TeacherDashboardStore> {
  const TeacherDashboardStoreProvider({
    super.key,
    required TeacherDashboardStore super.notifier,
    required super.child,
  });

  static TeacherDashboardStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<TeacherDashboardStoreProvider>();
    assert(provider != null, 'TeacherDashboardStoreProvider not found');
    return provider!.notifier!;
  }
}
