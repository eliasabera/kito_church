import 'package:flutter/material.dart';
import 'package:kitoapp/features/scoring/services/scoring_store.dart';

class ScoringStoreProvider extends InheritedNotifier<ScoringStore> {
  const ScoringStoreProvider({
    super.key,
    required ScoringStore super.notifier,
    required super.child,
  });

  static ScoringStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ScoringStoreProvider>();
    assert(provider != null, 'ScoringStoreProvider not found');
    return provider!.notifier!;
  }
}
