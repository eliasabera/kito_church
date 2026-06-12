import 'package:flutter/material.dart';
import 'package:kitoapp/features/learning/services/learning_progress_store.dart';

class LearningProgressProvider extends InheritedNotifier<LearningProgressStore> {
  const LearningProgressProvider({
    super.key,
    required LearningProgressStore super.notifier,
    required super.child,
  });

  static LearningProgressStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<LearningProgressProvider>();
    assert(provider != null, 'LearningProgressProvider not found');
    return provider!.notifier!;
  }
}
