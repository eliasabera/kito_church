import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/constants/app_info.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/core/router/role_nav_config.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/profile/data/profile_data.dart';
import 'package:kitoapp/features/profile/models/user_profile.dart';
import 'package:kitoapp/features/profile/widgets/profile_header.dart';
import 'package:kitoapp/features/profile/widgets/profile_section_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/attendance_store_provider.dart';
import 'package:kitoapp/shared/widgets/locale_notifier_provider.dart';
import 'package:kitoapp/shared/widgets/profile_store_provider.dart';
import 'package:kitoapp/shared/widgets/student_ranking_store_provider.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProfileStoreProvider.of(context).load();
      StudentRankingStoreProvider.of(context).load();
    });
  }

  UserRole _currentRole(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return roleFromPath(path) ?? UserRole.student;
  }

  UserProfile _profileForRole(UserRole role) {
    final store = ProfileStoreProvider.of(context);
    return store.profile ?? ProfileData.forRole(role);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = LocaleNotifierProvider.of(context);
    final currentCode = localeNotifier.locale.languageCode;
    final role = _currentRole(context);
    final profileStore = ProfileStoreProvider.of(context);

    return ListenableBuilder(
      listenable: profileStore,
      builder: (context, _) {
        if (profileStore.isLoading && profileStore.profile == null) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = _profileForRole(role);

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            onRefresh: profileStore.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ProfileHeader(profile: profile),
                if (role == UserRole.student) ...[
                  const SizedBox(height: 14),
                  _StudentStatsRow(l10n: l10n),
                ],
                const SizedBox(height: 14),
                ProfileSectionCard(
                  title: l10n.personalInfo,
                  children: _personalInfoRows(profile, l10n),
                ),
                if (profile.role == UserRole.student &&
                    profile.sponsorName != null) ...[
                  const SizedBox(height: 12),
                  ProfileSectionCard(
                    title: l10n.sponsorship,
                    children: [
                      ProfileInfoRow(
                        icon: Icons.favorite_outline,
                        label: l10n.sponsorName,
                        value: profile.sponsorName!,
                      ),
                      ProfileInfoRow(
                        icon: Icons.public_outlined,
                        label: l10n.sponsorCountry,
                        value: profile.sponsorCountry ?? '—',
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                ProfileSectionCard(
                  title: l10n.language,
                  children: [
                    ProfileLanguageOption(
                      label: l10n.english,
                      selected: currentCode == 'en',
                      onTap: () =>
                          localeNotifier.setLocale(const Locale('en')),
                    ),
                    ProfileLanguageOption(
                      label: l10n.amharic,
                      selected: currentCode == 'am',
                      onTap: () =>
                          localeNotifier.setLocale(const Locale('am')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProfileSectionCard(
                  title: l10n.about,
                  children: [
                    ProfileInfoRow(
                      icon: Icons.info_outline,
                      label: l10n.appVersion,
                      value: AppInfo.versionLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () async {
                    ProfileStoreProvider.of(context).clear();
                    StudentRankingStoreProvider.of(context).clear();
                    AttendanceStoreProvider.of(context).clear();
                    await AuthSession.signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(l10n.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _personalInfoRows(UserProfile profile, AppLocalizations l10n) {
    final rows = <Widget>[
      ProfileInfoRow(
        icon: Icons.email_outlined,
        label: l10n.email,
        value: profile.email,
      ),
      if (profile.compassionId != null)
        ProfileInfoRow(
          icon: Icons.badge_outlined,
          label: l10n.compassionProjectId,
          value: profile.compassionId!,
        ),
      if (profile.university != null)
        ProfileInfoRow(
          icon: Icons.account_balance_outlined,
          label: l10n.university,
          value: profile.university!,
        ),
      if (profile.department != null)
        ProfileInfoRow(
          icon: Icons.work_outline,
          label: l10n.department,
          value: profile.department!,
        ),
      if (profile.phone != null)
        ProfileInfoRow(
          icon: Icons.phone_outlined,
          label: l10n.phoneNumber,
          value: profile.phone!,
        ),
    ];

    return rows;
  }
}

class _StudentStatsRow extends StatelessWidget {
  const _StudentStatsRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final store = StudentRankingStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final summary = store.summary;

        return Row(
          children: [
            Expanded(
              child: _StatChip(
                label: l10n.attendancePercent,
                value: summary != null
                    ? '${summary.attendancePercent}%'
                    : '—',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatChip(
                label: l10n.currentRank,
                value: summary != null && summary.classRank > 0
                    ? '#${summary.classRank}'
                    : '—',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatChip(
                label: l10n.latestScore,
                value: summary != null
                    ? summary.finalScore.toStringAsFixed(0)
                    : '—',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.55),
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
