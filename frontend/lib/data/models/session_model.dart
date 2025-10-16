class SessionModel {
  final int id, classId;
  final DateTime startsAt, endsAt;
  final String status;
  final int? qrTtl;
  SessionModel(
      {required this.id,
      required this.classId,
      required this.startsAt,
      required this.endsAt,
      required this.status,
      this.qrTtl});
  factory SessionModel.fromJson(Map<String, dynamic> j) => SessionModel(
      id: j['id'],
      classId: j['class_id'],
      startsAt: DateTime.parse(j['starts_at']),
      endsAt: DateTime.parse(j['ends_at']),
      status: j['status'] ?? 'scheduled',
      qrTtl: j['qr_ttl']);
}
