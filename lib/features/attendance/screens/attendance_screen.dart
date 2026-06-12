import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/core/router/role_nav_config.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/attendance/models/attendance_session.dart';
import 'package:kitoapp/features/attendance/screens/teacher_attendance_content.dart';
import 'package:kitoapp/features/attendance/widgets/attendance_heatmap.dart';
import 'package:kitoapp/features/attendance/widgets/attendance_stats_bar.dart';
import 'package:kitoapp/features/attendance/widgets/attendance_summary_card.dart';
import 'package:kitoapp/features/attendance/widgets/pending_makeup_banner.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/attendance_store_provider.dart';

class AttendanceContent extends StatelessWidget {
  const AttendanceContent({super.key});

  UserRole? _role(BuildContext context) {
    return roleFromPath(GoRouterState.of(context).uri.path);
  }

  @override
  Widget build(BuildContext context) {
    final role = _role(context);
    if (role == UserRole.teacher) {
      return const TeacherAttendanceContent();
    }
    return _StudentAttendanceContent(role: role);
  }
}

class _StudentAttendanceContent extends StatelessWidget {
  const _StudentAttendanceContent({required this.role});

  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final store = AttendanceStoreProvider.of(context);
    final isStudent = role == UserRole.student;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final summary = store.summary;
        final pending =
            isStudent ? store.pendingMakeupSessions : <AttendanceSession>[];

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: AttendanceSummaryCard(summary: summary),
                ),
                if (isStudent && pending.isNotEmpty)
                  PendingMakeupBanner(sessions: pending),
                AttendanceStatsBar(summary: summary),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AttendanceHeatmap(
                    cells: store.heatmapCells,
                    onCellTap: isStudent
                        ? (cell) => _onHeatmapCellTap(context, cell)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onHeatmapCellTap(BuildContext context, HeatmapCell cell) {
    if (cell.status != WeekAttendanceStatus.pending || cell.sessionId == null) {
      return;
    }
    context.go(StudentRoutes.learning);
  }
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.attendance,
      body: const AttendanceContent(),
    );
  }
}
