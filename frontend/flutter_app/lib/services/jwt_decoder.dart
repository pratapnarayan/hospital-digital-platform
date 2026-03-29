/// jwt_decoder.dart
/// Decodes a JWT payload without verifying the signature.
/// Signature verification is done by the backend — the client only reads claims.

import 'dart:convert';

class JwtDecoder {
  /// Returns the decoded payload map from a JWT token string.
  /// Returns null if the token is malformed.
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // JWT uses base64url encoding — pad to make it valid base64
      String payload = parts[1];
      final remainder = payload.length % 4;
      if (remainder != 0) {
        payload = payload.padRight(payload.length + (4 - remainder), '=');
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Extracts the role claim from a JWT token.
  static String? getRole(String token) {
    return decode(token)?['role'] as String?;
  }

  /// Extracts the userId claim from a JWT token.
  static String? getUserId(String token) {
    return decode(token)?['userId'] as String?;
  }

  /// Extracts the hospitalId claim from a JWT token.
  static String? getHospitalId(String token) {
    return decode(token)?['hospitalId'] as String?;
  }

  /// Extracts the patientId claim from a JWT token.
  static String? getPatientId(String token) {
    return decode(token)?['patientId'] as String?;
  }
}
