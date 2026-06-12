import 'package:flutter/material.dart';
import 'package:kitoapp/core/locale/locale_notifier.dart';

/// Simple inherited widget to access [LocaleNotifier] without extra packages.
class LocaleNotifierProvider extends InheritedNotifier<LocaleNotifier> {
  const LocaleNotifierProvider({
    super.key,
    required LocaleNotifier super.notifier,
    required super.child,
  });

  static LocaleNotifier of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<LocaleNotifierProvider>();
    assert(provider != null, 'LocaleNotifierProvider not found');
    return provider!.notifier!;
  }
}
