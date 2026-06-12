import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'KGC Connect'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacher;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @assignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignments;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @scores.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get scores;

  /// No description provided for @ranking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get ranking;

  /// No description provided for @gifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get gifts;

  /// No description provided for @dailyVerse.
  ///
  /// In en, this message translates to:
  /// **'Daily Verse'**
  String get dailyVerse;

  /// No description provided for @sponsorship.
  ///
  /// In en, this message translates to:
  /// **'Sponsorship'**
  String get sponsorship;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @prayerRequests.
  ///
  /// In en, this message translates to:
  /// **'Prayer Requests'**
  String get prayerRequests;

  /// No description provided for @certificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificates;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get amharic;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @studentRegistration.
  ///
  /// In en, this message translates to:
  /// **'Student Registration'**
  String get studentRegistration;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @physicalAttendance.
  ///
  /// In en, this message translates to:
  /// **'Physical Attendance'**
  String get physicalAttendance;

  /// No description provided for @onlineAttendance.
  ///
  /// In en, this message translates to:
  /// **'Online Attendance'**
  String get onlineAttendance;

  /// No description provided for @myClasses.
  ///
  /// In en, this message translates to:
  /// **'My Classes'**
  String get myClasses;

  /// No description provided for @studentPerformance.
  ///
  /// In en, this message translates to:
  /// **'Student Performance'**
  String get studentPerformance;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @scoringSystem.
  ///
  /// In en, this message translates to:
  /// **'Scoring System'**
  String get scoringSystem;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @attendancePercent.
  ///
  /// In en, this message translates to:
  /// **'Attendance %'**
  String get attendancePercent;

  /// No description provided for @currentRank.
  ///
  /// In en, this message translates to:
  /// **'Current Rank'**
  String get currentRank;

  /// No description provided for @latestScore.
  ///
  /// In en, this message translates to:
  /// **'Latest Score'**
  String get latestScore;

  /// No description provided for @newAssignments.
  ///
  /// In en, this message translates to:
  /// **'New Assignments'**
  String get newAssignments;

  /// No description provided for @giftNotifications.
  ///
  /// In en, this message translates to:
  /// **'Gift Notifications'**
  String get giftNotifications;

  /// No description provided for @todaysClasses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Classes'**
  String get todaysClasses;

  /// No description provided for @totalStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get totalStudents;

  /// No description provided for @totalTeachers.
  ///
  /// In en, this message translates to:
  /// **'Total Teachers'**
  String get totalTeachers;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get pendingApproval;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get selectRole;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Compassion Learning Platform'**
  String get appTagline;

  /// No description provided for @compassionProjectId.
  ///
  /// In en, this message translates to:
  /// **'Compassion Project ID'**
  String get compassionProjectId;

  /// No description provided for @selectCompassionId.
  ///
  /// In en, this message translates to:
  /// **'Select Compassion ID'**
  String get selectCompassionId;

  /// No description provided for @noCompassionIdsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Compassion IDs available. Contact admin.'**
  String get noCompassionIdsAvailable;

  /// No description provided for @pleaseSelectCompassionId.
  ///
  /// In en, this message translates to:
  /// **'Please select your Compassion ID'**
  String get pleaseSelectCompassionId;

  /// No description provided for @menuMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get menuMain;

  /// No description provided for @menuMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get menuMore;

  /// No description provided for @churchName.
  ///
  /// In en, this message translates to:
  /// **'Church Name'**
  String get churchName;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @digitalGift.
  ///
  /// In en, this message translates to:
  /// **'Digital Gift'**
  String get digitalGift;

  /// No description provided for @physicalGift.
  ///
  /// In en, this message translates to:
  /// **'Physical Gift'**
  String get physicalGift;

  /// No description provided for @bibleMemory.
  ///
  /// In en, this message translates to:
  /// **'Bible Memory'**
  String get bibleMemory;

  /// No description provided for @participation.
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get participation;

  /// No description provided for @classRank.
  ///
  /// In en, this message translates to:
  /// **'Class Rank'**
  String get classRank;

  /// No description provided for @branchRank.
  ///
  /// In en, this message translates to:
  /// **'Branch Rank'**
  String get branchRank;

  /// No description provided for @projectRank.
  ///
  /// In en, this message translates to:
  /// **'Project Rank'**
  String get projectRank;

  /// No description provided for @verseReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get verseReference;

  /// No description provided for @uploadVerse.
  ///
  /// In en, this message translates to:
  /// **'Upload Verse'**
  String get uploadVerse;

  /// No description provided for @manageGifts.
  ///
  /// In en, this message translates to:
  /// **'Manage Gifts'**
  String get manageGifts;

  /// No description provided for @manageSponsorship.
  ///
  /// In en, this message translates to:
  /// **'Manage Sponsorship'**
  String get manageSponsorship;

  /// No description provided for @createAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Create Announcement'**
  String get createAnnouncement;

  /// No description provided for @submitPrayerRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Prayer Request'**
  String get submitPrayerRequest;

  /// No description provided for @generateCertificate.
  ///
  /// In en, this message translates to:
  /// **'Generate Certificate'**
  String get generateCertificate;

  /// No description provided for @recentAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Recent Announcements'**
  String get recentAnnouncements;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @yourStatus.
  ///
  /// In en, this message translates to:
  /// **'Your Status'**
  String get yourStatus;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueOn;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @learningOverview.
  ///
  /// In en, this message translates to:
  /// **'Learning Overview'**
  String get learningOverview;

  /// No description provided for @readLesson.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readLesson;

  /// No description provided for @submitWork.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitWork;

  /// No description provided for @takeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take Quiz'**
  String get takeQuiz;

  /// No description provided for @noLearningItems.
  ///
  /// In en, this message translates to:
  /// **'No items in this category'**
  String get noLearningItems;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// No description provided for @teacherName.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacherName;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @completedCount.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} done'**
  String completedCount(int completed, int total);

  /// No description provided for @showingItems.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} {type}'**
  String showingItems(int count, String type);

  /// No description provided for @lessonReader.
  ///
  /// In en, this message translates to:
  /// **'Lesson Reader'**
  String get lessonReader;

  /// No description provided for @quizPractice.
  ///
  /// In en, this message translates to:
  /// **'Quiz Practice'**
  String get quizPractice;

  /// No description provided for @assignmentSubmission.
  ///
  /// In en, this message translates to:
  /// **'Submit Assignment'**
  String get assignmentSubmission;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// No description provided for @typeYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type your answer here...'**
  String get typeYourAnswer;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach File'**
  String get attachFile;

  /// No description provided for @assignmentSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Assignment submitted successfully'**
  String get assignmentSubmitted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finishQuiz.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishQuiz;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'You scored {score} out of {total}'**
  String quizScore(int score, int total);

  /// No description provided for @myRanking.
  ///
  /// In en, this message translates to:
  /// **'My Ranking'**
  String get myRanking;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @sponsorName.
  ///
  /// In en, this message translates to:
  /// **'Sponsor Name'**
  String get sponsorName;

  /// No description provided for @sponsorCountry.
  ///
  /// In en, this message translates to:
  /// **'Sponsor Country'**
  String get sponsorCountry;

  /// No description provided for @attendanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Attendance Overview'**
  String get attendanceOverview;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get attendanceHistory;

  /// No description provided for @sessionsAttended.
  ///
  /// In en, this message translates to:
  /// **'{attended} of {total} sessions'**
  String sessionsAttended(int attended, int total);

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @noAttendanceRecords.
  ///
  /// In en, this message translates to:
  /// **'No attendance records found'**
  String get noAttendanceRecords;

  /// No description provided for @makeUpAttendance.
  ///
  /// In en, this message translates to:
  /// **'Make Up Attendance'**
  String get makeUpAttendance;

  /// No description provided for @completeLessonToMark.
  ///
  /// In en, this message translates to:
  /// **'Read the lesson below, then mark your online attendance.'**
  String get completeLessonToMark;

  /// No description provided for @markLessonComplete.
  ///
  /// In en, this message translates to:
  /// **'I Finished the Lesson'**
  String get markLessonComplete;

  /// No description provided for @markOnlineAttendance.
  ///
  /// In en, this message translates to:
  /// **'Mark Online Attendance'**
  String get markOnlineAttendance;

  /// No description provided for @attendanceMarkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Attendance marked successfully!'**
  String get attendanceMarkedSuccess;

  /// No description provided for @pendingMakeUp.
  ///
  /// In en, this message translates to:
  /// **'Pending Make-Up'**
  String get pendingMakeUp;

  /// No description provided for @pendingMakeUpCount.
  ///
  /// In en, this message translates to:
  /// **'{count} session(s) need make-up'**
  String pendingMakeUpCount(int count);

  /// No description provided for @learnAndMark.
  ///
  /// In en, this message translates to:
  /// **'Learn & Mark Attendance'**
  String get learnAndMark;

  /// No description provided for @lessonCompleted.
  ///
  /// In en, this message translates to:
  /// **'Lesson completed'**
  String get lessonCompleted;

  /// No description provided for @stepReadLesson.
  ///
  /// In en, this message translates to:
  /// **'Read lesson'**
  String get stepReadLesson;

  /// No description provided for @stepMarkAttendance.
  ///
  /// In en, this message translates to:
  /// **'Mark attendance'**
  String get stepMarkAttendance;

  /// No description provided for @makeUpAttendanceHint.
  ///
  /// In en, this message translates to:
  /// **'You were absent. Complete that day\'s lesson to mark your online attendance.'**
  String get makeUpAttendanceHint;

  /// No description provided for @readyToMarkAttendance.
  ///
  /// In en, this message translates to:
  /// **'Lesson done — tap to mark attendance'**
  String get readyToMarkAttendance;

  /// No description provided for @giftOverview.
  ///
  /// In en, this message translates to:
  /// **'Gift Overview'**
  String get giftOverview;

  /// No description provided for @totalGifts.
  ///
  /// In en, this message translates to:
  /// **'Total Gifts'**
  String get totalGifts;

  /// No description provided for @myGifts.
  ///
  /// In en, this message translates to:
  /// **'My Gifts'**
  String get myGifts;

  /// No description provided for @fromSponsor.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromSponsor;

  /// No description provided for @noGifts.
  ///
  /// In en, this message translates to:
  /// **'No gifts found'**
  String get noGifts;

  /// No description provided for @mySponsor.
  ///
  /// In en, this message translates to:
  /// **'My Sponsor'**
  String get mySponsor;

  /// No description provided for @sponsoredSince.
  ///
  /// In en, this message translates to:
  /// **'Sponsored since'**
  String get sponsoredSince;

  /// No description provided for @lettersFromSponsor.
  ///
  /// In en, this message translates to:
  /// **'Letters from Sponsor'**
  String get lettersFromSponsor;

  /// No description provided for @sponsorMessage.
  ///
  /// In en, this message translates to:
  /// **'Message from Sponsor'**
  String get sponsorMessage;

  /// No description provided for @noLetters.
  ///
  /// In en, this message translates to:
  /// **'No letters yet'**
  String get noLetters;

  /// No description provided for @announcementOverview.
  ///
  /// In en, this message translates to:
  /// **'Announcements Overview'**
  String get announcementOverview;

  /// No description provided for @totalAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Total Announcements'**
  String get totalAnnouncements;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements found'**
  String get noAnnouncements;

  /// No description provided for @postedBy.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get postedBy;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @churchAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get churchAnnouncements;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @academic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academic;

  /// No description provided for @prayerOverview.
  ///
  /// In en, this message translates to:
  /// **'Prayer Overview'**
  String get prayerOverview;

  /// No description provided for @myPrayerRequests.
  ///
  /// In en, this message translates to:
  /// **'My Prayer Requests'**
  String get myPrayerRequests;

  /// No description provided for @prayerRequestHint.
  ///
  /// In en, this message translates to:
  /// **'Share a request with your church community'**
  String get prayerRequestHint;

  /// No description provided for @prayerRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Prayer request submitted'**
  String get prayerRequestSubmitted;

  /// No description provided for @enterPrayerRequest.
  ///
  /// In en, this message translates to:
  /// **'Write your prayer request here...'**
  String get enterPrayerRequest;

  /// No description provided for @noPrayerRequests.
  ///
  /// In en, this message translates to:
  /// **'No prayer requests yet'**
  String get noPrayerRequests;

  /// No description provided for @praying.
  ///
  /// In en, this message translates to:
  /// **'Praying'**
  String get praying;

  /// No description provided for @answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// No description provided for @sidebarFaithLearning.
  ///
  /// In en, this message translates to:
  /// **'Faith & Learning'**
  String get sidebarFaithLearning;

  /// No description provided for @sidebarCompassion.
  ///
  /// In en, this message translates to:
  /// **'Compassion'**
  String get sidebarCompassion;

  /// No description provided for @sidebarCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get sidebarCommunity;

  /// No description provided for @sidebarTeaching.
  ///
  /// In en, this message translates to:
  /// **'Teaching'**
  String get sidebarTeaching;

  /// No description provided for @sidebarAdminTools.
  ///
  /// In en, this message translates to:
  /// **'Admin Tools'**
  String get sidebarAdminTools;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @sundaySchool.
  ///
  /// In en, this message translates to:
  /// **'Sunday School'**
  String get sundaySchool;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grow in faith, learn, and connect with your church'**
  String get homeHeroSubtitle;

  /// No description provided for @exploreToday.
  ///
  /// In en, this message translates to:
  /// **'Explore Today'**
  String get exploreToday;

  /// No description provided for @weeklyLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Bible Study — Week 3'**
  String get weeklyLessonTitle;

  /// No description provided for @weeklyLessonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue this week\'s lesson and reflection'**
  String get weeklyLessonSubtitle;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get continueLearning;

  /// No description provided for @bibleStories.
  ///
  /// In en, this message translates to:
  /// **'Bible Stories'**
  String get bibleStories;

  /// No description provided for @bibleStory.
  ///
  /// In en, this message translates to:
  /// **'BIBLE STORY'**
  String get bibleStory;

  /// No description provided for @swipeBibleStories.
  ///
  /// In en, this message translates to:
  /// **'Swipe to explore stories from Scripture'**
  String get swipeBibleStories;

  /// No description provided for @storyDavidTitle.
  ///
  /// In en, this message translates to:
  /// **'David & Goliath'**
  String get storyDavidTitle;

  /// No description provided for @storyDavidSummary.
  ///
  /// In en, this message translates to:
  /// **'A young shepherd trusted God and defeated a giant with courage and faith.'**
  String get storyDavidSummary;

  /// No description provided for @storyMosesTitle.
  ///
  /// In en, this message translates to:
  /// **'Moses & the Red Sea'**
  String get storyMosesTitle;

  /// No description provided for @storyMosesSummary.
  ///
  /// In en, this message translates to:
  /// **'God opened the sea for His people, showing that He always makes a way.'**
  String get storyMosesSummary;

  /// No description provided for @storyJonahTitle.
  ///
  /// In en, this message translates to:
  /// **'Jonah'**
  String get storyJonahTitle;

  /// No description provided for @storyJonahSummary.
  ///
  /// In en, this message translates to:
  /// **'Running from God\'s call taught Jonah that obedience brings mercy and purpose.'**
  String get storyJonahSummary;

  /// No description provided for @storyDanielTitle.
  ///
  /// In en, this message translates to:
  /// **'Daniel in the Lion\'s Den'**
  String get storyDanielTitle;

  /// No description provided for @storyDanielSummary.
  ///
  /// In en, this message translates to:
  /// **'Daniel prayed faithfully and God protected him — stand firm in your beliefs.'**
  String get storyDanielSummary;

  /// No description provided for @storySamaritanTitle.
  ///
  /// In en, this message translates to:
  /// **'The Good Samaritan'**
  String get storySamaritanTitle;

  /// No description provided for @storySamaritanSummary.
  ///
  /// In en, this message translates to:
  /// **'True faith shows love in action — help others even when it costs you.'**
  String get storySamaritanSummary;

  /// No description provided for @storyJesusStormTitle.
  ///
  /// In en, this message translates to:
  /// **'Jesus Calms the Storm'**
  String get storyJesusStormTitle;

  /// No description provided for @storyJesusStormSummary.
  ///
  /// In en, this message translates to:
  /// **'When life feels overwhelming, Jesus brings peace to those who trust Him.'**
  String get storyJesusStormSummary;

  /// No description provided for @learningPath.
  ///
  /// In en, this message translates to:
  /// **'Your Learning Path'**
  String get learningPath;

  /// No description provided for @learningPathHint.
  ///
  /// In en, this message translates to:
  /// **'Lessons post on Saturday — complete the lesson and assessment before the deadline to mark Sunday attendance'**
  String get learningPathHint;

  /// No description provided for @weekNumber.
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String weekNumber(int number);

  /// No description provided for @unitNumber.
  ///
  /// In en, this message translates to:
  /// **'Unit {number}'**
  String unitNumber(int number);

  /// No description provided for @timeSpent.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String timeSpent(int seconds);

  /// No description provided for @readingProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% read'**
  String readingProgress(int percent);

  /// No description provided for @completeLesson.
  ///
  /// In en, this message translates to:
  /// **'Complete Lesson'**
  String get completeLesson;

  /// No description provided for @lessonCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Lesson completed! Quiz or assignment is now unlocked.'**
  String get lessonCompletedSuccess;

  /// No description provided for @lessonCompleteRequirements.
  ///
  /// In en, this message translates to:
  /// **'Keep reading — scroll through the lesson and spend a little more time.'**
  String get lessonCompleteRequirements;

  /// No description provided for @keepReadingTime.
  ///
  /// In en, this message translates to:
  /// **'Read for {seconds} more seconds'**
  String keepReadingTime(int seconds);

  /// No description provided for @keepReadingScroll.
  ///
  /// In en, this message translates to:
  /// **'Scroll to the end of the lesson to continue'**
  String get keepReadingScroll;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @totalStudyTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min studied'**
  String totalStudyTime(int minutes);

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @unitLocked.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous unit\'s lesson first'**
  String get unitLocked;

  /// No description provided for @weekLocked.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous week\'s lesson first'**
  String get weekLocked;

  /// No description provided for @activityLocked.
  ///
  /// In en, this message translates to:
  /// **'Complete the lesson first to unlock this activity'**
  String get activityLocked;

  /// No description provided for @deadlineDate.
  ///
  /// In en, this message translates to:
  /// **'Deadline {date}'**
  String deadlineDate(String date);

  /// No description provided for @attendanceHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Weekly Attendance'**
  String get attendanceHeatmap;

  /// No description provided for @attendanceHeatmapHint.
  ///
  /// In en, this message translates to:
  /// **'Each block is a Sunday class. Finish the lesson and assessment before the deadline to mark online attendance.'**
  String get attendanceHeatmapHint;

  /// No description provided for @heatmapPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get heatmapPresent;

  /// No description provided for @heatmapOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get heatmapOnline;

  /// No description provided for @heatmapLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get heatmapLate;

  /// No description provided for @heatmapPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get heatmapPending;

  /// No description provided for @heatmapMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get heatmapMissed;

  /// No description provided for @heatmapFuture.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get heatmapFuture;

  /// No description provided for @heatmapNoLesson.
  ///
  /// In en, this message translates to:
  /// **'No lesson'**
  String get heatmapNoLesson;

  /// No description provided for @todaysVerse.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Verse'**
  String get todaysVerse;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @previousVerses.
  ///
  /// In en, this message translates to:
  /// **'Previous Verses'**
  String get previousVerses;

  /// No description provided for @previousVersesHint.
  ///
  /// In en, this message translates to:
  /// **'All verses posted by date, newest first'**
  String get previousVersesHint;

  /// No description provided for @noPreviousVerses.
  ///
  /// In en, this message translates to:
  /// **'No previous verses yet'**
  String get noPreviousVerses;

  /// No description provided for @verseArchive.
  ///
  /// In en, this message translates to:
  /// **'Verse Archive'**
  String get verseArchive;

  /// No description provided for @versesPostedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} verses posted'**
  String versesPostedCount(int count);

  /// No description provided for @daysWithVerses.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysWithVerses;

  /// No description provided for @versePostedOn.
  ///
  /// In en, this message translates to:
  /// **'Posted {date}'**
  String versePostedOn(String date);

  /// No description provided for @verseReflectionHint.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to reflect on this verse and how it applies to your life today.'**
  String get verseReflectionHint;

  /// No description provided for @teacherHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guide your students in faith, learning, and spiritual growth'**
  String get teacherHomeSubtitle;

  /// No description provided for @teachingOverview.
  ///
  /// In en, this message translates to:
  /// **'Teaching Overview'**
  String get teachingOverview;

  /// No description provided for @classesToday.
  ///
  /// In en, this message translates to:
  /// **'Classes Today'**
  String get classesToday;

  /// No description provided for @pendingReviews.
  ///
  /// In en, this message translates to:
  /// **'To Review'**
  String get pendingReviews;

  /// No description provided for @studentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String studentsCount(int count);

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @prayerRequest.
  ///
  /// In en, this message translates to:
  /// **'Prayer Request'**
  String get prayerRequest;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Ages {min}–{max}'**
  String ageRange(int min, int max);

  /// No description provided for @lessonsOverview.
  ///
  /// In en, this message translates to:
  /// **'Lessons Overview'**
  String get lessonsOverview;

  /// No description provided for @totalLessons.
  ///
  /// In en, this message translates to:
  /// **'Total Lessons'**
  String get totalLessons;

  /// No description provided for @avgCompletion.
  ///
  /// In en, this message translates to:
  /// **'Avg. Completion'**
  String get avgCompletion;

  /// No description provided for @lessonStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get lessonStatusDraft;

  /// No description provided for @lessonStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get lessonStatusPublished;

  /// No description provided for @lessonStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get lessonStatusActive;

  /// No description provided for @lessonStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get lessonStatusClosed;

  /// No description provided for @allLessons.
  ///
  /// In en, this message translates to:
  /// **'All Lessons'**
  String get allLessons;

  /// No description provided for @noLessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons match this filter'**
  String get noLessons;

  /// No description provided for @postLesson.
  ///
  /// In en, this message translates to:
  /// **'Post Lesson'**
  String get postLesson;

  /// No description provided for @postNewLesson.
  ///
  /// In en, this message translates to:
  /// **'Post New Lesson'**
  String get postNewLesson;

  /// No description provided for @postLessonHint.
  ///
  /// In en, this message translates to:
  /// **'Lessons are posted for students by age range. Set a deadline for lesson and assessment completion.'**
  String get postLessonHint;

  /// No description provided for @lessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson Title'**
  String get lessonTitle;

  /// No description provided for @lessonTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a lesson title'**
  String get lessonTitleRequired;

  /// No description provided for @classAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Class Age Range'**
  String get classAgeRange;

  /// No description provided for @minAge.
  ///
  /// In en, this message translates to:
  /// **'Min Age'**
  String get minAge;

  /// No description provided for @maxAge.
  ///
  /// In en, this message translates to:
  /// **'Max Age'**
  String get maxAge;

  /// No description provided for @invalidAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Minimum age cannot be greater than maximum age'**
  String get invalidAgeRange;

  /// No description provided for @includeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Include Quiz'**
  String get includeQuiz;

  /// No description provided for @includeAssignment.
  ///
  /// In en, this message translates to:
  /// **'Include Assignment'**
  String get includeAssignment;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @publishLesson.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishLesson;

  /// No description provided for @lessonPublished.
  ///
  /// In en, this message translates to:
  /// **'Lesson published successfully'**
  String get lessonPublished;

  /// No description provided for @lessonSavedAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Lesson saved as draft'**
  String get lessonSavedAsDraft;

  /// No description provided for @postedOn.
  ///
  /// In en, this message translates to:
  /// **'Posted {date}'**
  String postedOn(String date);

  /// No description provided for @deadlineOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String deadlineOn(String date);

  /// No description provided for @studentsCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} completed'**
  String studentsCompletedCount(int completed, int total);

  /// No description provided for @selectClassSession.
  ///
  /// In en, this message translates to:
  /// **'Select Class Session'**
  String get selectClassSession;

  /// No description provided for @studentAttendance.
  ///
  /// In en, this message translates to:
  /// **'Student Attendance'**
  String get studentAttendance;

  /// No description provided for @markAttendanceHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Present, Late, or Absent to mark each student'**
  String get markAttendanceHint;

  /// No description provided for @notMarked.
  ///
  /// In en, this message translates to:
  /// **'Not Marked'**
  String get notMarked;

  /// No description provided for @studentsUnmarked.
  ///
  /// In en, this message translates to:
  /// **'{count} students not yet marked'**
  String studentsUnmarked(int count);

  /// No description provided for @expandDetails.
  ///
  /// In en, this message translates to:
  /// **'Expand week details'**
  String get expandDetails;

  /// No description provided for @collapseDetails.
  ///
  /// In en, this message translates to:
  /// **'Minimize week details'**
  String get collapseDetails;

  /// No description provided for @sessionLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Past sessions are locked — attendance cannot be changed'**
  String get sessionLockedHint;

  /// No description provided for @assignmentsOverview.
  ///
  /// In en, this message translates to:
  /// **'Assignments Overview'**
  String get assignmentsOverview;

  /// No description provided for @quizzesOverview.
  ///
  /// In en, this message translates to:
  /// **'Quizzes Overview'**
  String get quizzesOverview;

  /// No description provided for @performanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Class Performance'**
  String get performanceOverview;

  /// No description provided for @totalAssignments.
  ///
  /// In en, this message translates to:
  /// **'Total Assignments'**
  String get totalAssignments;

  /// No description provided for @totalQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Total Quizzes'**
  String get totalQuizzes;

  /// No description provided for @classAvgScore.
  ///
  /// In en, this message translates to:
  /// **'Class Avg. Score'**
  String get classAvgScore;

  /// No description provided for @attempted.
  ///
  /// In en, this message translates to:
  /// **'Attempted'**
  String get attempted;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @allAssignments.
  ///
  /// In en, this message translates to:
  /// **'All Assignments'**
  String get allAssignments;

  /// No description provided for @allQuizzes.
  ///
  /// In en, this message translates to:
  /// **'All Quizzes'**
  String get allQuizzes;

  /// No description provided for @noAssignments.
  ///
  /// In en, this message translates to:
  /// **'No assignments match this filter'**
  String get noAssignments;

  /// No description provided for @noQuizzes.
  ///
  /// In en, this message translates to:
  /// **'No quizzes match this filter'**
  String get noQuizzes;

  /// No description provided for @noPerformanceData.
  ///
  /// In en, this message translates to:
  /// **'No students match this filter'**
  String get noPerformanceData;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @topPerformers.
  ///
  /// In en, this message translates to:
  /// **'Top Performers'**
  String get topPerformers;

  /// No description provided for @submittedCount.
  ///
  /// In en, this message translates to:
  /// **'{submitted}/{total} submitted'**
  String submittedCount(int submitted, int total);

  /// No description provided for @pendingReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} to review'**
  String pendingReviewCount(int count);

  /// No description provided for @attemptedCount.
  ///
  /// In en, this message translates to:
  /// **'{attempted}/{total} attempted'**
  String attemptedCount(int attempted, int total);

  /// No description provided for @passedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} passed'**
  String passedCount(int count);

  /// No description provided for @notAttemptedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} not attempted'**
  String notAttemptedCount(int count);

  /// No description provided for @overallScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Overall score: {score}%'**
  String overallScoreLabel(int score);

  /// No description provided for @lessonsProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total}'**
  String lessonsProgress(int completed, int total);

  /// No description provided for @assignmentsProgress.
  ///
  /// In en, this message translates to:
  /// **'Assignments: {submitted}/{total} submitted'**
  String assignmentsProgress(int submitted, int total);

  /// No description provided for @studentSubmissions.
  ///
  /// In en, this message translates to:
  /// **'Student Submissions'**
  String get studentSubmissions;

  /// No description provided for @notSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Not submitted'**
  String get notSubmitted;

  /// No description provided for @awaitingReview.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review'**
  String get awaitingReview;

  /// No description provided for @graded.
  ///
  /// In en, this message translates to:
  /// **'Graded'**
  String get graded;

  /// No description provided for @createAssignment.
  ///
  /// In en, this message translates to:
  /// **'Create Assignment'**
  String get createAssignment;

  /// No description provided for @editAssignment.
  ///
  /// In en, this message translates to:
  /// **'Edit Assignment'**
  String get editAssignment;

  /// No description provided for @createQuiz.
  ///
  /// In en, this message translates to:
  /// **'Create Quiz'**
  String get createQuiz;

  /// No description provided for @editQuiz.
  ///
  /// In en, this message translates to:
  /// **'Edit Quiz'**
  String get editQuiz;

  /// No description provided for @assignmentTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignment Title'**
  String get assignmentTitleLabel;

  /// No description provided for @assignmentTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an assignment title'**
  String get assignmentTitleRequired;

  /// No description provided for @assignmentInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get assignmentInstructions;

  /// No description provided for @assignmentInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what students should submit...'**
  String get assignmentInstructionsHint;

  /// No description provided for @assignmentEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Link this assignment to a lesson and write clear instructions for students.'**
  String get assignmentEditorHint;

  /// No description provided for @attachAssignmentFile.
  ///
  /// In en, this message translates to:
  /// **'Attach Reference File'**
  String get attachAssignmentFile;

  /// No description provided for @selectLesson.
  ///
  /// In en, this message translates to:
  /// **'Link to Lesson'**
  String get selectLesson;

  /// No description provided for @selectLessonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a lesson'**
  String get selectLessonRequired;

  /// No description provided for @lessonWeekOption.
  ///
  /// In en, this message translates to:
  /// **'Week {week} — {title}'**
  String lessonWeekOption(int week, String title);

  /// No description provided for @quizTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Quiz Title'**
  String get quizTitleLabel;

  /// No description provided for @quizTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quiz title'**
  String get quizTitleRequired;

  /// No description provided for @quizEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Build quiz questions with multiple-choice answers and mark the correct option.'**
  String get quizEditorHint;

  /// No description provided for @quizQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get quizQuestions;

  /// No description provided for @addQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get addQuestion;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionNumber(int number);

  /// No description provided for @questionText.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionText;

  /// No description provided for @optionLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String optionLabel(int number);

  /// No description provided for @correctAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Select the radio button for the correct answer'**
  String get correctAnswerHint;

  /// No description provided for @instructionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter assignment instructions'**
  String get instructionsRequired;

  /// No description provided for @quizQuestionsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Add at least one complete question with all options filled'**
  String get quizQuestionsInvalid;

  /// No description provided for @saveAssessment.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAssessment;

  /// No description provided for @assessmentSaved.
  ///
  /// In en, this message translates to:
  /// **'Assessment saved successfully'**
  String get assessmentSaved;

  /// No description provided for @needsSetup.
  ///
  /// In en, this message translates to:
  /// **'Needs setup'**
  String get needsSetup;

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionsCount(int count);

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @likesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String likesCount(int count);

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @commentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} comments'**
  String commentsCount(int count);

  /// No description provided for @addCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get addCommentHint;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Update status'**
  String get changeStatus;

  /// No description provided for @studentPrayerRequests.
  ///
  /// In en, this message translates to:
  /// **'Student Prayer Requests'**
  String get studentPrayerRequests;

  /// No description provided for @teacherPrayerViewHint.
  ///
  /// In en, this message translates to:
  /// **'Students submit prayer requests. View them here and join in prayer with likes and comments.'**
  String get teacherPrayerViewHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
