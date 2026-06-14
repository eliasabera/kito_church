import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';
import 'package:kitoapp/features/learning/widgets/edit_quiz_sheet.dart';
import 'package:kitoapp/features/learning/widgets/teacher_assessment_filter_bar.dart';
import 'package:kitoapp/features/learning/widgets/teacher_quiz_tile.dart';
import 'package:kitoapp/features/learning/widgets/teacher_quizzes_summary_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/teacher_assessments_store_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

class TeacherQuizzesContent extends StatefulWidget {
  const TeacherQuizzesContent({super.key});

  @override
  State<TeacherQuizzesContent> createState() => _TeacherQuizzesContentState();
}

class _TeacherQuizzesContentState extends State<TeacherQuizzesContent> {
  TeacherAssessmentFilter _filter = TeacherAssessmentFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TeacherLessonsStoreProvider.of(context).loadFromSupabase();
      if (!mounted) return;
      await TeacherAssessmentsStoreProvider.of(context).loadFromSupabase();
    });
  }

  void _openEditor(TeacherQuiz quiz) {
    final store = TeacherAssessmentsStoreProvider.of(context);
    final existing = store.quizContentFor(quiz.lessonId);
    showEditQuizSheet(
      context,
      lessonId: quiz.lessonId,
      existing: existing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = TeacherAssessmentsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.quizzes.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final summary = store.quizzesSummary;
        final quizzes = store.quizzesFor(_filter);

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TeacherQuizzesSummaryCard(summary: summary),
                  ),
                  TeacherAssessmentFilterBar(
                    value: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.allQuizzes,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: quizzes.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n.noQuizzes,
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
                            itemCount: quizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = quizzes[index];
                              return TeacherQuizTile(
                                quiz: quiz,
                                onTap: () => _openEditor(quiz),
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
                  onPressed: () => showEditQuizSheet(context),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createQuiz),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TeacherQuizzesScreen extends StatelessWidget {
  const TeacherQuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.quizzes,
      body: const TeacherQuizzesContent(),
    );
  }
}
