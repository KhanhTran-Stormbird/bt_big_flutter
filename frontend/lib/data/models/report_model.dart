class ReportSummary {
  final int totalSessions;
  final int totalPresent;
  final int totalAbsent;

  ReportSummary({
    required this.totalSessions,
    required this.totalPresent,
    required this.totalAbsent,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return ReportSummary(
      totalSessions: payload['total_sessions'] ?? 0,
      totalPresent: payload['total_present'] ?? 0,
      totalAbsent: payload['total_absent'] ?? 0,
    );
  }
}
