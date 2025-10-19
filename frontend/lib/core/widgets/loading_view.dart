import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const SizedBox(
        height: 48,
        width: 48,
        child: CircularProgressIndicator(),
      ),
    ];
    if (message != null && message!.isNotEmpty) {
      children.addAll([
        const SizedBox(height: 12),
        Text(
          message!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ]);
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
