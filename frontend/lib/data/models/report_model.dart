class ReportSummary {
  final int totalSessions, totalPresent, totalAbsent;
  ReportSummary(
      {required this.totalSessions,
      required this.totalPresent,
      required this.totalAbsent});
  factory ReportSummary.fromJson(Map<String, dynamic> j) => ReportSummary(
      totalSessions: j['total_sessions'] ?? 0,
      totalPresent: j['total_present'] ?? 0,
      totalAbsent: j['total_absent'] ?? 0);
}
