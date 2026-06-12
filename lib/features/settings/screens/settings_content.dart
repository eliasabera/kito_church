import 'package:flutter/material.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/locale_notifier_provider.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = LocaleNotifierProvider.of(context);
    final currentCode = localeNotifier.locale.languageCode;

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          subtitle: Text(currentCode == 'am' ? l10n.amharic : l10n.english),
        ),
        ListTile(
          leading: const Icon(Icons.check),
          title: Text(l10n.english),
          trailing: currentCode == 'en'
              ? Icon(Icons.radio_button_checked,
                  color: Theme.of(context).colorScheme.primary)
              : const Icon(Icons.radio_button_off),
          onTap: () => localeNotifier.setLocale(const Locale('en')),
        ),
        ListTile(
          leading: const Icon(Icons.check),
          title: Text(l10n.amharic),
          trailing: currentCode == 'am'
              ? Icon(Icons.radio_button_checked,
                  color: Theme.of(context).colorScheme.primary)
              : const Icon(Icons.radio_button_off),
          onTap: () => localeNotifier.setLocale(const Locale('am')),
        ),
      ],
    );
  }
}
