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
            children: const [
              AdminStatCard(
                title: 'Tổng người dùng',
                value: '1 245',
                icon: Icons.groups,
                color: Color(0xFFEFF6FF),
                iconColor: Color(0xFF2563EB),
              ),
              AdminStatCard(
                title: 'Giảng viên',
                value: '86',
                icon: Icons.person_outline,
                color: Color(0xFFFFF1F2),
                iconColor: Color(0xFFE11D48),
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

  const AdminStatCard({
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
