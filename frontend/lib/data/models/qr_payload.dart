class QrPayload {
  final int sessionId;
  final String svg;
  final int ttl;

  QrPayload({
    required this.sessionId,
    required this.svg,
    required this.ttl,
  });

  factory QrPayload.fromJson(Map<String, dynamic> json) => QrPayload(
        sessionId: json['session_id'] ?? json['sessionId'] ?? 0,
        svg: json['svg'] ?? '',
        ttl: json['ttl'] ?? json['qr_ttl'] ?? 0,
      );
}
