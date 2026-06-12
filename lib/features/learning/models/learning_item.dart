enum LearningItemType { lesson, assignment, quiz }

enum LearningItemStatus { newItem, pending, completed }

class LearningItem {
  const LearningItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.teacherName,
    required this.type,
    required this.status,
    this.description,
    this.dueDate,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final String teacherName;
  final String? description;
  final LearningItemType type;
  final LearningItemStatus status;
  final String? dueDate;
  final String? imageUrl;

  bool get isCompleted => status == LearningItemStatus.completed;
}

class LearningStats {
  const LearningStats({
    required this.lessonsTotal,
    required this.lessonsCompleted,
    required this.assignmentsTotal,
    required this.assignmentsCompleted,
    required this.quizzesTotal,
    required this.quizzesCompleted,
  });

  final int lessonsTotal;
  final int lessonsCompleted;
  final int assignmentsTotal;
  final int assignmentsCompleted;
  final int quizzesTotal;
  final int quizzesCompleted;
}
