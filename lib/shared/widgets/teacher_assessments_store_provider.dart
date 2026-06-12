import 'package:flutter/material.dart';
import 'package:kitoapp/features/learning/services/teacher_assessments_store.dart';

class TeacherAssessmentsStoreProvider
    extends InheritedNotifier<TeacherAssessmentsStore> {
  const TeacherAssessmentsStoreProvider({
    super.key,
    required TeacherAssessmentsStore super.notifier,
    required super.child,
  });

  static TeacherAssessmentsStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<TeacherAssessmentsStoreProvider>();
    assert(provider != null, 'TeacherAssessmentsStoreProvider not found');
    return provider!.notifier!;
  }
}
