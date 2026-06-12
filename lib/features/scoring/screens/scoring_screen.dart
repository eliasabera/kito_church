import 'package:flutter/material.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/feature_placeholder.dart';

class ScoringContent extends StatelessWidget {
  const ScoringContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FeaturePlaceholder(
      title: l10n.scoringSystem,
      icon: Icons.tune_outlined,
    );
  }
}

class ScoringScreen extends StatelessWidget {
  const ScoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.scoringSystem,
      body: const ScoringContent(),
    );
  }
}
