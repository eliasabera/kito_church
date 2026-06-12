import 'package:kitoapp/features/learning/models/learning_item.dart';

enum PathNodeType { lesson, quiz, assignment }

class PathNode {
  const PathNode({
    required this.type,
    required this.item,
    required this.isLocked,
    required this.isCompleted,
    this.timeSpentSeconds = 0,
  });

  final PathNodeType type;
  final LearningItem item;
  final bool isLocked;
  final bool isCompleted;
  final int timeSpentSeconds;
}

/// One week of Sunday School — lesson posted on Saturday, class on Sunday.
class LessonWeek {
  const LessonWeek({
    required this.weekNumber,
    required this.title,
    required this.postedDate,
    required this.sessionDate,
    required this.deadline,
    required this.lesson,
    this.quiz,
    this.assignment,
  });

  final int weekNumber;
  final String title;
  final DateTime postedDate;
  final DateTime sessionDate;
  final DateTime deadline;
  final LearningItem lesson;
  final LearningItem? quiz;
  final LearningItem? assignment;
}
