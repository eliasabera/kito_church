import 'package:kitoapp/features/learning/models/learning_item.dart';
import 'package:kitoapp/features/learning/models/lesson_unit.dart';
import 'package:kitoapp/features/learning/models/quiz_question.dart';

class StudentLearningData {
  StudentLearningData._();

  static const items = [
    LearningItem(
      id: '1',
      title: 'Introduction to Faith',
      subtitle: 'PDF · 12 pages',
      teacherName: 'Mr. Daniel',
      description:
          'Learn the foundations of Christian faith through scripture, prayer, and community worship.',
      type: LearningItemType.lesson,
      status: LearningItemStatus.completed,
      imageUrl:
          'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=800&q=80',
    ),
    LearningItem(
      id: '2',
      title: 'Bible Study — Week 2',
      subtitle: 'Notes & key verses',
      teacherName: 'Mr. Daniel',
      description:
          'Study key verses from the Gospels and reflect on their meaning in daily life.',
      type: LearningItemType.lesson,
      status: LearningItemStatus.newItem,
    ),
    LearningItem(
      id: '3',
      title: 'The Life of Jesus',
      subtitle: 'Video lesson · 25 min',
      teacherName: 'Ms. Sara',
      description:
          'Watch and discuss the life and ministry of Jesus Christ with guided questions.',
      type: LearningItemType.lesson,
      status: LearningItemStatus.newItem,
      imageUrl:
          'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=800&q=80',
    ),
    LearningItem(
      id: '4',
      title: 'Prayer & Worship',
      subtitle: 'Lesson notes',
      teacherName: 'Ms. Sara',
      description:
          'Explore different forms of prayer and how worship strengthens spiritual growth.',
      type: LearningItemType.lesson,
      status: LearningItemStatus.pending,
    ),
    LearningItem(
      id: '5',
      title: 'Memory Verse Essay',
      subtitle: 'Jeremiah 29:11',
      teacherName: 'Mr. Daniel',
      description:
          'Write a one-page essay explaining what Jeremiah 29:11 means to you personally.',
      type: LearningItemType.assignment,
      status: LearningItemStatus.pending,
      dueDate: 'Jun 14',
    ),
    LearningItem(
      id: '6',
      title: 'Reflection Assignment',
      subtitle: 'Prayer journal',
      teacherName: 'Ms. Sara',
      description:
          'Write a short reflection on how prayer shapes your daily walk with God.',
      type: LearningItemType.assignment,
      status: LearningItemStatus.completed,
      dueDate: 'Jun 28',
    ),
    LearningItem(
      id: '7',
      title: 'Week 3 Quiz',
      subtitle: '10 questions · 20 min',
      teacherName: 'Ms. Sara',
      description:
          'Answer questions covering this week\'s lesson on the life of Jesus.',
      type: LearningItemType.quiz,
      status: LearningItemStatus.newItem,
      dueDate: 'Jun 21',
    ),
    LearningItem(
      id: '8',
      title: 'Bible Memory Quiz',
      subtitle: '5 questions',
      teacherName: 'Mr. Daniel',
      description:
          'Recite and answer questions on this month\'s memory verses.',
      type: LearningItemType.quiz,
      status: LearningItemStatus.completed,
      dueDate: 'Jun 7',
    ),
  ];

  static List<LessonWeek> get weeks {
    LearningItem item(String id) => items.firstWhere((i) => i.id == id);

    return [
      LessonWeek(
        weekNumber: 1,
        title: item('1').title,
        postedDate: DateTime(2026, 5, 31),
        sessionDate: DateTime(2026, 6, 1),
        deadline: DateTime(2026, 6, 7, 23, 59),
        lesson: item('1'),
        quiz: item('8'),
      ),
      LessonWeek(
        weekNumber: 2,
        title: item('2').title,
        postedDate: DateTime(2026, 6, 7),
        sessionDate: DateTime(2026, 6, 8),
        deadline: DateTime(2026, 6, 14, 23, 59),
        lesson: item('2'),
        assignment: item('5'),
      ),
      LessonWeek(
        weekNumber: 3,
        title: item('3').title,
        postedDate: DateTime(2026, 6, 14),
        sessionDate: DateTime(2026, 6, 15),
        deadline: DateTime(2026, 6, 21, 23, 59),
        lesson: item('3'),
        quiz: item('7'),
      ),
      LessonWeek(
        weekNumber: 4,
        title: item('4').title,
        postedDate: DateTime(2026, 6, 21),
        sessionDate: DateTime(2026, 6, 22),
        deadline: DateTime(2026, 6, 28, 23, 59),
        lesson: item('4'),
        assignment: item('6'),
      ),
    ];
  }

  static LessonWeek? weekForNumber(int weekNumber) {
    for (final week in weeks) {
      if (week.weekNumber == weekNumber) return week;
    }
    return null;
  }

  static LessonWeek? weekForLessonId(String lessonId) {
    for (final week in weeks) {
      if (week.lesson.id == lessonId) return week;
    }
    return null;
  }

  static LessonWeek? weekContainingItem(String itemId) {
    for (final week in weeks) {
      if (week.lesson.id == itemId) return week;
      if (week.quiz?.id == itemId) return week;
      if (week.assignment?.id == itemId) return week;
    }
    return null;
  }

  static LearningStats get stats {
    int total(LearningItemType type) =>
        items.where((item) => item.type == type).length;

    int completed(LearningItemType type) => items
        .where((item) => item.type == type && item.isCompleted)
        .length;

    return LearningStats(
      lessonsTotal: total(LearningItemType.lesson),
      lessonsCompleted: completed(LearningItemType.lesson),
      assignmentsTotal: total(LearningItemType.assignment),
      assignmentsCompleted: completed(LearningItemType.assignment),
      quizzesTotal: total(LearningItemType.quiz),
      quizzesCompleted: completed(LearningItemType.quiz),
    );
  }

  static LearningItem? findById(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static String lessonContentFor(String id) {
    return _lessonContents[id] ??
        'Lesson content will appear here once your teacher publishes it.';
  }

  static List<QuizQuestion> quizQuestionsFor(String id) {
    return _quizQuestions[id] ?? _defaultQuizQuestions;
  }

  static const _lessonContents = {
    '1': '''
Faith is trusting in God even when we cannot see the full path ahead. In this lesson we explore what it means to believe, to pray, and to live as part of a Christian community.

Key points:
• Faith is a gift from God that grows through reading Scripture.
• Prayer connects us to God daily.
• Church fellowship strengthens our walk with Christ.

Reflection: Write one way you can practice your faith this week.
''',
    '2': '''
Week 2 — Gospel Highlights

Matthew 5:1-12 — The Beatitudes teach us the values of God's kingdom: humility, mercy, and peacemaking.

Mark 4:35-41 — Jesus calms the storm, showing His power over nature and inviting us to trust Him in difficult times.

Discussion questions:
1. Which Beatitude speaks to you most today?
2. When have you seen God bring peace in a stormy situation?
''',
    '3': '''
The Life of Jesus — Lesson Overview

Jesus was born in Bethlehem, grew in wisdom, began His ministry at about age 30, and taught throughout Galilee and Judea. He performed miracles, called twelve disciples, and showed God's love to all people.

Main sections:
• Birth and early life
• Baptism and temptation
• Teaching and miracles
• Death and resurrection

Watch the video lesson and note three things that surprised you about Jesus' ministry.
''',
    '4': '''
Prayer & Worship

Prayer is conversation with God. Worship is our response to who God is — through song, scripture, service, and silence.

Types of prayer:
• Thanksgiving — thanking God
• Confession — admitting wrong and receiving forgiveness
• Intercession — praying for others
• Petition — asking God for help

Practice: Spend five minutes in prayer using each type above.
''',
  };

  static const _defaultQuizQuestions = [
    QuizQuestion(
      question: 'Who calmed the storm in the Gospels?',
      options: ['Moses', 'Jesus', 'Peter', 'Paul'],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Where was Jesus born?',
      options: ['Nazareth', 'Jerusalem', 'Bethlehem', 'Capernaum'],
      correctIndex: 2,
    ),
  ];

  static const _quizQuestions = {
    '7': [
      QuizQuestion(
        question: 'What is the first Beatitude in Matthew 5?',
        options: [
          'Blessed are the merciful',
          'Blessed are the poor in spirit',
          'Blessed are the peacemakers',
          'Blessed are the pure in heart',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'How many disciples did Jesus call?',
        options: ['7', '10', '12', '14'],
        correctIndex: 2,
      ),
    ],
    '8': [
      QuizQuestion(
        question: 'Complete: "For God so loved the ___"',
        options: ['church', 'world', 'nation', 'family'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'The Lord\'s Prayer begins with…',
        options: ['Hallelujah', 'Our Father', 'Amen', 'Holy Spirit'],
        correctIndex: 1,
      ),
    ],
  };
}
