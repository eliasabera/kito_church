import 'package:flutter/material.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_store.dart';

class TeacherLessonsStoreProvider
    extends InheritedNotifier<TeacherLessonsStore> {
  const TeacherLessonsStoreProvider({
    super.key,
    required TeacherLessonsStore super.notifier,
    required super.child,
  });

  static TeacherLessonsStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<TeacherLessonsStoreProvider>();
    assert(provider != null, 'TeacherLessonsStoreProvider not found');
    return provider!.notifier!;
  }
}
