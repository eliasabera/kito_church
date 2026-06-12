import 'package:flutter/material.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/feature_placeholder.dart';

class UserManagementContent extends StatelessWidget {
  const UserManagementContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FeaturePlaceholder(
      title: l10n.pendingApproval,
      icon: Icons.people_outline,
    );
  }
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.manageUsers,
      body: const UserManagementContent(),
    );
  }
}
