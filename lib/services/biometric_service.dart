import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing device biometric hardware detection, authentication,
/// and user preferences for vault locking.
class BiometricService {
  static const String _keyBiometricsEnabled = 'chest_biometrics_enabled_v1';
  static const String _keyPromptedSetup = 'chest_biometrics_prompted_v1';

  final LocalAuthentication _localAuth;
  final SharedPreferences? _prefsInstance;

  BiometricService({LocalAuthentication? localAuth, SharedPreferences? prefs})
    : _localAuth = localAuth ?? LocalAuthentication(),
      _prefsInstance = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  /// Checks if the device has biometric hardware (fingerprint/face) available.
  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Checks if any biometrics (e.g. fingerprint, face) are currently enrolled.
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  bool _isAuthenticating = false;

  /// Returns whether a biometric authentication challenge is currently active.
  bool get isAuthenticating => _isAuthenticating;

  /// Prompts the device's native biometric scanner (fingerprint / face ID)
  /// with device PIN/pattern fallback.
  Future<bool> authenticate({
    String reason = 'Scan your fingerprint or face to unlock Chest',
  }) async {
    try {
      _isAuthenticating = true;
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      _isAuthenticating = false;
      return result;
    } on PlatformException {
      _isAuthenticating = false;
      return false;
    } catch (_) {
      _isAuthenticating = false;
      return false;
    }
  }

  /// Returns whether the user has enabled biometric lock in Chest.
  Future<bool> isBiometricsEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyBiometricsEnabled) ?? false;
  }

  /// Enables or disables biometric lock for Chest.
  Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyBiometricsEnabled, enabled);
  }

  /// Returns whether the startup setup prompt was already presented.
  Future<bool> hasPromptedSetup() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyPromptedSetup) ?? false;
  }

  /// Marks that the startup setup prompt was presented.
  Future<void> setPromptedSetup(bool prompted) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyPromptedSetup, prompted);
  }
}
