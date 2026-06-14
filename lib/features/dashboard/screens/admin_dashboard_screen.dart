import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/dashboard/widgets/admin_featured_verse.dart';
import 'package:kitoapp/features/dashboard/widgets/admin_home_hero.dart';
import 'package:kitoapp/features/dashboard/widgets/admin_platform_overview.dart';
import 'package:kitoapp/features/profile/data/profile_data.dart';
import 'package:kitoapp/shared/widgets/admin_dashboard_store_provider.dart';

class AdminDashboardContent extends StatefulWidget {
  const AdminDashboardContent({super.key});

  @override
  State<AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<AdminDashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminDashboardStoreProvider.of(context).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AdminDashboardStoreProvider.of(context);

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
        final adminName = admin?.fullName ?? fallback.fullName;
        final department = admin?.department ?? fallback.department;

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            onRefresh: store.load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminHomeHero(
                    adminName: adminName,
                    department: department,
                  ),
                  const SizedBox(height: 20),
                  AdminPlatformOverview(stats: store.stats),
                  const SizedBox(height: 22),
                  const AdminFeaturedVerse(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
