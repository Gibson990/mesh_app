import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _keyStorageKey = 'mesh_encryption_key';
  static const String _ivStorageKey = 'mesh_encryption_iv';
  
  static encrypt_pkg.Key? _key;
  static encrypt_pkg.IV? _iv;

  // Initialize encryption with secure key generation
  static Future<void> initialize() async {
    try {
      // Try to load existing key
      final storedKey = await _secureStorage.read(key: _keyStorageKey);
      final storedIv = await _secureStorage.read(key: _ivStorageKey);

      if (storedKey != null && storedIv != null) {
        _key = encrypt_pkg.Key.fromBase64(storedKey);
        _iv = encrypt_pkg.IV.fromBase64(storedIv);
        developer.log('🔐 Loaded existing encryption keys');
      } else {
        // Generate new secure keys
        _key = _generateSecureKey();
        _iv = _generateSecureIV();
        
        // Store securely
        await _secureStorage.write(key: _keyStorageKey, value: _key!.base64);
        await _secureStorage.write(key: _ivStorageKey, value: _iv!.base64);
        developer.log('🔐 Generated and stored new encryption keys');
      }
    } catch (e) {
      developer.log('⚠️ Encryption init error: $e, using fallback');
      _key = encrypt_pkg.Key.fromLength(32);
      _iv = encrypt_pkg.IV.fromLength(16);
    }
  }

  // Generate cryptographically secure random key
  static encrypt_pkg.Key _generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return encrypt_pkg.Key(Uint8List.fromList(bytes));
  }

  // Generate cryptographically secure random IV
  static encrypt_pkg.IV _generateSecureIV() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return encrypt_pkg.IV(Uint8List.fromList(bytes));
  }

  // Get keys (ensure initialized)
  static Future<encrypt_pkg.Key> _getKey() async {
    if (_key == null) await initialize();
    return _key!;
  }

  static Future<encrypt_pkg.IV> _getIV() async {
    if (_iv == null) await initialize();
    return _iv!;
  }

  // Encrypt text data
  static Future<String> encryptText(String plainText) async {
    try {
      final key = await _getKey();
      final iv = await _getIV();
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.gcm),
      );
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (e) {
      developer.log('Encryption error: $e');
      return plainText; // Fallback to plain text if encryption fails
    }
  }

  // Decrypt text data
  static Future<String> decryptText(String encryptedText) async {
    try {
      final key = await _getKey();
      final iv = await _getIV();
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.gcm),
      );
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      return decrypted;
    } catch (e) {
      developer.log('Decryption error: $e');
      return encryptedText; // Fallback if decryption fails
    }
  }

  // Encrypt binary data (for images, audio, video)
  static Future<Uint8List> encryptBinary(Uint8List data) async {
    try {
      final key = await _getKey();
      final iv = await _getIV();
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.gcm),
      );
      final encrypted = encrypter.encryptBytes(data, iv: iv);
      return encrypted.bytes;
    } catch (e) {
      developer.log('Binary encryption error: $e');
      return data;
    }
  }

  // Decrypt binary data
  static Future<Uint8List> decryptBinary(Uint8List encryptedData) async {
    try {
      final key = await _getKey();
      final iv = await _getIV();
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.gcm),
      );
      final encrypted = encrypt_pkg.Encrypted(encryptedData);
      final decrypted = encrypter.decryptBytes(encrypted, iv: iv);
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

