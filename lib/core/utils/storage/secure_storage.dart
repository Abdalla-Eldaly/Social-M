import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorage {
  final FlutterSecureStorage _storage;

  // Constants for storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresAtKey = 'expires_at';

  SecureStorage(this._storage);

  /// Saves authentication tokens and expiration time to secure storage.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
        _storage.write(key: _expiresAtKey, value: expiresAt.toIso8601String()),
      ]);
    } catch (e) {
      throw SecureStorageException('Failed to save tokens: $e');
    }
  }

  /// Retrieves authentication tokens and expiration time from secure storage.
  /// Returns null if any token or expiration time is missing.
  Future<Map<String, dynamic>?> getTokens() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _accessTokenKey),
        _storage.read(key: _refreshTokenKey),
        _storage.read(key: _expiresAtKey),
      ]);

      final accessToken = results[0];
      final refreshToken = results[1];
      final expiresAtString = results[2];

      if (accessToken != null && refreshToken != null && expiresAtString != null) {
        return {
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'expires_at': DateTime.tryParse(expiresAtString) ?? DateTime.now(),
        };
      }
      return null;
    } catch (e) {
      throw SecureStorageException('Failed to retrieve tokens: $e');
    }
  }

  /// Checks if the access token is still valid based on its expiration time.
  Future<bool> isTokenValid() async {
    try {
      final tokens = await getTokens();
      if (tokens == null) return false;

      final expiresAt = tokens['expires_at'] as DateTime;
      return expiresAt.isAfter(DateTime.now());
    } catch (e) {
      return false; // Assume invalid if an error occurs
    }
  }

  /// Deletes all stored tokens.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException('Failed to delete tokens: $e');
    }
  }
}

/// Custom exception for secure storage errors
class SecureStorageException implements Exception {
  final String message;

  SecureStorageException(this.message);

  @override
  String toString() => message;
}