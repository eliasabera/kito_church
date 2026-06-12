import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/shared/widgets/app_bottom_nav_bar.dart';
import 'package:kitoapp/shared/widgets/role_sidebar.dart';

class RoleShellScaffold extends StatelessWidget {
  const RoleShellScaffold({
    super.key,
    required this.role,
    required this.navigationShell,
  });

  final UserRole role;
  final StatefulNavigationShell navigationShell;

  static const double _sidebarBreakpoint = 720;

  @override
  Widget build(BuildContext context) {
    final usePermanentSidebar =
        MediaQuery.sizeOf(context).width >= _sidebarBreakpoint;

    final bottomNav = AppBottomNavBar(
      role: role,
      currentIndex: navigationShell.currentIndex,
      onTap: navigationShell.goBranch,
    );

    final body = Column(
      children: [
        Expanded(child: navigationShell),
        bottomNav,
      ],
    );

    if (usePermanentSidebar) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            RoleSidebar(role: role),
            const VerticalDivider(
              width: 1,
              color: Color(0xFFE0E0E0),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: navigationShell),
                  bottomNav,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: RoleSidebar(
          role: role,
          onNavigate: () => Navigator.of(context).pop(),
        ),
      ),
      appBar: const _ShellAppBar(),
      body: body,
    );
  }
}

class _ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ShellAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }
}
