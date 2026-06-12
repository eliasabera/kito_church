import 'package:flutter/material.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/feature_placeholder.dart';

class CertificatesContent extends StatelessWidget {
  const CertificatesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FeaturePlaceholder(
      title: l10n.generateCertificate,
      icon: Icons.workspace_premium_outlined,
    );
  }
}

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.certificates,
      body: const CertificatesContent(),
    );
  }
}
