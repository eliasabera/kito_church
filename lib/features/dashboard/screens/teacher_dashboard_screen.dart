import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/dashboard/data/teacher_dashboard_data.dart';
import 'package:kitoapp/features/dashboard/widgets/teacher_home_hero.dart';
import 'package:kitoapp/features/dashboard/widgets/teacher_stats_bar.dart';
import 'package:kitoapp/features/dashboard/widgets/teacher_today_classes.dart';
import 'package:kitoapp/features/profile/data/profile_data.dart';

class TeacherDashboardContent extends StatelessWidget {
  const TeacherDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileData.teacher;

    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.03),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeacherHomeHero(
              teacherName: profile.fullName,
              department: profile.department,
            ),
            const SizedBox(height: 18),
            TeacherStatsBar(stats: TeacherDashboardData.stats),
            const SizedBox(height: 22),
            TeacherTodayClasses(sessions: TeacherDashboardData.todayClasses),
          ],
        ),
      ),
    );
  }
}
