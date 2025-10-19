import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../core/utils/error_message.dart';
import '../../core/utils/toast.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/user.dart';
import 'user_controller.dart';
import 'widgets/user_form_sheet.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() =>
      _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  final TextEditingController searchCtrl = TextEditingController();
  Timer? _debounce;
  UserQuery _query = const UserQuery();

  @override
  void dispose() {
    _debounce?.cancel();
    searchCtrl.dispose();
    super.dispose();
  }

  void _updateQuery({
    String? role,
    bool setRole = false,
    String? keyword,
    bool setKeyword = false,
  }) {
    setState(() {
      _query = _query.copyWith(
        role: role,
        setRole: setRole,
        keyword: keyword,
        setKeyword: setKeyword,
      );
    });
    ref.invalidate(userListProvider(_query));
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _updateQuery(
        keyword: value.trim().isEmpty ? null : value.trim(),
        setKeyword: true,
      );
    });
  }

  Future<void> _openForm({User? initial}) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => UserFormSheet(initial: initial),
    );
    if (!mounted || result == null) return;
    await _refreshUsers();
    if (!mounted) return;
    switch (result) {
      case 'created':
        showSuccessToast(context, 'Đã thêm người dùng');
        break;
      case 'updated':
        showSuccessToast(context, 'Đã cập nhật người dùng');
        break;
    }
  }

  Future<void> _refreshUsers() async {
    try {
      await ref.refresh(userListProvider(_query).future);
    } catch (_) {
      // handled by UI via ErrorView
    }
  }

  Future<void> _confirmDelete(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa người dùng'),
        content: Text('Bạn có chắc muốn xóa ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final notifier = ref.read(userActionControllerProvider.notifier);
    final ok = await notifier.delete(user.id);
    final state = ref.read(userActionControllerProvider);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      await _refreshUsers();
      if (mounted) {
        showSuccessToast(context, 'Đã xóa người dùng');
      }
    } else if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(state.error!))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userListProvider(_query));

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm người dùng'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshUsers,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Text(
                'Quản lý người dùng',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Xem danh sách, lọc theo vai trò và quản lý giảng viên, sinh viên.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 16),
              _FilterRow(
                controller: searchCtrl,
                initialRole: _query.role,
                onRoleChanged: (value) => _updateQuery(
                  role: value?.isEmpty ?? true ? null : value,
                  setRole: true,
                ),
                onSearchChanged: _onSearchChanged,
              ),
              const SizedBox(height: 16),
              usersAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const EmptyView(
                        message: 'Chưa có người dùng nào phù hợp bộ lọc.');
                  }
                  return Column(
                    children: users
                        .map(
                          (user) => _UserTile(
                            user: user,
                            onEdit: () => _openForm(initial: user),
                            onDelete: () => _confirmDelete(user),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const LoadingView(
                    message: 'Đang tải danh sách người dùng...'),
                error: (error, _) => ErrorView(
                  message: extractErrorMessage(error),
                  onRetry: _refreshUsers,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatefulWidget {
  final TextEditingController controller;
  final String? initialRole;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String> onSearchChanged;

  const _FilterRow({
    required this.controller,
    required this.initialRole,
    required this.onRoleChanged,
    required this.onSearchChanged,
  });

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void didUpdateWidget(covariant _FilterRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRole != widget.initialRole) {
      setState(() {
        _role = widget.initialRole;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Tìm theo tên, email...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String?>(
                value: _role,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                borderRadius: BorderRadius.circular(12),
                hint: Text(
                  'Vai trò',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            AppColors.textPrimary.withValues(alpha: 0.6),
                      ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Tất cả'),
                  ),
                  DropdownMenuItem(
                    value: 'lecturer',
                    child: Text('Giảng viên'),
                  ),
                  DropdownMenuItem(
                    value: 'student',
                    child: Text('Sinh viên'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Quản trị'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _role = value);
                  widget.onRoleChanged(value);
                },
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserTile({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  String get roleLabel {
    switch (user.role.toLowerCase()) {
      case 'lecturer':
        return 'Giảng viên';
      case 'admin':
        return 'Quản trị';
      case 'student':
      default:
        return 'Sinh viên';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text('${user.email} • $roleLabel'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: Text('Chỉnh sửa'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Xóa'),
            ),
          ],
        ),
      ),
    );
  }
}
