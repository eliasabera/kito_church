import 'package:flutter/material.dart';
import 'package:kitoapp/features/ranking/services/student_ranking_store.dart';

class StudentRankingStoreProvider
    extends InheritedNotifier<StudentRankingStore> {
  const StudentRankingStoreProvider({
    super.key,
    required StudentRankingStore super.notifier,
    required super.child,
  });

  static StudentRankingStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<StudentRankingStoreProvider>();
    assert(provider != null, 'StudentRankingStoreProvider not found');
    return provider!.notifier!;
  }
}
