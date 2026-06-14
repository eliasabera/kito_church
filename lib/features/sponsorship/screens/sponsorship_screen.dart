import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/services/compassion_management_store.dart';
import 'package:kitoapp/features/profile/widgets/profile_section_card.dart';
import 'package:kitoapp/features/sponsorship/data/sponsorship_data.dart';
import 'package:kitoapp/features/sponsorship/widgets/sponsor_header_card.dart';
import 'package:kitoapp/features/sponsorship/widgets/sponsor_letter_tile.dart';
import 'package:kitoapp/features/sponsorship/widgets/sponsor_message_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/compassion_management_store_provider.dart';

class SponsorshipContent extends StatelessWidget {
  const SponsorshipContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = CompassionManagementStoreProvider.of(context);
    final letters = SponsorshipData.letters;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final sponsor = store.sponsorProfileForStudent(
          CompassionManagementStore.currentStudentId,
        );

        if (sponsor == null) {
          return ColoredBox(
            color: AppColors.primary.withValues(alpha: 0.03),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.volunteer_activism_outlined,
                      size: 48,
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noSponsorAssigned,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              SponsorHeaderCard(sponsor: sponsor),
              const SizedBox(height: 14),
              SponsorMessageCard(message: sponsor.message),
              const SizedBox(height: 12),
              ProfileSectionCard(
                title: l10n.sponsorship,
                children: [
                  ProfileInfoRow(
                    icon: Icons.person_outline,
                    label: l10n.sponsorName,
                    value: sponsor.name,
                  ),
                  ProfileInfoRow(
                    icon: Icons.public_outlined,
                    label: l10n.sponsorCountry,
                    value: sponsor.country,
                  ),
                  ProfileInfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: l10n.sponsoredSince,
                    value: sponsor.sponsoredSince,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                l10n.lettersFromSponsor,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (letters.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      l10n.noLetters,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.45),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...letters.map((letter) => SponsorLetterTile(letter: letter)),
            ],
          ),
        );
      },
    );
  }
}

class SponsorshipScreen extends StatelessWidget {
  const SponsorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.sponsorship,
      body: const SponsorshipContent(),
    );
  }
}
