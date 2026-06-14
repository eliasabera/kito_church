import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/dashboard/services/student_home_loader.dart';
import 'package:kitoapp/features/learning/widgets/learning_path_road.dart';
import 'package:kitoapp/features/learning/widgets/learning_stats_bar.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/attendance_store_provider.dart';
import 'package:kitoapp/shared/widgets/learning_progress_provider.dart';
import 'package:kitoapp/shared/widgets/student_learning_catalog_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_assessments_store_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

class StudentLearningContent extends StatefulWidget {
  const StudentLearningContent({super.key});

  @override
  State<StudentLearningContent> createState() => _StudentLearningContentState();
}

class _StudentLearningContentState extends State<StudentLearningContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLearningData());
  }

  Future<void> _loadLearningData() async {
    await loadStudentLearningData(
      lessonsStore: TeacherLessonsStoreProvider.of(context),
      assessmentsStore: TeacherAssessmentsStoreProvider.of(context),
      progressStore: LearningProgressProvider.of(context),
      attendanceStore: AttendanceStoreProvider.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progressStore = LearningProgressProvider.of(context);
    final catalogStore = StudentLearningCatalogProvider.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([progressStore, catalogStore]),
      builder: (context, _) {
        final isLoading =
            catalogStore.isLoading || progressStore.isLoading;
        final weeks = progressStore.weeks;

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _loadLearningData,
            child: isLoading && weeks.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ],
                  )
                : weeks.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              l10n.noLearningItems,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.text.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          LearningStatsBar(stats: progressStore.stats),
                          const Expanded(child: LearningPathRoad()),
                        ],
                      ),
          ),
        );
      },
    );
  }
}
