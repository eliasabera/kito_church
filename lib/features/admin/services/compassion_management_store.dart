import 'package:flutter/foundation.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/admin/models/managed_gift.dart';
import 'package:kitoapp/features/admin/models/sponsor.dart';
import 'package:kitoapp/features/admin/models/student_sponsorship_link.dart';
import 'package:kitoapp/features/admin/services/gifts_supabase_service.dart';
import 'package:kitoapp/features/admin/services/sponsorship_supabase_service.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/gifts/models/gift_item.dart';
import 'package:kitoapp/features/notifications/services/notifications_store.dart';
import 'package:kitoapp/features/sponsorship/data/sponsorship_data.dart';
import 'package:kitoapp/features/sponsorship/models/sponsorship_info.dart';

class CompassionManagementStore extends ChangeNotifier {
  CompassionManagementStore({NotificationsStore? notificationsStore})
      : _notificationsStore = notificationsStore;

  final NotificationsStore? _notificationsStore;
  final List<Sponsor> _sponsors = [];
  final List<StudentSponsorshipLink> _links = [];
  final List<({String id, String name, String university})> _students = [];
  final List<ManagedGift> _gifts = [];
  bool _giftsLoading = false;
  String? _giftsError;
  bool _sponsorshipLoading = false;
  String? _sponsorshipError;

  bool get giftsLoading => _giftsLoading;
  String? get giftsError => _giftsError;
  bool get sponsorshipLoading => _sponsorshipLoading;
  String? get sponsorshipError => _sponsorshipError;

  static String get currentStudentId => AuthSession.studentId;

  List<Sponsor> get sponsors => List.unmodifiable(_sponsors);
  List<StudentSponsorshipLink> get links => List.unmodifiable(_links);
  List<ManagedGift> get gifts => List.unmodifiable(_gifts);

  Future<void> loadGiftData() async {
    _giftsLoading = true;
    _giftsError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        GiftsSupabaseService.fetchAllGifts(),
        SponsorshipSupabaseService.fetchLinks(),
      ]);
      _gifts
        ..clear()
        ..addAll(results[0] as List<ManagedGift>);
      _links
        ..clear()
        ..addAll(results[1] as List<StudentSponsorshipLink>);
    } catch (error, stackTrace) {
      debugPrint('CompassionManagementStore.loadGiftData failed: $error\n$stackTrace');
      _giftsError = error.toString();
    } finally {
      _giftsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSponsorshipData() async {
    _sponsorshipLoading = true;
    _sponsorshipError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        SponsorshipSupabaseService.fetchSponsors(),
        SponsorshipSupabaseService.fetchStudents(),
        SponsorshipSupabaseService.fetchLinks(),
      ]);
      _sponsors
        ..clear()
        ..addAll(results[0] as List<Sponsor>);
      _students
        ..clear()
        ..addAll(
          results[1] as List<({String id, String name, String university})>,
        );
      _links
        ..clear()
        ..addAll(results[2] as List<StudentSponsorshipLink>);
    } catch (error, stackTrace) {
      debugPrint(
        'CompassionManagementStore.loadSponsorshipData failed: $error\n$stackTrace',
      );
      _sponsorshipError = error.toString();
    } finally {
      _sponsorshipLoading = false;
      notifyListeners();
    }
  }

  List<({String id, String name, String university})> get students =>
      List.unmodifiable(_students);

  Sponsor? sponsorById(String id) {
    for (final sponsor in _sponsors) {
      if (sponsor.id == id) return sponsor;
    }
    return null;
  }

  StudentSponsorshipLink? linkForStudent(String studentId) {
    for (final link in _links) {
      if (link.studentId == studentId) return link;
    }
    return null;
  }

  String? linkedStudentIdForSponsor(String sponsorId) {
    for (final link in _links) {
      if (link.sponsorId == sponsorId) return link.studentId;
    }
    return null;
  }

  List<Sponsor> get availableSponsors {
    return _sponsors
        .where((sponsor) => linkedStudentIdForSponsor(sponsor.id) == null)
        .toList();
  }

  List<Sponsor> selectableSponsorsForStudent(String studentId) {
    return _sponsors.where((sponsor) {
      final linkedStudent = linkedStudentIdForSponsor(sponsor.id);
      return linkedStudent == null || linkedStudent == studentId;
    }).toList();
  }

  SponsorshipManagementSummary get sponsorshipSummary {
    final linked = _links.length;
    final totalStudents = students.length;
    return SponsorshipManagementSummary(
      totalStudents: totalStudents,
      linkedStudents: linked,
      unlinkedStudents: totalStudents - linked,
      totalSponsors: _sponsors.length,
      availableSponsors: availableSponsors.length,
    );
  }

  ManagedGiftSummary get giftSummary {
    return ManagedGiftSummary(
      total: _gifts.length,
      awaitingAnnouncement: _gifts.where((g) => !g.announced).length,
      announced: _gifts.where((g) => g.announced).length,
      pending: _gifts.where((g) => g.status == GiftStatus.pending).length,
      received: _gifts.where((g) => g.status == GiftStatus.received).length,
      delivered: _gifts.where((g) => g.status == GiftStatus.delivered).length,
    );
  }

  List<({String id, String name, String university, StudentSponsorshipLink? link})>
      studentsWithLinks({
    SponsorshipFilter filter = SponsorshipFilter.all,
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return students
        .map((student) {
          final link = linkForStudent(student.id);
          return (
            id: student.id,
            name: student.name,
            university: student.university,
            link: link,
          );
        })
        .where((entry) {
          final matchesFilter = switch (filter) {
            SponsorshipFilter.all => true,
            SponsorshipFilter.linked => entry.link != null,
            SponsorshipFilter.unlinked => entry.link == null,
          };
          if (!matchesFilter) return false;
          if (normalizedQuery.isEmpty) return true;
          final sponsorName = entry.link?.sponsorName.toLowerCase() ?? '';
          return entry.name.toLowerCase().contains(normalizedQuery) ||
              entry.university.toLowerCase().contains(normalizedQuery) ||
              sponsorName.contains(normalizedQuery);
        })
        .toList();
  }

  List<ManagedGift> filteredGifts({
    AdminGiftFilter filter = AdminGiftFilter.all,
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return _gifts.where((gift) {
      final matchesFilter = switch (filter) {
        AdminGiftFilter.all => true,
        AdminGiftFilter.awaitingAnnouncement => !gift.announced,
        AdminGiftFilter.announced => gift.announced,
        AdminGiftFilter.pending => gift.status == GiftStatus.pending,
        AdminGiftFilter.received => gift.status == GiftStatus.received,
        AdminGiftFilter.delivered => gift.status == GiftStatus.delivered,
      };
      if (!matchesFilter) return false;
      if (normalizedQuery.isEmpty) return true;
      return gift.title.toLowerCase().contains(normalizedQuery) ||
          gift.studentName.toLowerCase().contains(normalizedQuery) ||
          gift.sponsorName.toLowerCase().contains(normalizedQuery);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<ManagedGift> announcedGiftsForStudent(String studentId) {
    return _gifts
        .where((gift) => gift.studentId == studentId && gift.announced)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  GiftSummary giftSummaryForStudent(String studentId) {
    final items = announcedGiftsForStudent(studentId);
    return GiftSummary(
      total: items.length,
      pending: items.where((g) => g.status == GiftStatus.pending).length,
      received: items.where((g) => g.status == GiftStatus.received).length,
      delivered: items.where((g) => g.status == GiftStatus.delivered).length,
    );
  }

  SponsorProfile? sponsorProfileForStudent(String studentId) {
    final link = linkForStudent(studentId);
    if (link == null) return null;
    final sponsor = sponsorById(link.sponsorId);
    if (sponsor == null) return null;

    final studentGifts = announcedGiftsForStudent(studentId);
    return SponsorProfile(
      name: sponsor.name,
      country: sponsor.country,
      sponsoredSince: '${link.linkedDate.year}',
      lettersExchanged: SponsorshipData.letters.length,
      giftsReceived: studentGifts.length,
      message: sponsor.message ??
          'Your sponsor is praying for you and cheering you on in your studies.',
    );
  }

  Future<bool> addSponsor({
    required String name,
    required String country,
    String? email,
    String? message,
  }) async {
    try {
      final saved = await SponsorshipSupabaseService.addSponsor(
        name: name,
        country: country,
        email: email,
        message: message,
      );
      _sponsors.add(saved);
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('CompassionManagementStore.addSponsor failed: $error\n$stackTrace');
      _sponsorshipError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignSponsor({
    required String studentId,
    required String studentName,
    required String sponsorId,
  }) async {
    try {
      final saved = await SponsorshipSupabaseService.assignLink(
        studentId: studentId,
        sponsorId: sponsorId,
      );
      _links.removeWhere((link) => link.studentId == studentId);
      _links.removeWhere((link) => link.sponsorId == sponsorId);
      _links.add(saved);
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'CompassionManagementStore.assignSponsor failed: $error\n$stackTrace',
      );
      _sponsorshipError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeSponsor({
    required String studentId,
    required String studentName,
    required String newSponsorId,
  }) {
    return assignSponsor(
      studentId: studentId,
      studentName: studentName,
      sponsorId: newSponsorId,
    );
  }

  Future<bool> removeSponsorLink(String studentId) async {
    try {
      await SponsorshipSupabaseService.removeLink(studentId);
      _links.removeWhere((link) => link.studentId == studentId);
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'CompassionManagementStore.removeSponsorLink failed: $error\n$stackTrace',
      );
      _sponsorshipError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addGift({
    required String studentId,
    required String title,
    required String description,
    required GiftType type,
  }) async {
    final link = linkForStudent(studentId);
    if (link == null) return false;

    try {
      final saved = await GiftsSupabaseService.addGift(
        studentId: studentId,
        sponsorId: link.sponsorId,
        title: title,
        description: description,
        type: type,
      );
      _gifts.insert(0, saved);
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('CompassionManagementStore.addGift failed: $error\n$stackTrace');
      _giftsError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> announceGift(String giftId) async {
    final index = _gifts.indexWhere((gift) => gift.id == giftId);
    if (index == -1) return false;
    final gift = _gifts[index];

    try {
      final saved = await GiftsSupabaseService.announceGift(giftId);
      _gifts[index] = saved;
      _notificationsStore?.notifyGiftArrived(
        studentId: gift.studentId,
        giftTitle: gift.title,
      );
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('CompassionManagementStore.announceGift failed: $error\n$stackTrace');
      _giftsError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGiftStatus(String giftId, GiftStatus status) async {
    final index = _gifts.indexWhere((gift) => gift.id == giftId);
    if (index == -1) return false;

    try {
      final saved = await GiftsSupabaseService.updateGiftStatus(giftId, status);
      _gifts[index] = saved;
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'CompassionManagementStore.updateGiftStatus failed: $error\n$stackTrace',
      );
      _giftsError = error.toString();
      notifyListeners();
      return false;
    }
  }
}
