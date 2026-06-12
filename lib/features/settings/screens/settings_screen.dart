import 'package:flutter/material.dart';
import 'package:kitoapp/features/settings/screens/settings_content.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.settings,
      body: const SettingsContent(),
    );
  }
}
