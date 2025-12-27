import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

@lazySingleton
class SecureStorage {
  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresAtKey = 'expires_at';

  SecureStorage(this._storage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    try {
      debugPrint("Saving tokens - expires at: ${expiresAt.toIso8601String()}");

      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
        _storage.write(key: _expiresAtKey, value: expiresAt.toIso8601String()),
      ]);

      debugPrint("Tokens saved successfully");
    } catch (e) {
      debugPrint("Failed to save tokens: $e");
      throw SecureStorageException('Failed to save tokens: $e');
    }
  }

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

      debugPrint("Retrieved tokens - accessToken: ${accessToken != null ? 'present' : 'null'}, refreshToken: ${refreshToken != null ? 'present' : 'null'}");

      if (accessToken != null && refreshToken != null && expiresAtString != null) {
        final expiresAt = DateTime.tryParse(expiresAtString);
        if (expiresAt == null) {
          debugPrint("Invalid expires_at format: $expiresAtString");
          // Clean up invalid data
          await deleteAll();
          return null;
        }

        return {
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'expires_at': expiresAt,
        };
      }

      debugPrint("Incomplete token data found");
      return null;
    } catch (e) {
      debugPrint("Failed to retrieve tokens: $e");
      // Don't throw here, just return null to allow graceful handling
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    try {
      final tokens = await getTokens();
      if (tokens == null) {
        debugPrint("No tokens found - invalid");
        return false;
      }

      final expiresAt = tokens['expires_at'] as DateTime;
      final now = DateTime.now();
      final isValid = expiresAt.isAfter(now.add(const Duration(minutes: 5))); // 5-minute buffer

      debugPrint("Token validation - expires: ${expiresAt.toIso8601String()}, now: ${now.toIso8601String()}, valid: $isValid");

      return isValid;
    } catch (e) {
      debugPrint("Token validation error: $e");
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      debugPrint("Access token: ${token != null ? 'present' : 'null'}");
      return token;
    } catch (e) {
      debugPrint("Failed to get access token: $e");
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      debugPrint("Refresh token: ${token != null ? 'present' : 'null'}");
      return token;
    } catch (e) {
      debugPrint("Failed to get refresh token: $e");
      return null;
    }
  }

  Future<void> deleteAll() async {
    try {
      debugPrint("Deleting all stored tokens");
      await _storage.deleteAll();
      debugPrint("All tokens deleted successfully");
    } catch (e) {
      debugPrint("Failed to delete tokens: $e");
      throw SecureStorageException('Failed to delete tokens: $e');
    }
  }

  Future<void> deleteSpecificKeys() async {
    try {
      debugPrint("Deleting specific token keys");
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _expiresAtKey),
      ]);
      debugPrint("Specific token keys deleted successfully");
    } catch (e) {
      debugPrint("Failed to delete specific keys: $e");
      throw SecureStorageException('Failed to delete specific keys: $e');
    }
  }
}

class SecureStorageException implements Exception {
  final String message;

  SecureStorageException(this.message);

  @override
  String toString() => message;
}