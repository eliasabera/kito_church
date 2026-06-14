class StudentSponsorshipLink {
  const StudentSponsorshipLink({
    required this.studentId,
    required this.studentName,
    required this.sponsorId,
    required this.sponsorName,
    required this.sponsorCountry,
    required this.linkedDate,
  });

  final String studentId;
  final String studentName;
  final String sponsorId;
  final String sponsorName;
  final String sponsorCountry;
  final DateTime linkedDate;

  StudentSponsorshipLink copyWith({
    String? studentId,
    String? studentName,
    String? sponsorId,
    String? sponsorName,
    String? sponsorCountry,
    DateTime? linkedDate,
  }) {
    return StudentSponsorshipLink(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      sponsorId: sponsorId ?? this.sponsorId,
      sponsorName: sponsorName ?? this.sponsorName,
      sponsorCountry: sponsorCountry ?? this.sponsorCountry,
      linkedDate: linkedDate ?? this.linkedDate,
    );
  }
}
