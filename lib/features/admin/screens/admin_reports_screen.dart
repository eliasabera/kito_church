import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/services/admin_report_pdf_service.dart';
import 'package:kitoapp/features/admin/widgets/admin_report_metric_grid.dart';
import 'package:kitoapp/features/admin/widgets/admin_reports_hero.dart';
import 'package:kitoapp/features/admin/widgets/admin_reports_overview_card.dart';
import 'package:kitoapp/features/ranking/widgets/ranking_leaderboard_tile.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/admin_reports_store_provider.dart';

class AdminReportsContent extends StatefulWidget {
  const AdminReportsContent({super.key});

  @override
  State<AdminReportsContent> createState() => _AdminReportsContentState();
}

class _AdminReportsContentState extends State<AdminReportsContent> {
  bool _generatingPdf = false;
  final _pdfService = AdminReportPdfService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminReportsStoreProvider.of(context).load();
    });
  }

  AdminReportPdfLabels _pdfLabels(AppLocalizations l10n) {
    return AdminReportPdfLabels(
      title: l10n.reportPdfTitle,
      generatedOn: l10n.generatedOn,
      reportsOverview: l10n.reportsOverview,
      avgAttendance: l10n.avgAttendance,
      avgScore: l10n.avgScore,
      completionRate: l10n.completionRate,
      activeStudents: l10n.activeStudents,
      totalStudents: l10n.totalStudents,
      lessonsPublished: l10n.lessonsPublished,
      pendingApproval: l10n.pendingApproval,
      keyMetrics: l10n.keyMetrics,
      attendance: l10n.attendance,
      scores: l10n.scores,
      learning: l10n.learning,
      topPerformers: l10n.topPerformers,
      leaderboard: l10n.leaderboard,
      rank: l10n.rank,
      student: l10n.student,
      finalScore: l10n.finalScore,
    );
  }

  Future<void> _generatePdf() async {
    if (_generatingPdf) return;

    setState(() => _generatingPdf = true);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final messenger = ScaffoldMessenger.of(context);
    final store = AdminReportsStoreProvider.of(context);

    try {
      await _pdfService.generateAndShare(
        summary: store.summary,
        leaderboard: store.leaderboard,
        rankingLevelLabel: l10n.et221CompassionProject,
        labels: _pdfLabels(l10n),
        locale: locale,
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportGenerated)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportGenerateFailed)));
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = AdminReportsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.leaderboard.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final summary = store.summary;
        final leaderboard = store.leaderboard;

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: store.load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AdminReportsHero(),
                      const SizedBox(height: 18),
                      AdminReportsOverviewCard(summary: summary),
                      const SizedBox(height: 20),
                      AdminReportMetricGrid(
                        summary: summary,
                        attendanceTrend: store.attendanceTrend,
                        scoreTrend: store.scoreTrend,
                        completionTrend: store.completionTrend,
                        activeStudentsTrend: store.activeStudentsTrend,
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.topPerformers,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.topPerformersEt221Subtitle,
                                  style: TextStyle(
                                    color: AppColors.text.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              l10n.et221CompassionProject,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (leaderboard.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            l10n.noUsersFound,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.text.withValues(alpha: 0.45),
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        ...leaderboard.map(
                          (entry) => RankingLeaderboardTile(entry: entry),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: FilledButton.icon(
                  onPressed: _generatingPdf ? null : _generatePdf,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _generatingPdf
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(
                    _generatingPdf ? l10n.generatingReport : l10n.generateReport,
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
