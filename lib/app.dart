import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:go_router/go_router.dart';

import 'package:kitoapp/core/locale/locale_notifier.dart';

import 'package:kitoapp/features/attendance/services/attendance_store.dart';

import 'package:kitoapp/features/attendance/services/teacher_attendance_store.dart';

import 'package:kitoapp/features/bible_verse/services/daily_verse_store.dart';

import 'package:kitoapp/features/learning/services/learning_progress_store.dart';

import 'package:kitoapp/features/learning/services/student_learning_catalog_store.dart';
import 'package:kitoapp/features/learning/services/teacher_assessments_store.dart';

import 'package:kitoapp/features/prayer_requests/services/prayer_requests_store.dart';

import 'package:kitoapp/features/bible_stories/services/bible_stories_store.dart';

import 'package:kitoapp/features/announcements/services/announcements_store.dart';

import 'package:kitoapp/features/admin/services/compassion_management_store.dart';

import 'package:kitoapp/features/admin/services/admin_reports_store.dart';

import 'package:kitoapp/features/admin/services/admin_settings_store.dart';

import 'package:kitoapp/features/admin/services/users_management_store.dart';

import 'package:kitoapp/features/notifications/services/notifications_store.dart';

import 'package:kitoapp/features/learning/services/teacher_lessons_store.dart';

import 'package:kitoapp/features/dashboard/services/teacher_dashboard_store.dart';

import 'package:kitoapp/features/dashboard/services/admin_dashboard_store.dart';

import 'package:kitoapp/features/profile/services/profile_store.dart';

import 'package:kitoapp/features/ranking/services/student_ranking_store.dart';

import 'package:kitoapp/features/learning/services/teacher_performance_store.dart';

import 'package:kitoapp/core/router/app_router.dart';

import 'package:kitoapp/core/theme/app_theme.dart';

import 'package:kitoapp/l10n/app_localizations.dart';

import 'package:kitoapp/shared/widgets/attendance_store_provider.dart';

import 'package:kitoapp/shared/widgets/teacher_attendance_store_provider.dart';

import 'package:kitoapp/shared/widgets/daily_verse_store_provider.dart';

import 'package:kitoapp/shared/widgets/learning_progress_provider.dart';

import 'package:kitoapp/shared/widgets/student_learning_catalog_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_assessments_store_provider.dart';

import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

import 'package:kitoapp/shared/widgets/locale_notifier_provider.dart';

import 'package:kitoapp/shared/widgets/prayer_requests_store_provider.dart';

import 'package:kitoapp/shared/widgets/bible_stories_store_provider.dart';

import 'package:kitoapp/shared/widgets/announcements_store_provider.dart';

import 'package:kitoapp/shared/widgets/compassion_management_store_provider.dart';

import 'package:kitoapp/shared/widgets/notifications_store_provider.dart';


import 'package:kitoapp/shared/widgets/users_management_store_provider.dart';

import 'package:kitoapp/shared/widgets/teacher_dashboard_store_provider.dart';

import 'package:kitoapp/shared/widgets/admin_reports_store_provider.dart';

import 'package:kitoapp/shared/widgets/admin_settings_store_provider.dart';

import 'package:kitoapp/shared/widgets/admin_dashboard_store_provider.dart';

import 'package:kitoapp/shared/widgets/profile_store_provider.dart';

import 'package:kitoapp/shared/widgets/student_ranking_store_provider.dart';

import 'package:kitoapp/shared/widgets/teacher_performance_store_provider.dart';



class KitoApp extends StatefulWidget {

  const KitoApp({super.key});



  @override

  State<KitoApp> createState() => _KitoAppState();

}



class _KitoAppState extends State<KitoApp> {

  late final LocaleNotifier _localeNotifier;

  late final NotificationsStore _notificationsStore;

  late final AttendanceStore _attendanceStore;

  late final TeacherAttendanceStore _teacherAttendanceStore;

  late final LearningProgressStore _learningProgressStore;

  late final DailyVerseStore _dailyVerseStore;

  late final TeacherLessonsStore _teacherLessonsStore;

  late final TeacherAssessmentsStore _teacherAssessmentsStore;

  late final StudentLearningCatalogStore _studentLearningCatalogStore;

  late final PrayerRequestsStore _prayerRequestsStore;

  late final UsersManagementStore _usersManagementStore;

  late final CompassionManagementStore _compassionManagementStore;

  late final AnnouncementsStore _announcementsStore;

  late final BibleStoriesStore _bibleStoriesStore;

  late final TeacherDashboardStore _teacherDashboardStore;

  late final AdminDashboardStore _adminDashboardStore;

  late final AdminReportsStore _adminReportsStore;

  late final AdminSettingsStore _adminSettingsStore;

  late final ProfileStore _profileStore;

  late final StudentRankingStore _studentRankingStore;

  late final TeacherPerformanceStore _teacherPerformanceStore;

  late final GoRouter _router;



  @override

  void initState() {

    super.initState();

    _localeNotifier = LocaleNotifier();

    _notificationsStore = NotificationsStore();

    _attendanceStore = AttendanceStore();

    _teacherAttendanceStore = TeacherAttendanceStore();

    _teacherLessonsStore = TeacherLessonsStore(

      attendanceStore: _teacherAttendanceStore,

    );

    _teacherAssessmentsStore = TeacherAssessmentsStore(

      lessonsStore: _teacherLessonsStore,

    );

    _studentLearningCatalogStore = StudentLearningCatalogStore(

      lessonsStore: _teacherLessonsStore,

      assessmentsStore: _teacherAssessmentsStore,

    );

    _learningProgressStore = LearningProgressStore(

      attendanceStore: _attendanceStore,

      catalogStore: _studentLearningCatalogStore,

    );

    _usersManagementStore = UsersManagementStore(

      notificationsStore: _notificationsStore,

    );

    unawaited(_usersManagementStore.load());

    _dailyVerseStore = DailyVerseStore(

      notificationsStore: _notificationsStore,

      usersManagementStore: _usersManagementStore,

    );

    unawaited(_dailyVerseStore.load());

    _prayerRequestsStore = PrayerRequestsStore();

    _compassionManagementStore = CompassionManagementStore(

      notificationsStore: _notificationsStore,

    );

    unawaited(_compassionManagementStore.loadGiftData());
    unawaited(_compassionManagementStore.loadSponsorshipData());

    _announcementsStore = AnnouncementsStore();

    unawaited(_announcementsStore.loadFromSupabase());

    _bibleStoriesStore = BibleStoriesStore();

    unawaited(_bibleStoriesStore.load());

    _teacherDashboardStore = TeacherDashboardStore();

    _adminDashboardStore = AdminDashboardStore();

    _adminReportsStore = AdminReportsStore();

    _adminSettingsStore = AdminSettingsStore();

    _profileStore = ProfileStore();

    _studentRankingStore = StudentRankingStore();

    _teacherPerformanceStore = TeacherPerformanceStore();

    _router = createAppRouter();

  }



  @override

  void dispose() {

    _localeNotifier.dispose();

    _notificationsStore.dispose();

    _attendanceStore.dispose();

    _teacherAttendanceStore.dispose();

    _learningProgressStore.dispose();

    _dailyVerseStore.dispose();

    _teacherLessonsStore.dispose();

    _teacherAssessmentsStore.dispose();

    _studentLearningCatalogStore.dispose();

    _prayerRequestsStore.dispose();

    _usersManagementStore.dispose();

    _compassionManagementStore.dispose();

    _announcementsStore.dispose();

    _bibleStoriesStore.dispose();

    _teacherDashboardStore.dispose();

    _adminDashboardStore.dispose();

    _adminReportsStore.dispose();

    _adminSettingsStore.dispose();

    _profileStore.dispose();

    _studentRankingStore.dispose();

    _teacherPerformanceStore.dispose();

    _router.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return ProfileStoreProvider(

      notifier: _profileStore,

      child: StudentRankingStoreProvider(

        notifier: _studentRankingStore,

        child: NotificationsStoreProvider(

      notifier: _notificationsStore,

      child: BibleStoriesStoreProvider(

        notifier: _bibleStoriesStore,

        child: AnnouncementsStoreProvider(

          notifier: _announcementsStore,

          child: CompassionManagementStoreProvider(

            notifier: _compassionManagementStore,

            child: UsersManagementStoreProvider(

                notifier: _usersManagementStore,

                child: PrayerRequestsStoreProvider(

                  notifier: _prayerRequestsStore,

                  child: TeacherLessonsStoreProvider(

                    notifier: _teacherLessonsStore,

                    child: TeacherPerformanceStoreProvider(

                      notifier: _teacherPerformanceStore,

                      child: TeacherAssessmentsStoreProvider(

                      notifier: _teacherAssessmentsStore,

                      child: StudentLearningCatalogProvider(

                        notifier: _studentLearningCatalogStore,

                        child: DailyVerseStoreProvider(

                          notifier: _dailyVerseStore,

                          child: LearningProgressProvider(

                            notifier: _learningProgressStore,

                            child: AttendanceStoreProvider(

                            notifier: _attendanceStore,

                            child: TeacherAttendanceStoreProvider(

                              notifier: _teacherAttendanceStore,

                              child: TeacherDashboardStoreProvider(

                                notifier: _teacherDashboardStore,

                                child: AdminDashboardStoreProvider(

                                  notifier: _adminDashboardStore,

                                  child: AdminReportsStoreProvider(

                                    notifier: _adminReportsStore,

                                    child: AdminSettingsStoreProvider(

                                      notifier: _adminSettingsStore,

                                      child: LocaleNotifierProvider(

                                notifier: _localeNotifier,

                                child: ListenableBuilder(

                                  listenable: _localeNotifier,

                                  builder: (context, _) {

                                    return MaterialApp.router(

                                      debugShowCheckedModeBanner: false,

                                      title: 'KGC Connect',

                                      theme: AppTheme.light(),

                                      locale: _localeNotifier.locale,

                                      supportedLocales:

                                          AppLocalizations.supportedLocales,

                                      localizationsDelegates: const [

                                        AppLocalizations.delegate,

                                        GlobalMaterialLocalizations.delegate,

                                        GlobalWidgetsLocalizations.delegate,

                                        GlobalCupertinoLocalizations.delegate,

                                      ],

                                      routerConfig: _router,

                                    );

                                  },

                                ),

                                ),

                              ),

                            ),

                          ),

                        ),

                      ),

                    ),

                  ),

                ),

              ),

            ),

          ),

        ),

      ),

    ),

    ),

    ),

    ),

    ),

    ),

    );

  }

}


