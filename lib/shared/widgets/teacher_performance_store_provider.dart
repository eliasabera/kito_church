import 'package:flutter/material.dart';
import 'package:kitoapp/features/learning/services/teacher_performance_store.dart';

class TeacherPerformanceStoreProvider
    extends InheritedNotifier<TeacherPerformanceStore> {
  const TeacherPerformanceStoreProvider({
    super.key,
    required TeacherPerformanceStore super.notifier,
    required super.child,
  });

  static TeacherPerformanceStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<TeacherPerformanceStoreProvider>();
    assert(provider != null, 'TeacherPerformanceStoreProvider not found');
    return provider!.notifier!;
  }
}
