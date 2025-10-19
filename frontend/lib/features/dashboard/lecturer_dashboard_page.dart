import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class LecturerDashboardPage extends StatelessWidget {
  const LecturerDashboardPage({super.key});

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
            children: const [
              QuickActionChip(label: 'Tạo buổi mới', icon: Icons.add_circle),
              QuickActionChip(
                  label: 'Xuất QR điểm danh', icon: Icons.qr_code_2),
              QuickActionChip(label: 'Cập nhật sĩ số', icon: Icons.group_add),
              QuickActionChip(label: 'Xuất báo cáo', icon: Icons.upload_file),
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

  const QuickActionChip({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.surface,
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
