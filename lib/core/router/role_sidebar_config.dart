import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class RoleSidebarItem {
  const RoleSidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.section,
  });

  final String label;
  final IconData icon;
  final String route;
  final String? section;
}

/// Sidebar shows extra features only — main tabs live in the bottom nav.
List<RoleSidebarItem> roleSidebarItems(UserRole role, AppLocalizations l10n) {
  return switch (role) {
    UserRole.student => [
      RoleSidebarItem(
        label: l10n.dailyVerse,
        icon: Icons.menu_book_outlined,
        route: StudentRoutes.dailyVerse,
        section: l10n.sidebarFaithLearning,
      ),
      RoleSidebarItem(
        label: l10n.attendance,
        icon: Icons.event_available_outlined,
        route: StudentRoutes.attendance,
        section: l10n.sidebarFaithLearning,
      ),
      RoleSidebarItem(
        label: l10n.gifts,
        icon: Icons.card_giftcard_outlined,
        route: StudentRoutes.gifts,
        section: l10n.sidebarCompassion,
      ),
      RoleSidebarItem(
        label: l10n.sponsorship,
        icon: Icons.favorite_outline,
        route: StudentRoutes.sponsorship,
        section: l10n.sidebarCompassion,
      ),
      RoleSidebarItem(
        label: l10n.notifications,
        icon: Icons.notifications_outlined,
        route: StudentRoutes.notifications,
        section: l10n.sidebarCommunity,
      ),
      RoleSidebarItem(
        label: l10n.announcements,
        icon: Icons.campaign_outlined,
        route: StudentRoutes.announcements,
        section: l10n.sidebarCommunity,
      ),
      RoleSidebarItem(
        label: l10n.prayerRequests,
        icon: Icons.volunteer_activism_outlined,
        route: StudentRoutes.prayerRequests,
        section: l10n.sidebarCommunity,
      ),
    ],
    UserRole.teacher => [
      RoleSidebarItem(
        label: l10n.assignments,
        icon: Icons.assignment_outlined,
        route: TeacherRoutes.assignments,
        section: l10n.sidebarTeaching,
      ),
      RoleSidebarItem(
        label: l10n.quizzes,
        icon: Icons.quiz_outlined,
        route: TeacherRoutes.quizzes,
        section: l10n.sidebarTeaching,
      ),
      RoleSidebarItem(
        label: l10n.studentPerformance,
        icon: Icons.insights_outlined,
        route: TeacherRoutes.performance,
        section: l10n.sidebarTeaching,
      ),
      RoleSidebarItem(
        label: l10n.announcements,
        icon: Icons.campaign_outlined,
        route: TeacherRoutes.announcements,
        section: l10n.sidebarCommunity,
      ),
      RoleSidebarItem(
        label: l10n.prayerRequests,
        icon: Icons.volunteer_activism_outlined,
        route: TeacherRoutes.prayerRequests,
        section: l10n.sidebarCommunity,
      ),
    ],
    UserRole.admin => [
      RoleSidebarItem(
        label: l10n.uploadVerse,
        icon: Icons.menu_book_outlined,
        route: AdminRoutes.dailyVerse,
        section: l10n.sidebarAdminTools,
      ),
      RoleSidebarItem(
        label: l10n.manageBibleStories,
        icon: Icons.auto_stories_outlined,
        route: AdminRoutes.bibleStories,
        section: l10n.sidebarAdminTools,
      ),
      RoleSidebarItem(
        label: l10n.manageGifts,
        icon: Icons.card_giftcard_outlined,
        route: AdminRoutes.gifts,
        section: l10n.sidebarCompassion,
      ),
      RoleSidebarItem(
        label: l10n.manageSponsorship,
        icon: Icons.favorite_outline,
        route: AdminRoutes.sponsorship,
        section: l10n.sidebarCompassion,
      ),
      RoleSidebarItem(
        label: l10n.notifications,
        icon: Icons.notifications_outlined,
        route: AdminRoutes.notifications,
        section: l10n.sidebarCommunity,
      ),
      RoleSidebarItem(
        label: l10n.createAnnouncement,
        icon: Icons.campaign_outlined,
        route: AdminRoutes.announcements,
        section: l10n.sidebarCommunity,
      ),
      RoleSidebarItem(
        label: l10n.generateCertificate,
        icon: Icons.workspace_premium_outlined,
        route: AdminRoutes.certificates,
        section: l10n.sidebarAdminTools,
      ),
    ],
  };
}

String roleLabel(UserRole role, AppLocalizations l10n) {
  return switch (role) {
    UserRole.student => l10n.student,
    UserRole.teacher => l10n.teacher,
    UserRole.admin => l10n.admin,
  };
}

List<({String section, List<RoleSidebarItem> items})> groupedSidebarItems(
  UserRole role,
  AppLocalizations l10n,
) {
  final items = roleSidebarItems(role, l10n);
  final map = <String, List<RoleSidebarItem>>{};

  for (final item in items) {
    final section = item.section ?? l10n.menuMore;
    map.putIfAbsent(section, () => []).add(item);
  }

  return map.entries
      .map((entry) => (section: entry.key, items: entry.value))
      .toList();
}
