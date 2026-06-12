import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';
import 'package:kitoapp/features/learning/widgets/edit_assignment_sheet.dart';
import 'package:kitoapp/features/learning/widgets/teacher_assessment_filter_bar.dart';
import 'package:kitoapp/features/learning/widgets/teacher_assignment_detail_sheet.dart';
import 'package:kitoapp/features/learning/widgets/teacher_assignment_tile.dart';
import 'package:kitoapp/features/learning/widgets/teacher_assignments_summary_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/teacher_assessments_store_provider.dart';

class TeacherAssignmentsContent extends StatefulWidget {
  const TeacherAssignmentsContent({super.key});

  @override
  State<TeacherAssignmentsContent> createState() =>
      _TeacherAssignmentsContentState();
}

class _TeacherAssignmentsContentState extends State<TeacherAssignmentsContent> {
  TeacherAssessmentFilter _filter = TeacherAssessmentFilter.all;

  void _openEditor(TeacherAssignment assignment) {
    final store = TeacherAssessmentsStoreProvider.of(context);
    final existing = store.assignmentContentFor(assignment.lessonId);
    showEditAssignmentSheet(
      context,
      lessonId: assignment.lessonId,
      existing: existing,
    );
  }

  void _openSubmissions(TeacherAssignment assignment) {
    final store = TeacherAssessmentsStoreProvider.of(context);
    if (!assignment.isConfigured) {
      _openEditor(assignment);
      return;
    }
    TeacherAssignmentDetailSheet.show(
      context,
      assignment: assignment,
      submissions: store.submissionsForAssignment(assignment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = TeacherAssessmentsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final summary = store.assignmentsSummary;
        final assignments = store.assignmentsFor(_filter);

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TeacherAssignmentsSummaryCard(summary: summary),
                  ),
                  TeacherAssessmentFilterBar(
                    value: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.allAssignments,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: assignments.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n.noAssignments,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      AppColors.text.withValues(alpha: 0.45),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                            itemCount: assignments.length,
                            itemBuilder: (context, index) {
                              final assignment = assignments[index];
                              return TeacherAssignmentTile(
                                assignment: assignment,
                                onTap: () => _openSubmissions(assignment),
                                onEdit: () => _openEditor(assignment),
                              );
                            },
                          ),
                  ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: () => showEditAssignmentSheet(context),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createAssignment),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TeacherAssignmentsScreen extends StatelessWidget {
  const TeacherAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.assignments,
      body: const TeacherAssignmentsContent(),
    );
  }
}
