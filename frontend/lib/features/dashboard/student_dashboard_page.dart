import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, Sinh viên!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Theo dõi tình trạng điểm danh và lịch học của bạn.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              DashboardQuickCard(
                title: 'Buổi hôm nay',
                value: '03',
                icon: Icons.calendar_today,
                color: Color(0xFFEEF2FF),
                iconColor: Color(0xFF4F46E5),
              ),
              DashboardQuickCard(
                title: 'Đã điểm danh',
                value: '27/30',
                icon: Icons.verified_user,
                color: Color(0xFFEFFDEE),
                iconColor: Color(0xFF16A34A),
              ),
              DashboardQuickCard(
                title: 'Vắng có phép',
                value: '02',
                icon: Icons.timer_off,
                color: Color(0xFFFFF7E8),
                iconColor: Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Buổi sắp diễn ra',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Column(
            children: [
              UpcomingSessionTile(
                subject: 'Lập trình Flutter',
                time: '08:00 - 10:00, Thứ 3',
                room: 'Phòng A205',
              ),
              SizedBox(height: 12),
              UpcomingSessionTile(
                subject: 'Trí tuệ nhân tạo',
                time: '13:30 - 15:30, Thứ 3',
                room: 'Phòng B402',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardQuickCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const DashboardQuickCard({
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

class UpcomingSessionTile extends StatelessWidget {
  final String subject;
  final String time;
  final String room;

  const UpcomingSessionTile({
    super.key,
    required this.subject,
    required this.time,
    required this.room,
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
          backgroundColor: Color(0xFFEBF2FF),
          child: Icon(Icons.schedule, color: Color(0xFF3B82F6)),
        ),
        title: Text(
          subject,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text('$time • $room'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
