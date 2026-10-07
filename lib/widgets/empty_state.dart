import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable empty state widget displayed when the vault has no credentials.
class EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const EmptyState({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border, width: 1.5),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 36,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No credentials yet',
              style: TextStyle(
                color: AppTheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Store your first app or website credential to keep them organized and accessible.',
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Credential'),
            ),
          ],
        ),
      ),
    );
  }
}
