import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/locale/locale_notifier.dart';
import 'package:kitoapp/features/attendance/services/attendance_store.dart';
import 'package:kitoapp/features/attendance/services/teacher_attendance_store.dart';
import 'package:kitoapp/features/bible_verse/services/daily_verse_store.dart';
import 'package:kitoapp/features/learning/services/learning_progress_store.dart';
import 'package:kitoapp/features/learning/services/teacher_assessments_store.dart';
import 'package:kitoapp/features/prayer_requests/services/prayer_requests_store.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_store.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/core/theme/app_theme.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/attendance_store_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_attendance_store_provider.dart';
import 'package:kitoapp/shared/widgets/daily_verse_store_provider.dart';
import 'package:kitoapp/shared/widgets/learning_progress_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_assessments_store_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';
import 'package:kitoapp/shared/widgets/locale_notifier_provider.dart';
import 'package:kitoapp/shared/widgets/prayer_requests_store_provider.dart';

class KitoApp extends StatefulWidget {
  const KitoApp({super.key});

  @override
  State<KitoApp> createState() => _KitoAppState();
}

class _KitoAppState extends State<KitoApp> {
  late final LocaleNotifier _localeNotifier;
  late final AttendanceStore _attendanceStore;
  late final TeacherAttendanceStore _teacherAttendanceStore;
  late final LearningProgressStore _learningProgressStore;
  late final DailyVerseStore _dailyVerseStore;
  late final TeacherLessonsStore _teacherLessonsStore;
  late final TeacherAssessmentsStore _teacherAssessmentsStore;
  late final PrayerRequestsStore _prayerRequestsStore;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _localeNotifier = LocaleNotifier();
    _attendanceStore = AttendanceStore();
    _teacherAttendanceStore = TeacherAttendanceStore();
    _learningProgressStore = LearningProgressStore(
      attendanceStore: _attendanceStore,
    );
    _dailyVerseStore = DailyVerseStore();
    _teacherLessonsStore = TeacherLessonsStore(
      attendanceStore: _teacherAttendanceStore,
    );
    _teacherAssessmentsStore = TeacherAssessmentsStore(
      lessonsStore: _teacherLessonsStore,
    );
    _prayerRequestsStore = PrayerRequestsStore();
    _router = createAppRouter();
  }

  @override
  void dispose() {
    _localeNotifier.dispose();
    _attendanceStore.dispose();
    _teacherAttendanceStore.dispose();
    _learningProgressStore.dispose();
    _dailyVerseStore.dispose();
    _teacherLessonsStore.dispose();
    _teacherAssessmentsStore.dispose();
    _prayerRequestsStore.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrayerRequestsStoreProvider(
      notifier: _prayerRequestsStore,
      child: TeacherLessonsStoreProvider(
        notifier: _teacherLessonsStore,
        child: TeacherAssessmentsStoreProvider(
          notifier: _teacherAssessmentsStore,
          child: DailyVerseStoreProvider(
        notifier: _dailyVerseStore,
        child: LearningProgressProvider(
          notifier: _learningProgressStore,
          child: AttendanceStoreProvider(
            notifier: _attendanceStore,
            child: TeacherAttendanceStoreProvider(
              notifier: _teacherAttendanceStore,
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
                    supportedLocales: AppLocalizations.supportedLocales,
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
    );
  }
}
