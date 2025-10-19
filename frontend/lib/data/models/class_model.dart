class ClassModel {
  final int id;
  final String name;
  final String subject;
  final String term;
  final int? lecturerId;
  final String? lecturerName;
  final String? lecturerEmail;

  ClassModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.term,
    this.lecturerId,
    this.lecturerName,
    this.lecturerEmail,
  });

  factory ClassModel.fromJson(Map<String, dynamic> j) {
    final lecturer = j['lecturer'];
    return ClassModel(
      id: j['id'] ?? 0,
      name: j['name'] ?? '',
      subject: j['subject'] ?? '',
      term: j['term'] ?? '',
      lecturerId: j['lecturer_id'] ?? j['lecturerId'],
      lecturerName: j['lecturer_name'] ??
          (lecturer is Map<String, dynamic> ? lecturer['name'] : null),
      lecturerEmail: j['lecturer_email'] ??
          (lecturer is Map<String, dynamic> ? lecturer['email'] : null),
    );
  }
}
