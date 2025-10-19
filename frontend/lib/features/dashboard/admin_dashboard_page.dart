import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bảng điều khiển Admin',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quản lý người dùng, cấu hình hệ thống và theo dõi báo cáo.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              AdminStatCard(
                title: 'Tổng người dùng',
                value: '1 245',
                icon: Icons.groups,
                color: Color(0xFFEFF6FF),
                iconColor: Color(0xFF2563EB),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UserManagementPage()),
                  );
                },
              ),
              AdminStatCard(
                title: 'Giảng viên',
                value: '86',
                icon: Icons.person_outline,
                color: Color(0xFFFFF1F2),
                iconColor: Color(0xFFE11D48),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LecturerListPage()),
                  );
                },
              ),
              AdminStatCard(
                title: 'Thông báo mới',
                value: '04',
                icon: Icons.notifications_active_outlined,
                color: Color(0xFFECFDF5),
                iconColor: Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Hoạt động gần đây',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const ActivityTimeline(),
        ],
      ),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
      ),
    );
  }
}

class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActivityItem(
          'Cập nhật ngưỡng nhận diện khuôn mặt', 'Admin', '10 phút trước'),
      _ActivityItem(
          'Thêm giảng viên mới: Nguyễn Văn A', 'System', '2 giờ trước'),
      _ActivityItem('Export báo cáo chuyên cần lớp KP336', 'Giảng viên Trần B',
          'Hôm qua'),
    ];
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final item in items) ...[
          Container(
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
                backgroundColor: Color(0xFFE0F2FE),
                child: Icon(Icons.settings, color: Color(0xFF0284C7)),
              ),
              title: Text(
                item.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text('${item.actor} • ${item.time}'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ActivityItem {
  final String title;
  final String actor;
  final String time;

  _ActivityItem(this.title, this.actor, this.time);
}

// thêm phần quản lý người dùng dưới đây
class User {
  String name;
  String role;
  User({required this.name, required this.role});
}

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final List<User> _users = [
    User(name: 'Nguyễn Văn A', role: 'Sinh viên'),
    User(name: 'Trần B', role: 'Giảng viên'),
    User(name: 'Lê C', role: 'Giảng viên'),
  ];

  void _showEditDialog({User? user, int? index}) {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    String selectedRole = user?.role ?? 'Sinh viên';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(user == null ? 'Thêm người dùng' : 'Sửa người dùng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ tên'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Chức vụ'),
                items: const [
                  DropdownMenuItem(value: 'Sinh viên', child: Text('Sinh viên')),
                  DropdownMenuItem(value: 'Giảng viên', child: Text('Giảng viên')),
                ],
                onChanged: (v) => setStateDialog(() {
                  selectedRole = v ?? 'Sinh viên';
                }),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
            ElevatedButton(
              onPressed: () {
                final newName = nameCtrl.text.trim();
                final newRole = selectedRole;
                if (newName.isEmpty) return;
                setState(() {
                  if (user == null) {
                    _users.add(User(name: newName, role: newRole));
                  } else if (index != null) {
                    _users[index] = User(name: newName, role: newRole);
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá người dùng'),
        content: Text('Bạn có chắc muốn xoá "${_users[index].name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              setState(() => _users.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(user: null, index: null),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Họ tên')),
              DataColumn(label: Text('Chức vụ')),
              DataColumn(label: Text('Hành động')),
            ],
            rows: List.generate(_users.length, (i) {
              final u = _users[i];
              return DataRow(cells: [
                DataCell(Text(u.name)),
                DataCell(Text(u.role)),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(user: u, index: i),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(i),
                    ),
                  ],
                )),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}

class Lecturer {
  final String name;
  final String email;
  final String department;
  final DateTime createdAt;
  final String phone;
  final String office;
  final String bio;

  const Lecturer({
    required this.name,
    required this.email,
    required this.department,
    required this.createdAt,
    this.phone = '',
    this.office = '',
    this.bio = '',
  });
}

enum SortOption { nameAsc, newestFirst, oldestFirst }

class LecturerListPage extends StatefulWidget {
  LecturerListPage({super.key});

  @override
  State<LecturerListPage> createState() => _LecturerListPageState();
}

class _LecturerListPageState extends State<LecturerListPage> {
  final TextEditingController _searchCtrl = TextEditingController();

   final List<Lecturer> _allLecturers = [
    Lecturer(
      name: 'Trần B',
      email: 'tran.b@uni.edu',
      department: 'Công nghệ thông tin',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      phone: '0123 456 789',
      office: 'P. A101',
      bio: 'Giảng viên chuyên môn về lập trình và hệ thống thông tin.',
    ),
    Lecturer(
      name: 'Lê C',
      email: 'le.c@uni.edu',
      department: 'Khoa học máy tính',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      phone: '0987 654 321',
      office: 'P. B202',
      bio: 'Quan tâm tới thuật toán và trí tuệ nhân tạo.',
    ),
    Lecturer(
      name: 'Nguyễn D',
      email: 'nguyen.d@uni.edu',
      department: 'Toán ứng dụng',
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
      phone: '0911 223 344',
      office: 'P. C303',
      bio: 'Giảng dạy môn toán rời rạc và xác suất thống kê.',
    ),
    Lecturer(
      name: 'Phạm E',
      email: 'pham.e@uni.edu',
      department: 'Hệ thống thông tin',
      createdAt: DateTime.now().subtract(Duration(days: 10)),
      phone: '0909 090 909',
      office: 'P. D404',
      bio: 'Nghiên cứu về an toàn thông tin và mạng máy tính.',
    ),
  ];

  String _query = '';
  SortOption _sort = SortOption.nameAsc;

  // normalize helper (remove basic diacritics) for correct A→Z sorting in VN names
  String _norm(String s) {
    const src = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćČčĐđÈÉÊËèéêëĒēĘęÌÍÎÏìíîïĨĩĪīÑñŃńÔÕÖÒÓôõöòóŌōØøÙÚÛÜùúûüŪūÝýÿŽž';
    const dst = 'AAAAAAaaaaaaAaAaAaCcCcCcDdEEEEeeeeEeEeIIIIiiiiIiNnNnOOOOOOooooooU UUuYyyZz';
    var out = s;
    for (var i = 0; i < src.length && i < dst.length; i++) {
      out = out.replaceAll(src[i], dst[i]);
    }
    return out;
  }

  List<Lecturer> get _filteredAndSorted {
    final q = _norm(_query.trim().toLowerCase());
    var list = _allLecturers.where((l) {
      final combined = '${l.name} ${l.email} ${l.department}'.toLowerCase();
      return _norm(combined).contains(q);
    }).toList();

    switch (_sort) {
      case SortOption.nameAsc:
        list.sort((a, b) => _norm(a.name.toLowerCase()).compareTo(_norm(b.name.toLowerCase())));
        break;
      case SortOption.newestFirst:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldestFirst:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    return list;
  }

  void _onSearchChanged(String v) => setState(() => _query = v);
  void _onSortChanged(SortOption? v) { if (v != null) setState(() => _sort = v); }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _avatarColor(String name) {
    final hash = name.codeUnits.fold<int>(0, (p, c) => p + c);
    final colors = [
      Colors.orange,
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredAndSorted;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Danh sách giảng viên'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: Column(
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary.withOpacity(0.12), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              children: [
                // Title row with count badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Giảng viên', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Quản lý, tìm kiếm và xem chi tiết giảng viên', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0,4))],
                      ),
                      child: Text('${list.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search field (separate)
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm theo tên, email, khoa...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _onSearchChanged(''); })
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort button as segmented choices
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: DropdownButton<SortOption>(
                          value: _sort,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: SortOption.nameAsc, child: Text('A → Z')),
                            DropdownMenuItem(value: SortOption.newestFirst, child: Text('Mới → Cũ')),
                            DropdownMenuItem(value: SortOption.oldestFirst, child: Text('Cũ → Mới')),
                          ],
                          onChanged: _onSortChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('Không tìm thấy giảng viên', style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 6),
                          Text('Thử từ khoá khác hoặc đặt lại bộ lọc', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final lec = list[idx];
                        final stt = idx + 1;
                        final avatarBg = _avatarColor(lec.name);
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => LecturerDetailPage(lecturer: lec)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [avatarBg.withOpacity(0.06), Colors.white]),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,4))],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              leading: Hero(
                                tag: 'lec_avatar_${lec.email}',
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: avatarBg,
                                  child: Text(
                                    lec.name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(child: Text('$stt. ${lec.name}', style: const TextStyle(fontWeight: FontWeight.w700))),
                                  const SizedBox(width: 8),
                                  Text(_formatDate(lec.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(lec.department, style: const TextStyle(fontSize: 12, color: Colors.green)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(lec.email, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                                    builder: (_) => Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.info),
                                            title: const Text('Xem chi tiết'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(context, MaterialPageRoute(builder: (_) => LecturerDetailPage(lecturer: lec)));
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.email),
                                            title: const Text('Gửi email'),
                                            onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng gửi email tạm thời chưa có.'))); },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.call),
                                            title: const Text('Gọi'),
                                            onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng gọi tạm thời chưa có.'))); },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class LecturerDetailPage extends StatelessWidget {
  final Lecturer lecturer;
  const LecturerDetailPage({super.key, required this.lecturer});

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final avatarBg = Colors.primaries[lecturer.name.codeUnitAt(0) % Colors.primaries.length];
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giảng viên'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // card header with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [avatarBg.withOpacity(0.18), Colors.white]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0,6))],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Hero(
                    tag: 'lec_avatar_${lecturer.email}',
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: avatarBg,
                      child: Text(
                        lecturer.name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join(),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lecturer.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(lecturer.department, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.green[800])),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.email, size: 16, color: Colors.grey[700]),
                            const SizedBox(width: 6),
                            Expanded(child: Text(lecturer.email, style: theme.textTheme.bodyMedium)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Chip(label: Text('Văn phòng: ${lecturer.office.isNotEmpty ? lecturer.office : "Chưa có"}')),
                            Chip(label: Text('SĐT: ${lecturer.phone.isNotEmpty ? lecturer.phone : "Chưa có"}')),
                            Chip(label: Text('Ngày tạo: ${_formatDate(lecturer.createdAt)}')),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Biography / info card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tiểu sử', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(lecturer.bio.isNotEmpty ? lecturer.bio : 'Chưa có thông tin.'),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('Hành động', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gửi email (demo)'))); }, icon: const Icon(Icons.email), label: const Text('Email')),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gọi (demo)'))); }, icon: const Icon(Icons.call), label: const Text('Gọi')),
                        const Spacer(),
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Additional stats or notes
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Môn phụ trách', style: theme.textTheme.bodySmall), const SizedBox(height:6), Text('Lập trình hướng đối tượng', style: theme.textTheme.bodyMedium)])),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Công trình', style: theme.textTheme.bodySmall), const SizedBox(height:6), Text('Nghiên cứu AI', style: theme.textTheme.bodyMedium)])),
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