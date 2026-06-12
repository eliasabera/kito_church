import 'package:flutter/material.dart';
import 'package:kitoapp/features/bible_verse/services/daily_verse_store.dart';

class DailyVerseStoreProvider extends InheritedNotifier<DailyVerseStore> {
  const DailyVerseStoreProvider({
    super.key,
    required DailyVerseStore super.notifier,
    required super.child,
  });

  static DailyVerseStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<DailyVerseStoreProvider>();
    assert(provider != null, 'DailyVerseStoreProvider not found');
    return provider!.notifier!;
  }
}
