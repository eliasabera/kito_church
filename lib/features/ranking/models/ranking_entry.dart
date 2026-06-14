class RankingEntry {
  const RankingEntry({
    required this.rank,
    required this.name,
    required this.score,
    this.isCurrentStudent = false,
  });

  final int rank;
  final String name;
  final double score;
  final bool isCurrentStudent;
}

class StudentRankSummary {
  const StudentRankSummary({
    required this.studentName,
    required this.finalScore,
    required this.classRank,
    this.attendancePercent = 0,
  });

  final String studentName;
  final double finalScore;
  final int classRank;
  final int attendancePercent;
}
