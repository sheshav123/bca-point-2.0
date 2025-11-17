import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

class SecurePdfCache {
  static final SecurePdfCache _instance = SecurePdfCache._internal();
  factory SecurePdfCache() => _instance;
  SecurePdfCache._internal();

  final Dio _dio = Dio();
  late final encrypt.Key _encryptionKey;
  late final encrypt.IV _iv;
  late final encrypt.Encrypter _encrypter;

  // Initialize encryption with device-specific key
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get or create device-specific encryption key
    String? keyString = prefs.getString('encryption_key');
    if (keyString == null) {
      // Generate a random key unique to this device
      final key = encrypt.Key.fromSecureRandom(32);
      keyString = key.base64;
      await prefs.setString('encryption_key', keyString);
    }
    
    _encryptionKey = encrypt.Key.fromBase64(keyString);
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
  }

  // Get the secure cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/.secure_pdfs');
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    return cacheDir;
  }

  // Generate a secure filename from URL
  String _getSecureFileName(String url) {
    final hash = url.hashCode.abs().toString();
    return '$hash.encrypted';
  }

  // Check if PDF is cached
  Future<bool> isCached(String url) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final fileName = _getSecureFileName(url);
      final file = File('${cacheDir.path}/$fileName');
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking cache: $e');
      return false;
    }
  }

  // Download and cache PDF with encryption
  Future<File?> downloadAndCache(
    String url,
    String materialId, {
    Function(double)? onProgress,
  }) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final fileName = _getSecureFileName(url);
      final encryptedFile = File('${cacheDir.path}/$fileName');

      // If already cached, return it
      if (await encryptedFile.exists()) {
        debugPrint('PDF already cached: $materialId');
        return encryptedFile;
      }

      debugPrint('Downloading PDF: $materialId');

      // Download the PDF
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      // Encrypt the PDF data
      final pdfBytes = Uint8List.fromList(response.data);
      final encryptedData = _encryptBytes(pdfBytes);

      // Save encrypted file
      await encryptedFile.writeAsBytes(encryptedData);

      // Save metadata
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pdf_$materialId', url);
      await prefs.setInt('pdf_size_$materialId', pdfBytes.length);
      await prefs.setString('pdf_cached_$materialId', DateTime.now().toIso8601String());

      debugPrint('PDF cached successfully: $materialId');
      return encryptedFile;
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      return null;
    }
  }

  // Get cached PDF and decrypt it
  Future<Uint8List?> getCachedPdf(String url) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final fileName = _getSecureFileName(url);
      final encryptedFile = File('${cacheDir.path}/$fileName');

      if (!await encryptedFile.exists()) {
        return null;
      }

      // Read encrypted data
      final encryptedData = await encryptedFile.readAsBytes();

      // Decrypt the data
      final decryptedData = _decryptBytes(encryptedData);

      return decryptedData;
    } catch (e) {
      debugPrint('Error reading cached PDF: $e');
      return null;
    }
  }

  // Encrypt bytes
  Uint8List _encryptBytes(Uint8List data) {
    // For large files, encrypt in chunks
    const chunkSize = 1024 * 1024; // 1MB chunks
    final encryptedChunks = <int>[];

    for (var i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      final chunk = data.sublist(i, end);
      final encrypted = _encrypter.encryptBytes(chunk, iv: _iv);
      encryptedChunks.addAll(encrypted.bytes);
    }

    return Uint8List.fromList(encryptedChunks);
  }

  // Decrypt bytes
  Uint8List _decryptBytes(Uint8List encryptedData) {
    // Decrypt in chunks
    const chunkSize = 1024 * 1024 + 16; // Encrypted chunk size (includes padding)
    final decryptedChunks = <int>[];

    for (var i = 0; i < encryptedData.length; i += chunkSize) {
      final end = (i + chunkSize < encryptedData.length) ? i + chunkSize : encryptedData.length;
      final chunk = encryptedData.sublist(i, end);
      try {
        final decrypted = _encrypter.decryptBytes(encrypt.Encrypted(chunk), iv: _iv);
        decryptedChunks.addAll(decrypted);
      } catch (e) {
        debugPrint('Error decrypting chunk: $e');
      }
    }

    return Uint8List.fromList(decryptedChunks);
  }

  // Get cache size
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      int totalSize = 0;

      await for (var entity in cacheDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0;
    }
  }

  // Clear specific PDF from cache
  Future<void> clearPdf(String url) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final fileName = _getSecureFileName(url);
      final file = File('${cacheDir.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error clearing PDF: $e');
    }
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      // Clear metadata
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('pdf_'));
      for (var key in keys) {
        await prefs.remove(key);
      }

      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  // Get cached PDFs list
  Future<List<String>> getCachedPdfsList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('pdf_cached_'));
      
      return keys.map((key) {
        final materialId = key.replaceFirst('pdf_cached_', '');
        return materialId;
      }).toList();
    } catch (e) {
      debugPrint('Error getting cached PDFs list: $e');
      return [];
    }
  }
}
