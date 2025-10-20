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
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              AdminStatCard(
                title: 'Tổng người dùng',
                value: '13',
                icon: Icons.groups,
                color: Color(0xFFEFF6FF),
                iconColor: Color(0xFF2563EB),
              ),
              AdminStatCard(
                title: 'Giảng viên',
                value: '5',
                icon: Icons.person_outline,
                color: Color(0xFFFFF1F2),
                iconColor: Color(0xFFE11D48),
              ),
              AdminStatCard(
                title: 'Sinh viên',
                value: '5',
                icon: Icons.school_outlined,
                color: Color(0xFFF5F3FF),
                iconColor: Color(0xFF7C3AED),
              ),
              AdminStatCard(
                title: 'Số lớp',
                value: '10',
                icon: Icons.class_,
                color: Color(0xFFECFDF5),
                iconColor: Color(0xFF10B981),
              ),
            ],
          ),
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
                backgroundColor: iconColor.withOpacity(0.12),
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
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
