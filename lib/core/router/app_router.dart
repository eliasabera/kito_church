import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/router/role_nav_config.dart';
import 'package:kitoapp/features/admin/screens/user_management_screen.dart';
import 'package:kitoapp/features/announcements/screens/announcements_screen.dart';
import 'package:kitoapp/features/attendance/screens/attendance_screen.dart';
import 'package:kitoapp/features/attendance/screens/makeup_attendance_screen.dart';
import 'package:kitoapp/features/auth/screens/login_screen.dart';
import 'package:kitoapp/features/auth/screens/student_registration_screen.dart';
import 'package:kitoapp/features/admin/screens/admin_create_announcement_screen.dart';
import 'package:kitoapp/features/admin/screens/admin_manage_bible_stories_screen.dart';
import 'package:kitoapp/features/admin/screens/admin_manage_gifts_screen.dart';
import 'package:kitoapp/features/admin/screens/admin_manage_sponsorship_screen.dart';
import 'package:kitoapp/features/admin/screens/admin_upload_verse_screen.dart';
import 'package:kitoapp/features/bible_verse/screens/daily_verse_screen.dart';
import 'package:kitoapp/features/certificates/screens/certificates_screen.dart';
import 'package:kitoapp/features/dashboard/screens/admin_dashboard_screen.dart';
import 'package:kitoapp/features/dashboard/screens/student_dashboard_screen.dart';
import 'package:kitoapp/features/dashboard/screens/teacher_dashboard_screen.dart';
import 'package:kitoapp/features/gifts/screens/gifts_screen.dart';
import 'package:kitoapp/features/learning/screens/assignment_submission_screen.dart';
import 'package:kitoapp/features/learning/screens/learning_item_detail_screen.dart';
import 'package:kitoapp/features/learning/screens/lesson_reader_screen.dart';
import 'package:kitoapp/features/learning/screens/quiz_practice_screen.dart';
import 'package:kitoapp/features/learning/screens/student_learning_content.dart';
import 'package:kitoapp/features/learning/screens/teacher_assignments_screen.dart';
import 'package:kitoapp/features/learning/screens/teacher_classes_content.dart';
import 'package:kitoapp/features/learning/screens/teacher_performance_screen.dart';
import 'package:kitoapp/features/learning/screens/teacher_quizzes_screen.dart';
import 'package:kitoapp/features/notifications/screens/notifications_screen.dart';
import 'package:kitoapp/features/prayer_requests/screens/prayer_requests_screen.dart';
import 'package:kitoapp/features/admin/screens/admin_settings_screen.dart';
import 'package:kitoapp/features/profile/screens/profile_content.dart';
import 'package:kitoapp/features/admin/screens/admin_reports_screen.dart';
import 'package:kitoapp/features/ranking/screens/ranking_screen.dart';
import 'package:kitoapp/features/sponsorship/screens/sponsorship_screen.dart';
import 'package:kitoapp/shared/widgets/role_shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRoutes {
  AppRoutes._();

  static const login = '/';
  static const register = '/register';
}

class StudentRoutes {
  StudentRoutes._();

  static const home = '/student';
  static const learning = '/student/learning';
  static const ranking = '/student/ranking';
  static const profile = '/student/profile';
  static const dailyVerse = '/student/daily-verse';
  static const attendance = '/student/attendance';
  static String makeupAttendance(String sessionId) =>
      '/student/attendance/makeup/$sessionId';
  static const gifts = '/student/gifts';
  static const sponsorship = '/student/sponsorship';
  static const announcements = '/student/announcements';
  static const prayerRequests = '/student/prayer-requests';
  static const notifications = '/student/notifications';
  static String learningItem(String id) => '/student/learning/item/$id';
  static String lessonReader(String id) => '/student/learning/lesson/$id';
  static String quizPractice(String id) => '/student/learning/quiz/$id';
  static String assignmentSubmit(String id) => '/student/learning/assignment/$id';
}

class TeacherRoutes {
  TeacherRoutes._();

  static const home = '/teacher';
  static const classes = '/teacher/classes';
  static const attendance = '/teacher/attendance';
  static const profile = '/teacher/profile';
  static const assignments = '/teacher/assignments';
  static const quizzes = '/teacher/quizzes';
  static const performance = '/teacher/performance';
  static const prayerRequests = '/teacher/prayer-requests';
  static const announcements = '/teacher/announcements';
}

class AdminRoutes {
  AdminRoutes._();

  static const home = '/admin';
  static const users = '/admin/users';
  static const reports = '/admin/reports';
  static const settings = '/admin/settings';
  static const dailyVerse = '/admin/daily-verse';
  static const gifts = '/admin/gifts';
  static const sponsorship = '/admin/sponsorship';
  static const announcements = '/admin/announcements';
  static const bibleStories = '/admin/bible-stories';
  static const certificates = '/admin/certificates';
  static const notifications = '/admin/notifications';
}

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const StudentRegistrationScreen(),
      ),
      _studentShellRoute(),
      _teacherShellRoute(),
      _adminShellRoute(),
    ],
  );
}

StatefulShellRoute _studentShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return RoleShellScaffold(
        role: UserRole.student,
        navigationShell: navigationShell,
      );
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: StudentRoutes.home,
            builder: (context, state) => const StudentDashboardContent(),
            routes: _studentOverlayRoutes(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: StudentRoutes.learning,
            builder: (context, state) => const StudentLearningContent(),
            routes: [
              GoRoute(
                path: 'item/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return LearningItemDetailScreen(itemId: id);
                },
              ),
              GoRoute(
                path: 'lesson/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return LessonReaderScreen(itemId: id);
                },
              ),
              GoRoute(
                path: 'quiz/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return QuizPracticeScreen(itemId: id);
                },
              ),
              GoRoute(
                path: 'assignment/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AssignmentSubmissionScreen(itemId: id);
                },
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: StudentRoutes.ranking,
            builder: (context, state) => const RankingContent(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: StudentRoutes.profile,
            builder: (context, state) => const ProfileContent(),
          ),
        ],
      ),
    ],
  );
}

List<RouteBase> _studentOverlayRoutes() {
  return [
    _overlayRoute('daily-verse', const DailyVerseScreen()),
    GoRoute(
      path: 'attendance',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AttendanceScreen(),
      routes: [
        GoRoute(
          path: 'makeup/:sessionId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final sessionId = state.pathParameters['sessionId']!;
            return MakeupAttendanceScreen(sessionId: sessionId);
          },
        ),
      ],
    ),
    _overlayRoute('gifts', const GiftsScreen()),
    _overlayRoute('sponsorship', const SponsorshipScreen()),
    _overlayRoute('announcements', const AnnouncementsScreen()),
    _overlayRoute('prayer-requests', const PrayerRequestsScreen()),
    _overlayRoute('notifications', const StudentNotificationsScreen()),
  ];
}

StatefulShellRoute _teacherShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return RoleShellScaffold(
        role: UserRole.teacher,
        navigationShell: navigationShell,
      );
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: TeacherRoutes.home,
            builder: (context, state) => const TeacherDashboardContent(),
            routes: _teacherOverlayRoutes(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: TeacherRoutes.classes,
            builder: (context, state) => const TeacherClassesContent(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: TeacherRoutes.attendance,
            builder: (context, state) => const AttendanceContent(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: TeacherRoutes.profile,
            builder: (context, state) => const ProfileContent(),
          ),
        ],
      ),
    ],
  );
}

List<RouteBase> _teacherOverlayRoutes() {
  return [
    _overlayRoute('assignments', const TeacherAssignmentsScreen()),
    _overlayRoute('quizzes', const TeacherQuizzesScreen()),
    _overlayRoute('performance', const TeacherPerformanceScreen()),
    _overlayRoute('prayer-requests', const PrayerRequestsScreen()),
    _overlayRoute('announcements', const AnnouncementsScreen()),
  ];
}

StatefulShellRoute _adminShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return RoleShellScaffold(
        role: UserRole.admin,
        navigationShell: navigationShell,
      );
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AdminRoutes.home,
            builder: (context, state) => const AdminDashboardContent(),
            routes: _adminOverlayRoutes(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AdminRoutes.users,
            builder: (context, state) => const UserManagementContent(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AdminRoutes.reports,
            builder: (context, state) => const AdminReportsContent(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AdminRoutes.settings,
            builder: (context, state) => const AdminSettingsContent(),
          ),
        ],
      ),
    ],
  );
}

List<RouteBase> _adminOverlayRoutes() {
  return [
    _overlayRoute('daily-verse', const AdminUploadVerseScreen()),
    _overlayRoute('gifts', const AdminManageGiftsScreen()),
    _overlayRoute('sponsorship', const AdminManageSponsorshipScreen()),
    _overlayRoute('announcements', const AdminCreateAnnouncementScreen()),
    _overlayRoute('bible-stories', const AdminManageBibleStoriesScreen()),
    _overlayRoute('certificates', const CertificatesScreen()),
    _overlayRoute('notifications', const AdminNotificationsScreen()),
  ];
}

GoRoute _overlayRoute(String path, Widget screen) {
  return GoRoute(
    path: path,
    parentNavigatorKey: _rootNavigatorKey,
    builder: (context, state) => screen,
  );
}

String dashboardRouteForRole(UserRole role) => shellRootForRole(role);
