class SessionModel {
  final int id;
  final int classId;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final int? qrTtl;

  SessionModel({
    required this.id,
    required this.classId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.qrTtl,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        id: json['id'] ?? json['session_id'] ?? 0,
        classId: json['class_id'] ?? json['classId'] ?? 0,
        startsAt: _parseDate(json['starts_at']) ??
            _parseDate(json['startsAt']) ??
            DateTime.now(),
        endsAt: _parseDate(json['ends_at']) ??
            _parseDate(json['endsAt']) ??
            DateTime.now(),
        status: (json['status'] ?? 'scheduled').toString(),
        qrTtl: json['qr_ttl'] ?? json['ttl'],
      );
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
