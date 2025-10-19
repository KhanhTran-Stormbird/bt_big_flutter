import 'user.dart';

class ClassModel {
  final int id;
  final String name;
  final String subject;
  final String term;
  final int? lecturerId;
  final String? lecturerName;
  final String? lecturerEmail;
  final List<User> students;

  ClassModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.term,
    this.lecturerId,
    this.lecturerName,
    this.lecturerEmail,
    this.students = const [],
  });

  factory ClassModel.fromJson(Map<String, dynamic> j) {
    final lecturer = j['lecturer'];
    final rawStudents = j['students'];
    final students = rawStudents is List
        ? rawStudents
            .whereType<Map<String, dynamic>>()
            .map(User.fromJson)
            .toList()
        : <User>[];

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
      students: students,
    );
  }
}
