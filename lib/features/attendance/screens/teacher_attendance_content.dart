import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/attendance/widgets/teacher_attendance_header.dart';
import 'package:kitoapp/features/attendance/widgets/teacher_student_attendance_tile.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/teacher_attendance_store_provider.dart';

class TeacherAttendanceContent extends StatefulWidget {
  const TeacherAttendanceContent({super.key});

  @override
  State<TeacherAttendanceContent> createState() =>
      _TeacherAttendanceContentState();
}

class _TeacherAttendanceContentState extends State<TeacherAttendanceContent> {
  bool _headerExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TeacherAttendanceStoreProvider.of(context).loadFromSupabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = TeacherAttendanceStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.sessions.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final session = store.selectedSession;
        if (session == null) {
          return ColoredBox(
            color: AppColors.primary.withValues(alpha: 0.03),
            child: RefreshIndicator(
              onRefresh: store.loadFromSupabase,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.noAttendanceRecords,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.text.withValues(alpha: 0.45),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final summary = store.sessionSummary;
        final canEdit = store.canEditSelectedSession;

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            onRefresh: store.loadFromSupabase,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TeacherAttendanceHeader(
                  sessions: store.sessions,
                  selectedSession: session,
                  summary: summary,
                  expanded: _headerExpanded,
                  onToggleExpanded: () =>
                      setState(() => _headerExpanded = !_headerExpanded),
                  onSessionSelected: store.selectSession,
                  onPreviousSession: store.selectOlderSession,
                  onNextSession: store.selectNewerSession,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        l10n.studentAttendance,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.studentsCount(summary.total),
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.markAttendanceHint,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: session.students.length,
                    itemBuilder: (context, index) {
                      final student = session.students[index];
                      return TeacherStudentAttendanceTile(
                        student: student,
                        readOnly: !canEdit,
                        onMark: (status) =>
                            store.markStudent(student.id, status),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
