import 'package:kitoapp/features/ranking/models/ranking_entry.dart';

class StudentRankingData {
  StudentRankingData._();

  static const summary = StudentRankSummary(
    studentName: 'You',
    finalScore: 82,
    classRank: 5,
    branchRank: 12,
    projectRank: 48,
  );

  static const classLeaderboard = [
    RankingEntry(rank: 1, name: 'Hanna T.', score: 96),
    RankingEntry(rank: 2, name: 'Samuel K.', score: 94),
    RankingEntry(rank: 3, name: 'Marta G.', score: 91),
    RankingEntry(rank: 4, name: 'Yonas A.', score: 87),
    RankingEntry(rank: 5, name: 'You', score: 82, isCurrentStudent: true),
    RankingEntry(rank: 6, name: 'Lydia M.', score: 80),
    RankingEntry(rank: 7, name: 'Daniel B.', score: 78),
    RankingEntry(rank: 8, name: 'Ruth T.', score: 75),
  ];

  static const branchLeaderboard = [
    RankingEntry(rank: 1, name: 'Hanna T.', score: 96),
    RankingEntry(rank: 2, name: 'Samuel K.', score: 94),
    RankingEntry(rank: 8, name: 'Marta G.', score: 91),
    RankingEntry(rank: 10, name: 'Yonas A.', score: 87),
    RankingEntry(rank: 12, name: 'You', score: 82, isCurrentStudent: true),
    RankingEntry(rank: 15, name: 'Lydia M.', score: 80),
    RankingEntry(rank: 18, name: 'Daniel B.', score: 78),
    RankingEntry(rank: 22, name: 'Ruth T.', score: 75),
  ];

  static const projectLeaderboard = [
    RankingEntry(rank: 1, name: 'Hanna T.', score: 96),
    RankingEntry(rank: 5, name: 'Samuel K.', score: 94),
    RankingEntry(rank: 18, name: 'Marta G.', score: 91),
    RankingEntry(rank: 32, name: 'Yonas A.', score: 87),
    RankingEntry(rank: 48, name: 'You', score: 82, isCurrentStudent: true),
    RankingEntry(rank: 51, name: 'Lydia M.', score: 80),
    RankingEntry(rank: 60, name: 'Daniel B.', score: 78),
    RankingEntry(rank: 72, name: 'Ruth T.', score: 75),
  ];

  static List<RankingEntry> leaderboardFor(RankingLevel level) {
    return switch (level) {
      RankingLevel.classRank => classLeaderboard,
      RankingLevel.branchRank => branchLeaderboard,
      RankingLevel.projectRank => projectLeaderboard,
    };
  }
}
