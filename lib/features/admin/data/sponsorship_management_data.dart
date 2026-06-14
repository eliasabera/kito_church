import 'package:kitoapp/features/admin/models/sponsor.dart';
import 'package:kitoapp/features/admin/models/student_sponsorship_link.dart';

class SponsorshipManagementData {
  SponsorshipManagementData._();

  static const students = [
    (id: 'u1', name: 'Abel Tesfaye', university: 'Addis Ababa University'),
    (id: 'u2', name: 'Hanna Bekele', university: 'Hawassa University'),
    (id: 'u3', name: 'Samuel Girma', university: 'Bahir Dar University'),
    (id: 'u4', name: 'Marta Haile', university: 'Jimma University'),
    (id: 'u5', name: 'Daniel Worku', university: 'Mekelle University'),
  ];

  static const initialSponsors = [
    Sponsor(
      id: 's1',
      name: 'John Miller',
      country: 'USA',
      email: 'john.miller@email.com',
      message:
          'Abel, I am so proud of your progress in university and in your faith. '
          'Keep serving in your church. I pray for you every week.',
    ),
    Sponsor(
      id: 's2',
      name: 'Sarah Johnson',
      country: 'Canada',
      email: 'sarah.j@email.com',
      message:
          'Hanna, your dedication to your studies inspires me. Keep shining!',
    ),
    Sponsor(
      id: 's3',
      name: 'Robert Smith',
      country: 'UK',
      email: 'robert.smith@email.com',
    ),
    Sponsor(
      id: 's4',
      name: 'Emily Davis',
      country: 'Australia',
      email: 'emily.davis@email.com',
    ),
  ];

  static final initialLinks = [
    StudentSponsorshipLink(
      studentId: 'u1',
      studentName: 'Abel Tesfaye',
      sponsorId: 's1',
      sponsorName: 'John Miller',
      sponsorCountry: 'USA',
      linkedDate: DateTime(2019, 3, 1),
    ),
    StudentSponsorshipLink(
      studentId: 'u2',
      studentName: 'Hanna Bekele',
      sponsorId: 's2',
      sponsorName: 'Sarah Johnson',
      sponsorCountry: 'Canada',
      linkedDate: DateTime(2024, 9, 15),
    ),
  ];
}
