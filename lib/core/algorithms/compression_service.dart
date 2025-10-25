import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;

class CompressionService {
  // Compress text using GZip (similar to Zstandard in efficiency)
  static Uint8List compressText(String text) {
    try {
      final bytes = utf8.encode(text);
      final compressed = GZipEncoder().encode(bytes);
      return Uint8List.fromList(compressed!);
    } catch (e) {
      developer.log('Text compression error: $e');
      return Uint8List.fromList(utf8.encode(text));
    }
  }

  // Decompress text
  static String decompressText(Uint8List compressedData) {
    try {
      final decompressed = GZipDecoder().decodeBytes(compressedData);
      return utf8.decode(decompressed);
    } catch (e) {
      developer.log('Text decompression error: $e');
      return utf8.decode(compressedData);
    }
  }

  // Compress image to WebP-like format (using JPEG with quality optimization)
  static Uint8List compressImage(Uint8List imageData, {int quality = 75}) {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) return imageData;

      // Resize if too large (max 1024px on longest side)
      img.Image resized = image;
      if (image.width > 1024 || image.height > 1024) {
        final ratio = 1024 / (image.width > image.height ? image.width : image.height);
        resized = img.copyResize(
          image,
          width: (image.width * ratio).round(),
          height: (image.height * ratio).round(),
        );
      }

      // Encode as JPEG with quality setting
      final compressed = img.encodeJpg(resized, quality: quality);
      return Uint8List.fromList(compressed);
    } catch (e) {
      developer.log('Image compression error: $e');
      return imageData;
    }
  }

  // Compress data for Bluetooth transmission (chunk into small packets)
  static List<Uint8List> chunkData(Uint8List data, {int chunkSize = 512}) {
    final chunks = <Uint8List>[];
    for (int i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      chunks.add(data.sublist(i, end));
    }
    return chunks;
  }

  // Reassemble chunks
  static Uint8List reassembleChunks(List<Uint8List> chunks) {
    final totalLength = chunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
    final result = Uint8List(totalLength);
    int offset = 0;
    for (final chunk in chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return result;
  }

  // Calculate compression ratio
  static double getCompressionRatio(int originalSize, int compressedSize) {
    if (originalSize == 0) return 0;
    return ((originalSize - compressedSize) / originalSize) * 100;
  }

  // Compress JSON data
  static Uint8List compressJson(Map<String, dynamic> json) {
    final jsonString = jsonEncode(json);
    return compressText(jsonString);
  }

  // Decompress JSON data
  static Map<String, dynamic> decompressJson(Uint8List compressedData) {
    final jsonString = decompressText(compressedData);
    return jsonDecode(jsonString);
  }
}

