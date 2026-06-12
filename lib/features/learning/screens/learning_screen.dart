import 'package:flutter/material.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/feature_placeholder.dart';

class LearningContent extends StatelessWidget {
  const LearningContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FeaturePlaceholder(
      title: '${l10n.lessons} · ${l10n.assignments} · ${l10n.quizzes}',
      icon: Icons.school_outlined,
    );
  }
}

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.learning,
      body: const LearningContent(),
    );
  }
}
