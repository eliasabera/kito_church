import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/data/teacher_teaching_data.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';
import 'package:kitoapp/features/learning/widgets/teacher_assessment_filter_bar.dart';
import 'package:kitoapp/features/learning/widgets/teacher_performance_summary_card.dart';
import 'package:kitoapp/features/learning/widgets/teacher_student_performance_tile.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';

class TeacherPerformanceContent extends StatefulWidget {
  const TeacherPerformanceContent({super.key});

  @override
  State<TeacherPerformanceContent> createState() =>
      _TeacherPerformanceContentState();
}

class _TeacherPerformanceContentState extends State<TeacherPerformanceContent> {
  TeacherPerformanceFilter _filter = TeacherPerformanceFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = TeacherTeachingData.performanceSummary;
    final entries = TeacherTeachingData.performanceFor(_filter);

    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TeacherPerformanceSummaryCard(summary: summary),
          ),
          TeacherPerformanceFilterBar(
            value: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  l10n.leaderboard,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.studentsCount(entries.length),
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.noPerformanceData,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.45),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return TeacherStudentPerformanceTile(
                        entry: entries[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TeacherPerformanceScreen extends StatelessWidget {
  const TeacherPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.studentPerformance,
      body: const TeacherPerformanceContent(),
    );
  }
}
