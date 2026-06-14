import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/dashboard/widgets/teacher_home_hero.dart';
import 'package:kitoapp/features/dashboard/widgets/teacher_stats_bar.dart';
import 'package:kitoapp/features/dashboard/widgets/teacher_today_classes.dart';
import 'package:kitoapp/shared/widgets/teacher_dashboard_store_provider.dart';

class TeacherDashboardContent extends StatefulWidget {
  const TeacherDashboardContent({super.key});

  @override
  State<TeacherDashboardContent> createState() =>
      _TeacherDashboardContentState();
}

class _TeacherDashboardContentState extends State<TeacherDashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TeacherDashboardStoreProvider.of(context).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = TeacherDashboardStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.teacher == null) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final teacher = store.teacher;
        final teacherName = teacher?.fullName ?? 'Teacher';

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
                  TeacherHomeHero(
                    teacherName: teacherName,
                    department: teacher?.department,
                  ),
                  const SizedBox(height: 18),
                  TeacherStatsBar(stats: store.stats),
                  const SizedBox(height: 22),
                  TeacherTodayClasses(sessions: store.todayClasses),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
