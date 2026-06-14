import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/scoring/data/scoring_data.dart';
import 'package:kitoapp/features/scoring/widgets/scoring_category_tile.dart';
import 'package:kitoapp/features/scoring/widgets/scoring_hero.dart';
import 'package:kitoapp/features/scoring/widgets/scoring_overview_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/scoring_store_provider.dart';

class ScoringContent extends StatelessWidget {
  const ScoringContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = ScoringStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                children: [
                  const ScoringHero(),
                  const SizedBox(height: 18),
                  ScoringOverviewCard(
                    totalWeight: store.totalWeight,
                    isValid: store.isValid,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.adjustWeights,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.scoringWeightsHint,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final category in ScoringData.categories)
                    ScoringCategoryTile(
                      category: category,
                      label: scoringCategoryLabel(category, l10n),
                      hint: scoringCategoryHint(category, l10n),
                      icon: scoringCategoryIcon(category),
                      value: store.weightFor(category),
                      maxValue: store.maxWeightFor(category),
                      onChanged: (value) =>
                          store.setWeight(category, value),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: store.resetToDefaults,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.resetToDefaults),
                  ),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: FilledButton(
                  onPressed: store.isValid
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.scoringSaved)),
                          );
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        );
      },
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
