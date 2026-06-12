import 'package:kitoapp/core/enums/app_enums.dart';

class Gift {
  const Gift({
    required this.id,
    required this.studentId,
    required this.title,
    required this.type,
    required this.status,
    this.message,
  });

  final String id;
  final String studentId;
  final String title;
  final GiftType type;
  final GiftStatus status;
  final String? message;
}
