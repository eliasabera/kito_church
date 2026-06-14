import 'package:kitoapp/features/admin/models/sponsor.dart';
import 'package:kitoapp/features/admin/models/student_sponsorship_link.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';

class SponsorshipSupabaseService {
  SponsorshipSupabaseService._();

  static const _sponsorsTable = 'sponsors';
  static const _linksTable = 'student_sponsorship_links';
  static const _usersTable = 'users';
  static const _linkSelect =
      'id, student_id, sponsor_id, linked_date, student:users!student_id(full_name), sponsor:sponsors!sponsor_id(name, country)';

  static Sponsor sponsorFromRow(Map<String, dynamic> row) {
    return Sponsor(
      id: row['id'] as String,
      name: row['name'] as String,
      country: row['country'] as String,
      email: row['email'] as String?,
      message: row['message'] as String?,
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

  static Future<List<Sponsor>> fetchSponsors() async {
    final rows = await SupabaseAuthService.client
        .from(_sponsorsTable)
        .select('id, name, country, email, message')
        .order('name');

    return (rows as List)
        .map((row) => sponsorFromRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  static Future<List<({String id, String name, String university})>>
      fetchStudents() async {
    final rows = await SupabaseAuthService.client
        .from(_usersTable)
        .select('id, full_name, profiles(university)')
        .eq('role', 'student')
        .order('full_name');

    return (rows as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final profile = _nestedMap(map['profiles']);
      return (
        id: map['id'] as String,
        name: map['full_name'] as String? ?? 'Student',
        university: profile?['university'] as String? ?? '',
      );
    }).toList();
  }

  static Future<List<StudentSponsorshipLink>> fetchLinks() async {
    final rows = await SupabaseAuthService.client
        .from(_linksTable)
        .select(_linkSelect)
        .order('linked_date', ascending: false);

    return (rows as List)
        .map((row) => linkFromRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  static Future<Sponsor> addSponsor({
    required String name,
    required String country,
    String? email,
    String? message,
  }) async {
    final row = await SupabaseAuthService.client
        .from(_sponsorsTable)
        .insert({
          'name': name.trim(),
          'country': country.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          if (message != null && message.trim().isNotEmpty)
            'message': message.trim(),
        })
        .select('id, name, country, email, message')
        .single();

    return sponsorFromRow(Map<String, dynamic>.from(row));
  }

  static Future<StudentSponsorshipLink> assignLink({
    required String studentId,
    required String sponsorId,
  }) async {
    await SupabaseAuthService.client
        .from(_linksTable)
        .delete()
        .eq('student_id', studentId);
    await SupabaseAuthService.client
        .from(_linksTable)
        .delete()
        .eq('sponsor_id', sponsorId);

    final row = await SupabaseAuthService.client
        .from(_linksTable)
        .insert({
          'student_id': studentId,
          'sponsor_id': sponsorId,
        })
        .select(_linkSelect)
        .single();

    return linkFromRow(Map<String, dynamic>.from(row));
  }

  static Future<void> removeLink(String studentId) async {
    await SupabaseAuthService.client
        .from(_linksTable)
        .delete()
        .eq('student_id', studentId);
  }

  static Map<String, dynamic>? _nestedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
