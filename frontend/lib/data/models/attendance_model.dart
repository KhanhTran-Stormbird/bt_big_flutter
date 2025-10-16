class AttendanceModel {
  final int id, sessionId, studentId;
  final String status;
  final DateTime checkedAt;
  final double? distance;
  AttendanceModel(
      {required this.id,
      required this.sessionId,
      required this.studentId,
      required this.status,
      required this.checkedAt,
      this.distance});
  factory AttendanceModel.fromJson(Map<String, dynamic> j) => AttendanceModel(
      id: j['id'],
      sessionId: j['session_id'],
      studentId: j['student_id'],
      status: j['status'] ?? 'present',
      checkedAt: DateTime.parse(j['checked_at']),
      distance: (j['distance'] as num?)?.toDouble());
}
