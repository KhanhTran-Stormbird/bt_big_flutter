import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic>? result;
  const ResultPage({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    final status = result?['status'] ?? 'Unknown';
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(status == 'Present' ? Icons.check_circle : Icons.error,
              size: 72, color: status == 'Present' ? Colors.green : Colors.red),
          const SizedBox(height: 12),
          Text('Kết quả: $status'),
        ]),
      ),
    );
  }
}
