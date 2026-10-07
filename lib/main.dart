import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/lock_screen.dart';
import 'services/biometric_service.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = LocalStorageService();
  final biometricService = BiometricService();

  runApp(
    PasswordVaultApp(
      storageService: storageService,
      biometricService: biometricService,
    ),
  );
}

/// Root widget of the application supporting startup lock and biometric authentication.
class PasswordVaultApp extends StatefulWidget {
  final LocalStorageService storageService;
  final BiometricService biometricService;

  const PasswordVaultApp({
    super.key,
    required this.storageService,
    required this.biometricService,
  });

  @override
  State<PasswordVaultApp> createState() => _PasswordVaultAppState();
}

class _PasswordVaultAppState extends State<PasswordVaultApp>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isCheckingLock = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _onAppPaused();
    }
  }

  Future<void> _onAppPaused() async {
    // Re-lock the app when sent to background so entering again asks for fingerprint
    if (!widget.biometricService.isAuthenticating) {
      final enabled = await widget.biometricService.isBiometricsEnabled();
      if (enabled && mounted) {
        setState(() {
          _isLocked = true;
        });
      }
    }
  }

  Future<void> _checkInitialLock() async {
    final enabled = await widget.biometricService.isBiometricsEnabled();
    if (mounted) {
      setState(() {
        _isLocked = enabled;
        _isCheckingLock = false;
      });
    }
  }

  void _onUnlocked() {
    setState(() {
      _isLocked = false;
    });
  }

  void _onLock() {
    setState(() {
      _isLocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _isCheckingLock
          ? const Scaffold(
              backgroundColor: AppTheme.background,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accent,
                  strokeWidth: 2.5,
                ),
              ),
            )
          : _isLocked
          ? LockScreen(
              biometricService: widget.biometricService,
              onUnlocked: _onUnlocked,
            )
          : HomePage(
              storageService: widget.storageService,
              biometricService: widget.biometricService,
              onLock: _onLock,
            ),
    );
  }
}
