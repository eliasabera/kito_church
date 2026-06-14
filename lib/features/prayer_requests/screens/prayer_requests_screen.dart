import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/router/role_nav_config.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/prayer_requests/widgets/prayer_request_tile.dart';
import 'package:kitoapp/features/prayer_requests/widgets/prayer_summary_card.dart';
import 'package:kitoapp/features/prayer_requests/widgets/submit_prayer_card.dart';
import 'package:kitoapp/features/profile/data/profile_data.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/prayer_requests_store_provider.dart';
import 'package:kitoapp/shared/widgets/profile_store_provider.dart';

class PrayerRequestsContent extends StatefulWidget {
  const PrayerRequestsContent({super.key});

  @override
  State<PrayerRequestsContent> createState() => _PrayerRequestsContentState();
}

class _PrayerRequestsContentState extends State<PrayerRequestsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PrayerRequestsStoreProvider.of(context).loadFromSupabase();
    });
  }

  UserRole? _role(BuildContext context) {
    return roleFromPath(GoRouterState.of(context).uri.path);
  }

  String _authorName(UserRole role) {
    final profile = ProfileStoreProvider.of(context).profile;
    if (profile != null) return profile.fullName;
    return ProfileData.forRole(role).fullName;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final role = _role(context) ?? UserRole.student;
    final isTeacher = role == UserRole.teacher;
    final store = PrayerRequestsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.requests.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final requests = store.requests;
        final summary = store.summary;

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            onRefresh: store.loadFromSupabase,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                PrayerSummaryCard(
                  summary: summary,
                  totalLabel: isTeacher
                      ? l10n.studentPrayerRequests
                      : l10n.prayerRequests,
                ),
                const SizedBox(height: 12),
                if (!isTeacher) ...[
                  SubmitPrayerCard(
                    onSubmit: (message) async {
                      try {
                        await store.submitRequest(
                          message: message,
                          authorName: _authorName(role),
                          authorId: AuthSession.userId,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.prayerRequestSubmitted),
                          ),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.prayerRequestSubmitFailed),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.teacherPrayerViewHint,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                Text(
                  isTeacher ? l10n.studentPrayerRequests : l10n.prayerRequests,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (requests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        l10n.noPrayerRequests,
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.45),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...requests.map(
                    (request) => PrayerRequestTile(
                      request: request,
                      role: role,
                      showAuthor: true,
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

class PrayerRequestsScreen extends StatelessWidget {
  const PrayerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.prayerRequests,
      body: const PrayerRequestsContent(),
    );
  }
}
