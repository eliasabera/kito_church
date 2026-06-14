import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/constants/app_info.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/widgets/admin_settings_hero.dart';
import 'package:kitoapp/features/profile/data/profile_data.dart';
import 'package:kitoapp/features/profile/widgets/profile_section_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/admin_settings_store_provider.dart';
import 'package:kitoapp/shared/widgets/locale_notifier_provider.dart';

class AdminSettingsContent extends StatefulWidget {
  const AdminSettingsContent({super.key});

  @override
  State<AdminSettingsContent> createState() => _AdminSettingsContentState();
}

class _AdminSettingsContentState extends State<AdminSettingsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminSettingsStoreProvider.of(context).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = LocaleNotifierProvider.of(context);
    final currentCode = localeNotifier.locale.languageCode;
    final store = AdminSettingsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.admin == null) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final admin = store.admin;
        final fallback = ProfileData.admin;
        final name = admin?.fullName ?? fallback.fullName;
        final email = admin?.email ?? fallback.email;
        final department = admin?.department ?? fallback.department ?? l10n.admin;
        final phone = admin?.phone ?? fallback.phone;
        final initials = name
            .trim()
            .split(RegExp(r'\s+'))
            .map((part) => part.isNotEmpty ? part[0] : '')
            .take(2)
            .join()
            .toUpperCase();
        final settings = store.settings;

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            onRefresh: store.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const AdminSettingsHero(),
                const SizedBox(height: 18),
                _AdminAccountCard(
                  initials: initials,
                  name: name,
                  email: email,
                  department: department,
                ),
                const SizedBox(height: 14),
                ProfileSectionCard(
                  title: l10n.personalInfo,
                  children: [
                    ProfileInfoRow(
                      icon: Icons.email_outlined,
                      label: l10n.email,
                      value: email,
                    ),
                    if (phone != null)
                      ProfileInfoRow(
                        icon: Icons.phone_outlined,
                        label: l10n.phoneNumber,
                        value: phone,
                      ),
                    if (department.isNotEmpty)
                      ProfileInfoRow(
                        icon: Icons.business_outlined,
                        label: l10n.department,
                        value: department,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ProfileSectionCard(
                  title: l10n.preferences,
                  children: [
                    Text(
                      l10n.language,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ProfileLanguageOption(
                      label: l10n.english,
                      selected: currentCode == 'en',
                      onTap: () => localeNotifier.setLocale(const Locale('en')),
                    ),
                    ProfileLanguageOption(
                      label: l10n.amharic,
                      selected: currentCode == 'am',
                      onTap: () => localeNotifier.setLocale(const Locale('am')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProfileSectionCard(
                  title: l10n.platformSettings,
                  children: [
                    _SettingsToggle(
                      icon: Icons.notifications_outlined,
                      label: l10n.pushNotifications,
                      value: settings.pushNotifications,
                      onChanged: store.setPushNotifications,
                    ),
                    _SettingsToggle(
                      icon: Icons.mail_outline,
                      label: l10n.emailAlerts,
                      value: settings.emailAlerts,
                      onChanged: store.setEmailAlerts,
                    ),
                    _SettingsToggle(
                      icon: Icons.pending_actions_outlined,
                      label: l10n.pendingApprovalAlerts,
                      value: settings.pendingApprovalAlerts,
                      onChanged: store.setPendingApprovalAlerts,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProfileSectionCard(
                  title: l10n.aboutApp,
                  children: [
                    ProfileInfoRow(
                      icon: Icons.church_outlined,
                      label: l10n.appTitle,
                      value: l10n.appTitle,
                    ),
                    ProfileInfoRow(
                      icon: Icons.info_outline,
                      label: l10n.appVersion,
                      value: AppInfo.versionLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.login),
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
}

class _AdminAccountCard extends StatelessWidget {
  const _AdminAccountCard({
    required this.initials,
    required this.name,
    required this.email,
    required this.department,
  });

  final String initials;
  final String name;
  final String email;
  final String department;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF004A85)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.background.withValues(alpha: 0.3),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: AppColors.background.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    department,
                    style: TextStyle(
                      color: AppColors.background.withValues(alpha: 0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.background.withValues(alpha: 0.7),
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            activeThumbColor: AppColors.background,
          ),
        ],
      ),
    );
  }
}
