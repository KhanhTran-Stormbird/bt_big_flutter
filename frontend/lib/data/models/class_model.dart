class ClassModel {
  final int id;
  final String name;
  final String subject;
  final String term;
  ClassModel(
      {required this.id,
      required this.name,
      required this.subject,
      required this.term});
  factory ClassModel.fromJson(Map<String, dynamic> j) => ClassModel(
      id: j['id'],
      name: j['name'] ?? '',
      subject: j['subject'] ?? '',
      term: j['term'] ?? '');
}
