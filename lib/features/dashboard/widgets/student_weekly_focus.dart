import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

class StudentWeeklyFocus extends StatelessWidget {
  const StudentWeeklyFocus({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = TeacherLessonsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final published = store.publishedLessons;
        final focusLesson = published.isEmpty ? null : published.first;

        if (store.isLoading && focusLesson == null) {
          return _WeeklyFocusShell(
            onTap: null,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (focusLesson == null) {
          return _WeeklyFocusShell(
            onTap: () => context.go(StudentRoutes.learning),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.noLessons,
                style: TextStyle(
                  color: AppColors.text.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ),
          );
        }

        final subtitle = focusLesson.description?.trim().isNotEmpty == true
            ? focusLesson.description!.trim()
            : l10n.weeklyLessonSubtitle;

        return _WeeklyFocusShell(
          onTap: () => context.go(StudentRoutes.learning),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.auto_stories_outlined,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                    Container(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                    Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: AppColors.background.withValues(alpha: 0.9),
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.thisWeek,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        focusLesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.55),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            l10n.continueLearning,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_forward,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyFocusShell extends StatelessWidget {
  const _WeeklyFocusShell({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
