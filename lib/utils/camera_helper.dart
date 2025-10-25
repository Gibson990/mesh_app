import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:mesh_app/core/algorithms/compression_service.dart';
import 'package:mesh_app/core/constants/app_constants.dart';

class CameraHelper {
  static final ImagePicker _picker = ImagePicker();

  // Capture photo from camera
  static Future<Uint8List?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;

      final bytes = await File(photo.path).readAsBytes();
      
      // Compress image
      final compressed = CompressionService.compressImage(bytes);
      
      // Check size limit
      if (compressed.length > AppConstants.maxImageSize) {
        developer.log('Image too large after compression');
        return null;
      }

      return compressed;
    } catch (e) {
      developer.log('Capture photo error: $e');
      return null;
    }
  }

  // Pick image from gallery
  static Future<Uint8List?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      final bytes = await File(image.path).readAsBytes();
      
      // Compress image
      final compressed = CompressionService.compressImage(bytes);
      
      // Check size limit
      if (compressed.length > AppConstants.maxImageSize) {
        developer.log('Image too large after compression');
        return null;
      }

      return compressed;
    } catch (e) {
      developer.log('Pick image error: $e');
      return null;
    }
  }

  // Record video
  static Future<File?> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: AppConstants.maxVideoDuration),
      );

      if (video == null) return null;

      return File(video.path);
    } catch (e) {
      developer.log('Record video error: $e');
      return null;
    }
  }

  // Pick video from gallery
  static Future<File?> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(seconds: AppConstants.maxVideoDuration),
      );

      if (video == null) return null;

      return File(video.path);
    } catch (e) {
      developer.log('Pick video error: $e');
      return null;
    }
  }
}

