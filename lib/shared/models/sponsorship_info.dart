class SponsorshipInfo {
  const SponsorshipInfo({
    required this.studentId,
    required this.projectId,
    required this.sponsorName,
    required this.sponsorCountry,
    required this.startDate,
    required this.status,
  });

  final String studentId;
  final String projectId;
  final String sponsorName;
  final String sponsorCountry;
  final DateTime startDate;
  final String status;
}
