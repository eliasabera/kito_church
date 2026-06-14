import 'package:flutter/material.dart';
import 'package:kitoapp/features/bible_stories/services/bible_stories_store.dart';

class BibleStoriesStoreProvider extends InheritedNotifier<BibleStoriesStore> {
  const BibleStoriesStoreProvider({
    super.key,
    required BibleStoriesStore super.notifier,
    required super.child,
  });

  static BibleStoriesStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<BibleStoriesStoreProvider>();
    assert(provider != null, 'BibleStoriesStoreProvider not found');
    return provider!.notifier!;
  }
}
