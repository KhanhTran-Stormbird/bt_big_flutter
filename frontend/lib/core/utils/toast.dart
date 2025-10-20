import 'dart:async';

import 'package:flutter/material.dart';

void showSuccessToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  _showToast(
    context,
    message: message,
    icon: Icons.check_circle,
    gradient: const LinearGradient(
      colors: [Color(0xFF34D399), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    duration: duration,
  );
}

void showWarningToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  _showToast(
    context,
    message: message,
    icon: Icons.error_outline,
    gradient: const LinearGradient(
      colors: [Color(0xFFFACC15), Color(0xFFEAB308)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    duration: duration,
  );
}

void showErrorToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  _showToast(
    context,
    message: message,
    icon: Icons.highlight_off,
    gradient: const LinearGradient(
      colors: [Color(0xFFFB7185), Color(0xFFF43F5E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    duration: duration,
  );
}

void _showToast(
  BuildContext context, {
  required String message,
  required IconData icon,
  required Gradient gradient,
  Duration duration = const Duration(seconds: 2),
}) {
  
  final overlay = Overlay.maybeOf(context, rootOverlay: true)
      ?? Navigator.of(context).overlay;
  if (overlay == null) return;

  final overlayEntry = OverlayEntry(
    builder: (ctx) => _ToastCard(
      message: message,
      icon: icon,
      gradient: gradient,
      top: MediaQuery.of(ctx).padding.top + 16,
      right: 16,
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration, () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

class _ToastCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Gradient gradient;
  final double top;
  final double right;

  const _ToastCard({
    required this.message,
    required this.icon,
    required this.gradient,
    required this.top,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: top,
      right: right,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 200),
        builder: (ctx, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * -20),
            child: child,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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

