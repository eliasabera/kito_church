import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_store.dart';
import 'package:kitoapp/features/learning/widgets/post_lesson_sheet.dart';
import 'package:kitoapp/features/learning/widgets/teacher_lesson_filter_bar.dart';
import 'package:kitoapp/features/learning/widgets/teacher_lesson_tile.dart';
import 'package:kitoapp/features/learning/widgets/teacher_lessons_summary_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

class TeacherClassesContent extends StatefulWidget {
  const TeacherClassesContent({super.key});

  @override
  State<TeacherClassesContent> createState() => _TeacherClassesContentState();
}

class _TeacherClassesContentState extends State<TeacherClassesContent> {
  TeacherLessonFilter _filter = TeacherLessonFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = TeacherLessonsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final lessons = store.lessonsFor(_filter);

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TeacherLessonsSummaryCard(summary: store.summary),
                  ),
                  TeacherLessonFilterBar(
                    value: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.allLessons,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: lessons.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n.noLessons,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.text.withValues(alpha: 0.45),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                            itemCount: lessons.length,
                            itemBuilder: (context, index) {
                              return TeacherLessonTile(lesson: lessons[index]);
                            },
                          ),
                  ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: () => showPostLessonSheet(context),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.postLesson),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
