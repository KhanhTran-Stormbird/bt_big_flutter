import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../attendance/history_page.dart';
import '../classes/class_list_page.dart';
import '../dashboard/student_dashboard_page.dart';
import '../qr/scan_qr_page.dart';
import '../reports/report_summary_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});
  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int idx = 0;
  final tabs = const [
    StudentDashboardPage(),
    ClassListPage(),
    ScanQrPage(),
    HistoryPage(),
    ReportSummaryPage(),
  ];
  final titles = const ['Trang chủ', 'Lớp', 'Điểm danh', 'Lịch sử', 'Báo cáo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titles[idx])),
      backgroundColor: AppColors.surface,
      body: IndexedStack(index: idx, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Lớp'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'Điểm danh'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Báo cáo'),
        ],
      ),
    );
  }
}
