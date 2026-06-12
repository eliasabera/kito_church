import 'package:flutter/material.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/dashboard_tile.dart';

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${l10n.welcome}, ${l10n.admin}!'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatChip(label: l10n.totalStudents, value: '—'),
              _StatChip(label: l10n.totalTeachers, value: '—'),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                DashboardTile(
                  title: l10n.scoringSystem,
                  icon: Icons.tune_outlined,
                  route: AdminRoutes.scoring,
                ),
                DashboardTile(
                  title: l10n.uploadVerse,
                  icon: Icons.menu_book_outlined,
                  route: AdminRoutes.dailyVerse,
                ),
                DashboardTile(
                  title: l10n.manageGifts,
                  icon: Icons.card_giftcard_outlined,
                  route: AdminRoutes.gifts,
                ),
                DashboardTile(
                  title: l10n.manageSponsorship,
                  icon: Icons.favorite_outline,
                  route: AdminRoutes.sponsorship,
                ),
                DashboardTile(
                  title: l10n.createAnnouncement,
                  icon: Icons.campaign_outlined,
                  route: AdminRoutes.announcements,
                ),
                DashboardTile(
                  title: l10n.generateCertificate,
                  icon: Icons.workspace_premium_outlined,
                  route: AdminRoutes.certificates,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
