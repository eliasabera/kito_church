import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/features/attendance/models/student_attendance_entry.dart';
import 'package:kitoapp/features/learning/data/student_learning_data.dart';

class TeacherAttendanceData {
  TeacherAttendanceData._();

  static const studentNames = [
    'Abel Tesfaye',
    'Hanna T.',
    'Samuel K.',
    'Marta G.',
    'Yonas A.',
    'Lydia M.',
    'Daniel B.',
    'Ruth T.',
    'Sara M.',
    'Michael H.',
    'Eden W.',
    'Nathan P.',
    'Grace L.',
    'Joshua F.',
  ];

  static List<StudentAttendanceEntry> rosterForAgeRange(int minAge, int maxAge) {
    return List.generate(studentNames.length, (index) {
      return StudentAttendanceEntry(
        id: 's${index + 1}',
        name: studentNames[index],
      );
    });
  }

  static List<StudentAttendanceEntry> _roster({
    List<AttendanceStatus?> statuses = const [],
    List<bool> onlineFlags = const [],
  }) {
    return List.generate(studentNames.length, (index) {
      return StudentAttendanceEntry(
        id: 's${index + 1}',
        name: studentNames[index],
        physicalStatus: index < statuses.length ? statuses[index] : null,
        onlineMarked: index < onlineFlags.length && onlineFlags[index],
      );
    });
  }

  static List<TeacherAttendanceSession> initialSessions() {
    final weeks = StudentLearningData.weeks;

    return [
      TeacherAttendanceSession(
        id: 'ts-w3',
        sessionDate: weeks[2].sessionDate,
        weekNumber: weeks[2].weekNumber,
        lessonTitle: weeks[2].title,
        students: _roster(
          statuses: [
            AttendanceStatus.present,
            AttendanceStatus.present,
            AttendanceStatus.late,
            AttendanceStatus.present,
            null,
            AttendanceStatus.present,
            null,
            AttendanceStatus.absent,
            null,
            AttendanceStatus.present,
            null,
            AttendanceStatus.late,
            null,
            null,
          ],
          onlineFlags: [
            false, false, false, false, true, false, true, false,
            false, false, false, false, false, false,
          ],
        ),
      ),
      TeacherAttendanceSession(
        id: 'ts-w2',
        sessionDate: weeks[1].sessionDate,
        weekNumber: weeks[1].weekNumber,
        lessonTitle: weeks[1].title,
        students: _roster(
          statuses: List.filled(14, AttendanceStatus.present)
            ..[7] = AttendanceStatus.absent
            ..[11] = AttendanceStatus.late,
          onlineFlags: [
            false, false, false, false, false, false, false, true,
            false, false, false, false, false, false,
          ],
        ),
      ),
      TeacherAttendanceSession(
        id: 'ts-w1',
        sessionDate: weeks[0].sessionDate,
        weekNumber: weeks[0].weekNumber,
        lessonTitle: weeks[0].title,
        students: _roster(
          statuses: List.filled(14, AttendanceStatus.present)
            ..[5] = AttendanceStatus.late
            ..[9] = AttendanceStatus.absent,
          onlineFlags: [
            false, false, false, false, false, false, false, false,
            false, true, false, false, false, false,
          ],
        ),
      ),
    ];
  }
}
