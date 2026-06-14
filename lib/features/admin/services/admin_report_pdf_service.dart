import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:kitoapp/features/admin/data/admin_reports_data.dart';
import 'package:kitoapp/features/ranking/models/ranking_entry.dart';

class AdminReportPdfLabels {
  const AdminReportPdfLabels({
    required this.title,
    required this.generatedOn,
    required this.reportsOverview,
    required this.avgAttendance,
    required this.avgScore,
    required this.completionRate,
    required this.activeStudents,
    required this.totalStudents,
    required this.lessonsPublished,
    required this.pendingApproval,
    required this.keyMetrics,
    required this.attendance,
    required this.scores,
    required this.learning,
    required this.topPerformers,
    required this.leaderboard,
    required this.rank,
    required this.student,
    required this.finalScore,
  });

  final String title;
  final String generatedOn;
  final String reportsOverview;
  final String avgAttendance;
  final String avgScore;
  final String completionRate;
  final String activeStudents;
  final String totalStudents;
  final String lessonsPublished;
  final String pendingApproval;
  final String keyMetrics;
  final String attendance;
  final String scores;
  final String learning;
  final String topPerformers;
  final String leaderboard;
  final String rank;
  final String student;
  final String finalScore;
}

class AdminReportPdfService {
  static final _primary = PdfColor.fromInt(0xFF005DA5);
  static final _primaryDark = PdfColor.fromInt(0xFF003D6B);

  Future<void> generateAndShare({
    required AdminReportsSummary summary,
    required List<RankingEntry> leaderboard,
    required String rankingLevelLabel,
    required AdminReportPdfLabels labels,
    required String locale,
  }) async {
    final doc = pw.Document();
    final generatedAt = DateFormat.yMMMd(locale).add_jm().format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.robotoRegular(),
            bold: await PdfGoogleFonts.robotoBold(),
          ),
        ),
        build: (context) => [
          _header(labels, generatedAt),
          pw.SizedBox(height: 20),
          _sectionTitle(labels.reportsOverview),
          pw.SizedBox(height: 10),
          _overviewTable(summary, labels),
          pw.SizedBox(height: 20),
          _sectionTitle(labels.keyMetrics),
          pw.SizedBox(height: 10),
          _metricsGrid(summary, labels),
          pw.SizedBox(height: 20),
          _sectionTitle('${labels.topPerformers} — $rankingLevelLabel'),
          pw.SizedBox(height: 6),
          pw.Text(
            labels.leaderboard,
            style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          _leaderboardTable(leaderboard, labels),
        ],
      ),
    );

    final bytes = await doc.save();
    final fileName =
        'kgc_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  pw.Widget _header(AdminReportPdfLabels labels, String generatedAt) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            labels.title,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${labels.generatedOn}: $generatedAt',
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _primary, width: 2),
        ),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: _primaryDark,
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _overviewTable(
    AdminReportsSummary summary,
    AdminReportPdfLabels labels,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        _tableRow(labels.avgAttendance, '${summary.avgAttendancePercent}%'),
        _tableRow(labels.avgScore, '${summary.avgScore}'),
        _tableRow(labels.completionRate, '${summary.completionRate}%'),
        _tableRow(
          labels.activeStudents,
          '${summary.activeStudents} / ${summary.totalStudents}',
        ),
        _tableRow(labels.lessonsPublished, '${summary.lessonsPublished}'),
        _tableRow(labels.pendingApproval, '${summary.pendingApprovals}'),
      ],
    );
  }

  pw.Widget _metricsGrid(
    AdminReportsSummary summary,
    AdminReportPdfLabels labels,
  ) {
    final items = [
      (labels.attendance, '${summary.avgAttendancePercent}%'),
      (labels.scores, '${summary.avgScore}'),
      (labels.learning, '${summary.completionRate}%'),
      (labels.totalStudents, '${summary.activeStudents}/${summary.totalStudents}'),
    ];

    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => pw.Container(
              width: 230,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item.$2,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(item.$1, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _leaderboardTable(
    List<RankingEntry> entries,
    AdminReportPdfLabels labels,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _primary),
          children: [
            _headerCell(labels.rank),
            _headerCell(labels.student),
            _headerCell(labels.finalScore),
          ],
        ),
        ...entries.map(
          (entry) => pw.TableRow(
            children: [
              _bodyCell('#${entry.rank}'),
              _bodyCell(entry.name),
              _bodyCell(entry.score.toStringAsFixed(0)),
            ],
          ),
        ),
      ],
    );
  }

  pw.TableRow _tableRow(String label, String value) {
    return pw.TableRow(
      children: [
        _bodyCell(label),
        _bodyCell(value, align: pw.TextAlign.right),
      ],
    );
  }

  pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  pw.Widget _bodyCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, textAlign: align, style: const pw.TextStyle(fontSize: 10)),
    );
  }
}
