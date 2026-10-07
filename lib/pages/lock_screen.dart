import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import '../theme/app_theme.dart';

/// Screen displayed when Chest is locked with biometrics.
/// Shows an interactive pulsating fingerprint sensor graphic and initiates
/// device biometric verification.
class LockScreen extends StatefulWidget {
  final BiometricService biometricService;
  final VoidCallback onUnlocked;

  const LockScreen({
    super.key,
    required this.biometricService,
    required this.onUnlocked,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isAuthenticating = false;
  String _statusMessage = 'Touch the fingerprint sensor to unlock';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-prompt biometrics shortly after screen renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerBiometrics();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _triggerBiometrics() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Scanning fingerprint / face...';
    });

    final success = await widget.biometricService.authenticate(
      reason: 'Verify your identity to unlock Chest',
    );

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
    });

    if (success) {
      widget.onUnlocked();
    } else {
      setState(() {
        _statusMessage =
            'Authentication cancelled or failed. Tap below to retry.';
      });
    }
  }

  Future<void> _promptDisableEmergency() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Unlock Assistance'),
          content: const Text(
            'If your device fingerprint sensor is having trouble, you can temporarily unlock using your device credentials.',
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Retry Unlock'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _triggerBiometrics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Lock Icon & Chest Title
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 32,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chest Locked',
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your credentials are protected with biometric security',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 48),

                // Pulsating Fingerprint Sensor Graphic
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: InkWell(
                    borderRadius: BorderRadius.circular(56),
                    onTap: _triggerBiometrics,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accent.withValues(alpha: 0.6),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fingerprint_rounded,
                          size: 60,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Status message
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),

                // Manual Unlock / Retry Button
                ElevatedButton.icon(
                  onPressed: _triggerBiometrics,
                  icon: const Icon(Icons.fingerprint_rounded, size: 20),
                  label: const Text('Unlock with Biometrics'),
                ),
                const SizedBox(height: 16),

                // Emergency / Alternative Option
                TextButton(
                  onPressed: _promptDisableEmergency,
                  child: const Text('Having trouble with sensor?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
