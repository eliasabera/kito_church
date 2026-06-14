import 'package:flutter/widgets.dart';
import 'package:kitoapp/features/learning/services/student_learning_catalog_store.dart';

class StudentLearningCatalogProvider
    extends InheritedNotifier<StudentLearningCatalogStore> {
  const StudentLearningCatalogProvider({
    super.key,
    required StudentLearningCatalogStore super.notifier,
    required super.child,
  });

  static StudentLearningCatalogStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<StudentLearningCatalogProvider>();
    assert(provider != null, 'StudentLearningCatalogProvider not found');
    return provider!.notifier!;
  }
}
