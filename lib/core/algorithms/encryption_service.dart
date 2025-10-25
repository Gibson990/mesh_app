import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:crypto/crypto.dart';

class EncryptionService {
  // AES-256-GCM encryption key (32 bytes)
  // In production, this should be generated and shared securely
  static final _key = encrypt_pkg.Key.fromLength(32);
  static final _iv = encrypt_pkg.IV.fromLength(16);

  // Encrypt text data
  static String encryptText(String plainText) {
    try {
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_key, mode: encrypt_pkg.AESMode.gcm),
      );
      final encrypted = encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      developer.log('Encryption error: $e');
      return plainText; // Fallback to plain text if encryption fails
    }
  }

  // Decrypt text data
  static String decryptText(String encryptedText) {
    try {
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_key, mode: encrypt_pkg.AESMode.gcm),
      );
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      developer.log('Decryption error: $e');
      return encryptedText; // Fallback if decryption fails
    }
  }

  // Encrypt binary data (for images, audio, video)
  static Uint8List encryptBinary(Uint8List data) {
    try {
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_key, mode: encrypt_pkg.AESMode.gcm),
      );
      final encrypted = encrypter.encryptBytes(data, iv: _iv);
      return encrypted.bytes;
    } catch (e) {
      developer.log('Binary encryption error: $e');
      return data;
    }
  }

  // Decrypt binary data
  static Uint8List decryptBinary(Uint8List encryptedData) {
    try {
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_key, mode: encrypt_pkg.AESMode.gcm),
      );
      final encrypted = encrypt_pkg.Encrypted(encryptedData);
      final decrypted = encrypter.decryptBytes(encrypted, iv: _iv);
      return Uint8List.fromList(decrypted);
    } catch (e) {
      developer.log('Binary decryption error: $e');
      return encryptedData;
    }
  }

  // Generate SHA-256 hash for content
  static String generateHash(String content) {
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate hash for binary data
  static String generateBinaryHash(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }

  // Generate a rotating user ID based on timestamp
  static String generateRotatingUserId(String baseId) {
    final now = DateTime.now();
    // Rotate every hour
    final hourKey = '${now.year}${now.month}${now.day}${now.hour}';
    final combined = '$baseId$hourKey';
    return generateHash(combined).substring(0, 16);
  }
}

