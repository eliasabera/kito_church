import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/data/student_learning_data.dart';
import 'package:kitoapp/features/learning/services/learning_progress_store.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/learning_progress_provider.dart';

class LessonReaderScreen extends StatefulWidget {
  const LessonReaderScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<LessonReaderScreen> createState() => _LessonReaderScreenState();
}

class _LessonReaderScreenState extends State<LessonReaderScreen> {
  final _scrollController = ScrollController();
  Timer? _timer;
  LearningProgressStore? _store;
  bool _lessonStarted = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = LearningProgressProvider.of(context);
    if (_lessonStarted) return;
    _lessonStarted = true;
    _store!.beginLesson(widget.itemId);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _store?.addLessonTime(widget.itemId);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _store == null) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) {
      _store!.updateLessonScroll(widget.itemId, 1);
      return;
    }
    final progress = _scrollController.offset / max;
    _store!.updateLessonScroll(widget.itemId, progress);
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_lessonStarted) {
      _store?.endLesson(widget.itemId);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _completeLesson(LearningProgressStore store) {
    final l10n = AppLocalizations.of(context);
    store.completeLesson(widget.itemId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.lessonCompletedSuccess)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = StudentLearningData.findById(widget.itemId);

    if (item == null) {
      return AppScaffold(
        title: l10n.lessons,
        body: Center(child: Text(l10n.noLearningItems)),
      );
    }

    final content = StudentLearningData.lessonContentFor(widget.itemId);
    final store = LearningProgressProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final progress = store.lessonProgress(widget.itemId);
        final timeProgress =
            (progress.timeSpentSeconds / LearningProgressStore.minLessonSeconds)
                .clamp(0.0, 1.0);
        final canComplete = store.canCompleteLesson(widget.itemId);
        final alreadyDone = progress.isCompleted;

        return AppScaffold(
          title: l10n.lessonReader,
          body: Column(
            children: [
              _LessonProgressBar(
                timeSpent: progress.timeSpentSeconds,
                timeProgress: timeProgress,
                scrollProgress: progress.scrollProgress,
                isCompleted: alreadyDone,
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      _onScroll();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${l10n.teacherName}: ${item.teacherName}',
                          style: TextStyle(
                            color: AppColors.text.withValues(alpha: 0.55),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            content,
                            style: TextStyle(
                              color: AppColors.text.withValues(alpha: 0.85),
                              fontSize: 15,
                              height: 1.65,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!alreadyDone)
                _LessonCompleteFooter(
                  canComplete: canComplete,
                  timeSpent: progress.timeSpentSeconds,
                  scrollProgress: progress.scrollProgress,
                  onComplete: () => _completeLesson(store),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LessonProgressBar extends StatelessWidget {
  const _LessonProgressBar({
    required this.timeSpent,
    required this.timeProgress,
    required this.scrollProgress,
    required this.isCompleted,
  });

  final int timeSpent;
  final double timeProgress;
  final double scrollProgress;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MetricChip(
                icon: Icons.timer_outlined,
                label: l10n.timeSpent(timeSpent),
                progress: timeProgress,
                done: timeProgress >= 1,
              ),
              const SizedBox(width: 8),
              _MetricChip(
                icon: Icons.vertical_align_bottom,
                label: l10n.readingProgress(
                  (scrollProgress * 100).round(),
                ),
                progress: scrollProgress,
                done: scrollProgress >= LearningProgressStore.minScrollProgress,
              ),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  l10n.lessonCompleted,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.progress,
    required this.done,
  });

  final IconData icon;
  final String label;
  final double progress;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done ? const Color(0xFF004A85) : AppColors.primary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (done)
                  Icon(Icons.check, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: color.withValues(alpha: 0.15),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonCompleteFooter extends StatelessWidget {
  const _LessonCompleteFooter({
    required this.canComplete,
    required this.timeSpent,
    required this.scrollProgress,
    required this.onComplete,
  });

  final bool canComplete;
  final int timeSpent;
  final double scrollProgress;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final needsTime =
        timeSpent < LearningProgressStore.minLessonSeconds;
    final needsScroll =
        scrollProgress < LearningProgressStore.minScrollProgress;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!canComplete)
              Text(
                needsTime && needsScroll
                    ? l10n.lessonCompleteRequirements
                    : needsTime
                        ? l10n.keepReadingTime(
                            LearningProgressStore.minLessonSeconds - timeSpent,
                          )
                        : l10n.keepReadingScroll,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
            if (!canComplete) const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: canComplete ? onComplete : null,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(l10n.completeLesson),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.3),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
