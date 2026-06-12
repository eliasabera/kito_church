import 'package:flutter/material.dart';

/// Holds the active app locale and notifies listeners when it changes.
class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier({Locale? initialLocale})
      : _locale = initialLocale ?? const Locale('en');

  Locale _locale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    setLocale(_locale.languageCode == 'am'
        ? const Locale('en')
        : const Locale('am'));
  }
}
