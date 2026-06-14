import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/admin/models/managed_gift.dart';
import 'package:kitoapp/features/admin/models/student_sponsorship_link.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';

class GiftsSupabaseService {
  GiftsSupabaseService._();

  static const _giftsTable = 'gifts';
  static const _linksTable = 'student_sponsorship_links';
  static const _linkSelect =
      'id, student_id, sponsor_id, linked_date, student:users!student_id(full_name), sponsor:sponsors!sponsor_id(name, country)';
  static const _giftSelect =
      'id, student_id, sponsor_id, title, description, gift_date, type, status, announced, announced_at, student:users!student_id(full_name), sponsor:sponsors!sponsor_id(name)';

  static ManagedGift giftFromRow(Map<String, dynamic> row) {
    final student = _nestedMap(row['student']);
    final sponsor = _nestedMap(row['sponsor']);

    return ManagedGift(
      id: row['id'] as String,
      studentId: row['student_id'] as String,
      studentName: student?['full_name'] as String? ?? 'Student',
      sponsorId: row['sponsor_id'] as String,
      sponsorName: sponsor?['name'] as String? ?? 'Sponsor',
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      date: DateTime.parse(row['gift_date'] as String),
      type: _parseGiftType(row['type'] as String?),
      status: _parseGiftStatus(row['status'] as String?),
      announced: row['announced'] as bool? ?? false,
      announcedAt: row['announced_at'] == null
          ? null
          : DateTime.parse(row['announced_at'] as String),
    );
  }

  static StudentSponsorshipLink linkFromRow(Map<String, dynamic> row) {
    final student = _nestedMap(row['student']);
    final sponsor = _nestedMap(row['sponsor']);

    return StudentSponsorshipLink(
      studentId: row['student_id'] as String,
      studentName: student?['full_name'] as String? ?? 'Student',
      sponsorId: row['sponsor_id'] as String,
      sponsorName: sponsor?['name'] as String? ?? 'Sponsor',
      sponsorCountry: sponsor?['country'] as String? ?? '',
      linkedDate: DateTime.parse(row['linked_date'] as String),
    );
  }

  static Future<List<ManagedGift>> fetchAllGifts() async {
    final rows = await SupabaseAuthService.client
        .from(_giftsTable)
        .select(_giftSelect)
        .order('gift_date', ascending: false);

    return (rows as List)
        .map((row) => giftFromRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  static Future<List<StudentSponsorshipLink>> fetchSponsorshipLinks() async {
    final rows = await SupabaseAuthService.client
        .from(_linksTable)
        .select(_linkSelect)
        .order('linked_date', ascending: false);

    return (rows as List)
        .map((row) => linkFromRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  static Future<ManagedGift> addGift({
    required String studentId,
    required String sponsorId,
    required String title,
    required String description,
    required GiftType type,
  }) async {
    final row = await SupabaseAuthService.client
        .from(_giftsTable)
        .insert({
          'student_id': studentId,
          'sponsor_id': sponsorId,
          'title': title.trim(),
          'description': description.trim(),
          'type': type.name,
          'status': GiftStatus.pending.name,
          'announced': false,
        })
        .select(_giftSelect)
        .single();

    return giftFromRow(Map<String, dynamic>.from(row));
  }

  static Future<ManagedGift> announceGift(String giftId) async {
    final row = await SupabaseAuthService.client
        .from(_giftsTable)
        .update({
          'announced': true,
          'announced_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', giftId)
        .select(_giftSelect)
        .single();

    return giftFromRow(Map<String, dynamic>.from(row));
  }

  static Future<ManagedGift> updateGiftStatus(
    String giftId,
    GiftStatus status,
  ) async {
    final row = await SupabaseAuthService.client
        .from(_giftsTable)
        .update({'status': status.name})
        .eq('id', giftId)
        .select(_giftSelect)
        .single();

    return giftFromRow(Map<String, dynamic>.from(row));
  }

  static Map<String, dynamic>? _nestedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static GiftType _parseGiftType(String? value) {
    return GiftType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => GiftType.physical,
    );
  }

  static GiftStatus _parseGiftStatus(String? value) {
    return GiftStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => GiftStatus.pending,
    );
  }
}
