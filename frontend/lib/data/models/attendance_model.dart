class AttendanceModel {
  final int id;
  final int sessionId;
  final int studentId;
  final int? classId;
  final String status;
  final DateTime checkedAt;
  final DateTime? sessionStartsAt;
  final DateTime? sessionEndsAt;
  final String? className;
  final String? classSubject;
  final double? distance;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    required this.checkedAt,
    this.classId,
    this.sessionStartsAt,
    this.sessionEndsAt,
    this.className,
    this.classSubject,
    this.distance,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> j) => AttendanceModel(
        id: j['id'] as int,
        sessionId: j['session_id'] as int,
        studentId: j['student_id'] as int,
        status: (j['status'] ?? 'present') as String,
        checkedAt: DateTime.parse(j['checked_at'] as String),
        distance: (j['distance'] as num?)?.toDouble(),
        classId: j['class_id'] as int?,
        className: j['class_name'] as String?,
        classSubject: j['class_subject'] as String?,
        sessionStartsAt: j['session_starts_at'] != null
            ? DateTime.tryParse(j['session_starts_at'] as String)
            : null,
        sessionEndsAt: j['session_ends_at'] != null
            ? DateTime.tryParse(j['session_ends_at'] as String)
            : null,
      );
}
