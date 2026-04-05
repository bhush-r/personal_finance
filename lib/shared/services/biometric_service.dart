import 'package:local_auth/local_auth.dart';

/// Service for managing biometric and device credential authentication
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  late LocalAuthentication _localAuth;
  bool _isInitialized = false;

  BiometricService._internal();

  factory BiometricService() {
    return _instance;
  }

  /// Initialize the biometric service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _localAuth = LocalAuthentication();
    _isInitialized = true;
  }

  /// Check if device supports biometric authentication
  Future<bool> isSupported() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate using biometric only (fingerprint, face, iris)
  Future<bool> authenticateWithBiometric({
    String reason = 'Unlock Finance Companion',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Authenticate using biometric or device PIN/password
  Future<bool> authenticate({
    String reason = 'Unlock Finance Companion',
  }) async {
    try {
      final supported = await isSupported();
      if (!supported) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Stop authentication (cancel ongoing operation)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Ignore errors
    }
  }
}