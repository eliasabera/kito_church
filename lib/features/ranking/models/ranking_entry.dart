enum RankingLevel { classRank, branchRank, projectRank }

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
    required this.branchRank,
    required this.projectRank,
  });

  final String studentName;
  final double finalScore;
  final int classRank;
  final int branchRank;
  final int projectRank;
}
