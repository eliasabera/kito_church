import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class RoleNavItem {
  const RoleNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

List<RoleNavItem> roleNavItems(UserRole role, AppLocalizations l10n) {
  return switch (role) {
    UserRole.student => [
      RoleNavItem(
        label: l10n.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      RoleNavItem(
        label: l10n.learning,
        icon: Icons.school_outlined,
        selectedIcon: Icons.school,
      ),
      RoleNavItem(
        label: l10n.ranking,
        icon: Icons.leaderboard_outlined,
        selectedIcon: Icons.leaderboard,
      ),
      RoleNavItem(
        label: l10n.profile,
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
    ],
    UserRole.teacher => [
      RoleNavItem(
        label: l10n.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      RoleNavItem(
        label: l10n.myClasses,
        icon: Icons.class_outlined,
        selectedIcon: Icons.class_,
      ),
      RoleNavItem(
        label: l10n.attendance,
        icon: Icons.event_available_outlined,
        selectedIcon: Icons.event_available,
      ),
      RoleNavItem(
        label: l10n.profile,
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
    ],
    UserRole.admin => [
      RoleNavItem(
        label: l10n.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      RoleNavItem(
        label: l10n.manageUsers,
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
      ),
      RoleNavItem(
        label: l10n.reports,
        icon: Icons.summarize_outlined,
        selectedIcon: Icons.summarize,
      ),
      RoleNavItem(
        label: l10n.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
      ),
    ],
  };
}

String shellRootForRole(UserRole role) {
  return switch (role) {
    UserRole.student => '/student',
    UserRole.teacher => '/teacher',
    UserRole.admin => '/admin',
  };
}

UserRole? roleFromPath(String path) {
  if (path.startsWith('/student')) return UserRole.student;
  if (path.startsWith('/teacher')) return UserRole.teacher;
  if (path.startsWith('/admin')) return UserRole.admin;
  return null;
}
