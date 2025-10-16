import 'package:flutter/material.dart';

import 'core/theme/colors.dart';
import 'router.dart';

class TluApp extends StatelessWidget {
  const TluApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
      brightness: Brightness.light,
    );

    return MaterialApp.router(
      title: 'TLU Attendance',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
