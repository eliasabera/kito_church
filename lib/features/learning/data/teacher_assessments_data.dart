import 'package:kitoapp/features/learning/models/quiz_question.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment_content.dart';

class TeacherAssessmentsData {
  TeacherAssessmentsData._();

  static final initialAssignments = <String, AssignmentContent>{
    'tl2': const AssignmentContent(
      lessonId: 'tl2',
      title: 'Memory Verse Essay',
      instructions:
          'Write a short essay (150–250 words) reflecting on this week\'s memory verse. '
          'Explain what it means to you and how you can apply it in daily life.',
    ),
    'tl4': const AssignmentContent(
      lessonId: 'tl4',
      title: 'Reflection Assignment',
      instructions:
          'After reading the lesson on Prayer & Worship, answer the following:\n'
          '1. What is one way you can grow in prayer this week?\n'
          '2. How does worship connect you to God?',
      attachmentName: 'prayer_reflection_guide.pdf',
    ),
  };

  static final initialQuizzes = <String, QuizContent>{
    'tl1': const QuizContent(
      lessonId: 'tl1',
      title: 'Bible Memory Quiz',
      questions: [
        QuizQuestion(
          question: 'What is the foundation of Christian faith?',
          options: ['Works', 'Grace through faith', 'Tradition', 'Wealth'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Who is the author of salvation?',
          options: ['Ourselves', 'Church leaders', 'Jesus Christ', 'Angels'],
          correctIndex: 2,
        ),
      ],
    ),
    'tl3': const QuizContent(
      lessonId: 'tl3',
      title: 'Week 3 Quiz',
      questions: [
        QuizQuestion(
          question: 'Where was Jesus born?',
          options: ['Nazareth', 'Jerusalem', 'Bethlehem', 'Galilee'],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'At what age did Jesus begin His public ministry?',
          options: ['12', '25', '30', '40'],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'What did Jesus say is the greatest commandment?',
          options: [
            'Honor your parents',
            'Love God with all your heart',
            'Keep the Sabbath',
            'Pay tithes',
          ],
          correctIndex: 1,
        ),
      ],
    ),
  };
}
