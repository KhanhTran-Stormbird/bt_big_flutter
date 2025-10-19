import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/colors.dart';

// add Session model
class Session {
  final String id;
  final String className;
  final String subject;
  final TimeOfDay start;
  final TimeOfDay end;

  Session({
    required this.id,
    required this.className,
    required this.subject,
    required this.start,
    required this.end,
  });
}

// change LecturerDashboardPage to StatefulWidget to keep sessions
class LecturerDashboardPage extends StatefulWidget {
  const LecturerDashboardPage({super.key});

  @override
  State<LecturerDashboardPage> createState() => _LecturerDashboardPageState();
}

class _LecturerDashboardPageState extends State<LecturerDashboardPage> {
  final List<Session> _sessions = [];
  Session? _lastSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, Giảng viên!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quản lý lớp học, tạo buổi điểm danh và theo dõi trạng thái.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              LecturerStatCard(
                title: 'Lớp đang dạy',
                value: '05',
                icon: Icons.class_,
                color: Color(0xFFEEF2FF),
                iconColor: Color(0xFF4338CA),
              ),
              LecturerStatCard(
                title: 'Buổi hôm nay',
                value: '02',
                icon: Icons.today,
                color: Color(0xFFFFF7ED),
                iconColor: Color(0xFFD97706),
              ),
              LecturerStatCard(
                title: 'Đang mở',
                value: '01',
                icon: Icons.qr_code,
                color: Color(0xFFEFFDEE),
                iconColor: Color(0xFF15803D),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Tác vụ nhanh',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              QuickActionChip(
                label: 'Tạo buổi mới',
                icon: Icons.add_circle,
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.78,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      builder: (_, controller) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: SingleChildScrollView(
                          controller: controller,
                          child: CreateSessionForm(
                            onCreate: (session) {
                              setState(() {
                                _sessions.add(session);
                                _lastSession = session;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              QuickActionChip(
                label: 'Xuất QR điểm danh',
                icon: Icons.qr_code_2,
                onTap: () {
                  if (_lastSession == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có buổi học nào vừa tạo.')));
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('QR điểm danh', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text('${_lastSession!.className} • ${_lastSession!.subject}', style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0,4))],
                              ),
                              child: Container(
                                width: 200,
                                height: 200,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  _lastSession!.id,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.copy),
                                    label: const Text('Sao chép mã'),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: _lastSession!.id));
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép mã QR.')));
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.check),
                                    label: const Text('Đóng'),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              QuickActionChip(
                label: 'Cập nhật sĩ số',
                icon: Icons.group_add,
                onTap: () {
                  if (_sessions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có buổi học. Vui lòng tạo buổi trước.')));
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AttendanceManagerPage(sessions: _sessions)),
                  );
                },
              ),
              QuickActionChip(
                label: 'Xuất báo cáo',
                icon: Icons.upload_file,
                onTap: () {
                  if (_sessions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có buổi học để xuất báo cáo.')));
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ReportListPage(sessions: _sessions)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Buổi đang diễn ra',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const LecturerSessionTile(
            className: 'KP336 - Lập trình Flutter',
            time: '08:00 - 10:00',
            status: 'Đang nhận điểm danh',
            statusColor: Color(0xFF22C55E),
          ),
          const SizedBox(height: 12),
          const LecturerSessionTile(
            className: 'KT234 - Nhập môn AI',
            time: '13:30 - 15:30',
            status: 'Sắp bắt đầu',
            statusColor: Color(0xFFF97316),
          ),
        ],
      ),
    );
  }
}

class LecturerStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const LecturerStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 0,
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withValues(alpha: 0.12),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const QuickActionChip({super.key, required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0,4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}


// Create session form shown in modal bottom sheet
class CreateSessionForm extends StatefulWidget {
  final void Function(Session) onCreate;

  const CreateSessionForm({super.key, required this.onCreate});

  @override
  State<CreateSessionForm> createState() => _CreateSessionFormState();
}

class _CreateSessionFormState extends State<CreateSessionForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClass;
  String? _selectedSubject;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _classes = ['KP336', 'KT234', 'CS101', 'IT202'];
  final List<String> _subjects = ['Lập trình Flutter', 'Nhập môn AI', 'Cấu trúc dữ liệu', 'Mạng máy tính'];

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? (_startTime ?? TimeOfDay(hour: 8, minute: 0)) : (_endTime ?? TimeOfDay(hour: 10, minute: 0));
    final t = await showTimePicker(context: context, initialTime: initial, builder: (_, child) {
      return Theme(data: Theme.of(context).copyWith(timePickerTheme: const TimePickerThemeData()), child: child!);
    });
    if (t == null) return;
    setState(() {
      if (isStart) _startTime = t;
      else _endTime = t;
    });
  }

  String _formatTime(TimeOfDay? t) => t == null ? '--:--' : t.format(context);

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn thời gian bắt đầu và kết thúc.')));
      return;
    }
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thời gian kết thúc phải sau thời gian bắt đầu.')));
      return;
    }

    final newSession = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      className: _selectedClass!,
      subject: _selectedSubject!,
      start: _startTime!,
      end: _endTime!,
    );
    widget.onCreate(newSession);

    // demo: in real app send to backend or state management
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo buổi học thành công.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          alignment: Alignment.center,
          child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 12),
        Text('Tạo buổi học mới', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Nhập thông tin buổi học', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Class dropdown
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: InputDecoration(labelText: 'Tên lớp', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedClass = v),
                validator: (v) => v == null ? 'Vui lòng chọn lớp' : null,
              ),
              const SizedBox(height: 12),
              // Subject dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(labelText: 'Tên môn', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedSubject = v),
                validator: (v) => v == null ? 'Vui lòng chọn môn' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(true),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Bắt đầu', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          controller: TextEditingController(text: _formatTime(_startTime)),
                          validator: (_) => _startTime == null ? 'Chọn giờ bắt đầu' : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(false),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Kết thúc', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          controller: TextEditingController(text: _formatTime(_endTime)),
                          validator: (_) => _endTime == null ? 'Chọn giờ kết thúc' : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Huỷ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Lưu và tạo', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class LecturerSessionTile extends StatelessWidget {
  final String className;
  final String time;
  final String status;
  final Color statusColor;

  const LecturerSessionTile({
    super.key,
    required this.className,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFEF2F2),
          child: Icon(Icons.class_, color: Color(0xFFDC2626)),
        ),
        title: Text(
          className,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(time),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
          ),
        ),
      ),
    );
  }
}

// ---------- Attendance & Report UI (append these classes to the end of the file) ----------

class Student {
  final String id;
  final String name;
  Student({required this.id, required this.name});
}

class AttendanceManagerPage extends StatefulWidget {
  final List<Session> sessions;
  const AttendanceManagerPage({super.key, required this.sessions});

  @override
  State<AttendanceManagerPage> createState() => _AttendanceManagerPageState();
}

class _AttendanceManagerPageState extends State<AttendanceManagerPage> {
  Session? _selectedSession;
  DateTime _selectedDate = DateTime.now();
  final List<Student> _students = [
    Student(id: 'S001', name: 'Nguyễn Văn A'),
    Student(id: 'S002', name: 'Trần Thị B'),
    Student(id: 'S003', name: 'Lê Văn C'),
    Student(id: 'S004', name: 'Phạm Thị D'),
    Student(id: 'S005', name: 'Hoàng E'),
  ];

  // map sessionId -> set of present student ids (simple in-memory storage)
  final Map<String, Set<String>> _attendance = {};

  Set<String> _presentFor(Session s) => _attendance[s.id] ?? <String>{};

  void _togglePresent(Session s, String studentId) {
    setState(() {
      final set = _attendance.putIfAbsent(s.id, () => <String>{});
      if (set.contains(studentId)) set.remove(studentId);
      else set.add(studentId);
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  @override
  void initState() {
    super.initState();
    if (widget.sessions.isNotEmpty) _selectedSession = widget.sessions.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật sĩ số'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Session>(
                        value: _selectedSession,
                        decoration: const InputDecoration(labelText: 'Chọn buổi', border: OutlineInputBorder()),
                        items: widget.sessions
                            .map((s) => DropdownMenuItem(value: s, child: Text('${s.className} • ${s.subject}')))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedSession = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _selectedSession == null
                  ? Center(child: Text('Chưa có buổi để cập nhật', style: theme.textTheme.bodyLarge))
                  : Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(child: Text('${_selectedSession!.className} • ${_selectedSession!.subject}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                                Text('Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: _students.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final st = _students[i];
                                final present = _presentFor(_selectedSession!).contains(st.id);
                                return ListTile(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  tileColor: present ? AppColors.surface.withOpacity(0.6) : null,
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFFFE0B2),
                                    child: Text(st.name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join(), style: const TextStyle(color: Colors.white)),
                                  ),
                                  title: Text(st.name),
                                  subtitle: Text(st.id),
                                  trailing: Switch(
                                    value: present,
                                    onChanged: (_) => _togglePresent(_selectedSession!, st.id),
                                  ),
                                  onTap: () => _togglePresent(_selectedSession!, st.id),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _attendance[_selectedSession!.id] = <String>{};
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đặt lại sĩ số.')));
                                    },
                                    child: const Text('Đặt lại'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final cnt = _presentFor(_selectedSession!).length;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lưu thành công — có $cnt sinh viên điểm danh.')));
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Text('Lưu', style: TextStyle(fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportListPage extends StatelessWidget {
  final List<Session> sessions;
  const ReportListPage({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo điểm danh'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: sessions.isEmpty
            ? Center(child: Text('Không có buổi để báo cáo', style: theme.textTheme.bodyLarge))
            : ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final s = sessions[i];
                  // sample counts (you could pass real counts from AttendanceManager)
                  final presentCount = (i + 2) % 6; // demo
                  final total = 30;
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      leading: CircleAvatar(backgroundColor: const Color(0xFFFFE0B2), child: Text('${i + 1}')),
                      title: Text('${s.className} • ${s.subject}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Đã điểm danh: $presentCount / $total'),
                      trailing: PopupMenuButton<int>(
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 1, child: Text('Xem chi tiết')),
                          const PopupMenuItem(value: 2, child: Text('Xuất CSV')),
                        ],
                        onSelected: (v) {
                          if (v == 1) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportDetailPage(session: s, presentCount: presentCount, total: total)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tải xuống báo cáo (demo).')));
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class ReportDetailPage extends StatelessWidget {
  final Session session;
  final int presentCount;
  final int total;
  const ReportDetailPage({super.key, required this.session, required this.presentCount, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // sample students for detail view
    final students = [
      Student(id: 'S001', name: 'Nguyễn Văn A'),
      Student(id: 'S002', name: 'Trần Thị B'),
      Student(id: 'S003', name: 'Lê Văn C'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo chi tiết'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: ListTile(
                title: Text('${session.className} • ${session.subject}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text('Đã điểm danh: $presentCount / $total'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final st = students[i];
                  final present = i % 2 == 0;
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: const Color(0xFFFFE0B2), child: Text(st.name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join())),
                      title: Text(st.name),
                      subtitle: Text(st.id),
                      trailing: present ? const Chip(label: Text('Có mặt', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green) : const Chip(label: Text('Vắng', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close), label: const Text('Đóng'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xuất CSV (demo)'))), icon: const Icon(Icons.download), label: const Text('Xuất báo cáo'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
