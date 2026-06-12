import 'package:flutter/material.dart';
import 'package:kitoapp/features/attendance/services/teacher_attendance_store.dart';

class TeacherAttendanceStoreProvider
    extends InheritedNotifier<TeacherAttendanceStore> {
  const TeacherAttendanceStoreProvider({
    super.key,
    required TeacherAttendanceStore super.notifier,
    required super.child,
  });

  static TeacherAttendanceStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<TeacherAttendanceStoreProvider>();
    assert(provider != null, 'TeacherAttendanceStoreProvider not found');
    return provider!.notifier!;
  }
}
