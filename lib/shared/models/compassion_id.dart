class CompassionId {
  const CompassionId({
    required this.id,
    required this.projectId,
    this.studentName,
    required this.isAssigned,
  });

  final int id;
  final String projectId;
  final String? studentName;
  final bool isAssigned;

  factory CompassionId.fromMap(Map<String, Object?> map) {
    return CompassionId(
      id: map['id'] as int,
      projectId: map['project_id'] as String,
      studentName: map['student_name'] as String?,
      isAssigned: (map['is_assigned'] as int) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'student_name': studentName,
      'is_assigned': isAssigned ? 1 : 0,
    };
  }
}
