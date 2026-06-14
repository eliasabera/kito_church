import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/attendance/models/attendance_session.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/attendance_store_provider.dart';
import 'package:kitoapp/shared/widgets/student_learning_catalog_provider.dart';

class MakeupAttendanceScreen extends StatelessWidget {
  const MakeupAttendanceScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = AttendanceStoreProvider.of(context);
    final session = store.sessionById(sessionId);

    if (session == null) {
      return AppScaffold(
        title: l10n.makeUpAttendance,
        body: Center(child: Text(l10n.noAttendanceRecords)),
      );
    }

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final current = store.sessionById(sessionId)!;
        return AppScaffold(
          title: l10n.makeUpAttendance,
          body: _MakeupBody(session: current),
        );
      },
    );
  }
}

class _MakeupBody extends StatelessWidget {
  const _MakeupBody({required this.session});

  final AttendanceSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = AttendanceStoreProvider.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.yMMMd(locale).format(session.sessionDate);
    final content = session.lessonId == null
        ? ''
        : StudentLearningCatalogProvider.of(context)
            .lessonContentFor(session.lessonId!);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SessionInfoCard(
                  sessionLabel: session.sessionLabel,
                  dateLabel: dateLabel,
                  lessonTitle: session.lessonTitle ?? '',
                ),
                const SizedBox(height: 16),
                _StepIndicator(
                  stepOneDone: session.lessonCompleted,
                  stepTwoDone: session.onlineMarked,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.stepReadLesson,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
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
                if (!session.lessonCompleted) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.completeLessonToMark,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!session.lessonCompleted)
                  FilledButton.icon(
                    onPressed: () => store.markLessonComplete(session.id),
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: Text(l10n.markLessonComplete),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary.withValues(alpha: 0.8),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.lessonCompleted,
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.stepMarkAttendance,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: session.canMarkOnline
                        ? () {
                            store.markOnlineAttendance(session.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.attendanceMarkedSuccess)),
                            );
                            context.pop();
                          }
                        : null,
                    icon: const Icon(Icons.how_to_reg_outlined, size: 18),
                    label: Text(l10n.markOnlineAttendance),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionInfoCard extends StatelessWidget {
  const _SessionInfoCard({
    required this.sessionLabel,
    required this.dateLabel,
    required this.lessonTitle,
  });

  final String sessionLabel;
  final String dateLabel;
  final String lessonTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sessionLabel,
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: TextStyle(
              color: AppColors.background.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                size: 16,
                color: AppColors.background.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lessonTitle,
                  style: TextStyle(
                    color: AppColors.background.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.stepOneDone,
    required this.stepTwoDone,
  });

  final bool stepOneDone;
  final bool stepTwoDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _StepChip(
            label: l10n.stepReadLesson,
            done: stepOneDone,
            active: !stepOneDone,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StepChip(
            label: l10n.stepMarkAttendance,
            done: stepTwoDone,
            active: stepOneDone && !stepTwoDone,
          ),
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.label,
    required this.done,
    required this.active,
  });

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? const Color(0xFF2E7D32)
        : active
            ? AppColors.primary
            : AppColors.text.withValues(alpha: 0.35);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active || done ? color : AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
