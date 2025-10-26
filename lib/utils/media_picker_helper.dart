import 'dart:developer' as developer;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:mesh_app/core/algorithms/compression_service.dart';
import 'dart:typed_data';

class MediaPickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();
  static FlutterSoundRecorder? _audioRecorder;
  static String? _audioPath;

  // Pick image from camera
  static Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        return await _compressImage(File(photo.path));
      }
      return null;
    } catch (e) {
      developer.log('Error taking photo: $e');
      return null;
    }
  }

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        return await _compressImage(File(image.path));
      }
      return null;
    } catch (e) {
      developer.log('Error picking image: $e');
      return null;
    }
  }

  // Compress image to max 1MB
  static Future<File> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileSize = bytes.length;

      // If already under 1MB, return as is
      if (fileSize <= 1024 * 1024) {
        return imageFile;
      }

      // Compress image
      int quality = 75;
      Uint8List compressed =
          CompressionService.compressImage(bytes, quality: quality);

      // Keep reducing quality until under 1MB
      while (compressed.length > 1024 * 1024 && quality > 10) {
        quality -= 10;
        compressed = CompressionService.compressImage(bytes, quality: quality);
      }

      // Write compressed image to new file
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressed);

      developer.log(
          'Image compressed from ${fileSize / 1024}KB to ${compressed.length / 1024}KB');
      return compressedFile;
    } catch (e) {
      developer.log('Error compressing image: $e');
      return imageFile;
    }
  }

  // Record video
  static Future<File?> recordVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 15),
      );

      if (video != null) {
        return await _compressVideo(File(video.path));
      }
      return null;
    } catch (e) {
      developer.log('Error recording video: $e');
      return null;
    }
  }

  // Pick video from gallery
  static Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 15),
      );

      if (video != null) {
        return await _compressVideo(File(video.path));
      }
      return null;
    } catch (e) {
      developer.log('Error picking video: $e');
      return null;
    }
  }

  // Compress video to max 5MB
  static Future<File?> _compressVideo(File videoFile) async {
    try {
      final fileSize = await videoFile.length();

      // If already under 5MB, return as is
      if (fileSize <= 5 * 1024 * 1024) {
        return videoFile;
      }

      developer.log('Compressing video from ${fileSize / (1024 * 1024)}MB...');

      final info = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (info != null && info.file != null) {
        final compressedSize = await info.file!.length();
        developer
            .log('Video compressed to ${compressedSize / (1024 * 1024)}MB');
        return info.file;
      }

      return videoFile;
    } catch (e) {
      developer.log('Error compressing video: $e');
      return videoFile;
    }
  }

  // Start audio recording
  static Future<bool> startAudioRecording() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        developer.log('Microphone permission denied');
        return false;
      }

      _audioRecorder ??= FlutterSoundRecorder();
      await _audioRecorder!.openRecorder();

      final dir = await getTemporaryDirectory();
      _audioPath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder!.startRecorder(
        toFile: _audioPath,
        codec: Codec.aacADTS,
      );

      developer.log('Audio recording started');
      return true;
    } catch (e) {
      developer.log('Error starting audio recording: $e');
      return false;
    }
  }

  // Stop audio recording
  static Future<File?> stopAudioRecording() async {
    try {
      if (_audioRecorder == null) return null;

      await _audioRecorder!.stopRecorder();
      await _audioRecorder!.closeRecorder();

      if (_audioPath != null) {
        final audioFile = File(_audioPath!);
        final fileSize = await audioFile.length();

        // Check if under 500KB
        if (fileSize <= 500 * 1024) {
          developer.log('Audio recorded: ${fileSize / 1024}KB');
          return audioFile;
        } else {
          developer.log('Audio file too large: ${fileSize / 1024}KB');
          // For now, return as is. Could implement audio compression if needed
          return audioFile;
        }
      }

      return null;
    } catch (e) {
      developer.log('Error stopping audio recording: $e');
      return null;
    }
  }

  // Cancel audio recording
  static Future<void> cancelAudioRecording() async {
    try {
      if (_audioRecorder != null) {
        await _audioRecorder!.stopRecorder();
        await _audioRecorder!.closeRecorder();
        _audioRecorder = null;
      }

      if (_audioPath != null) {
        final file = File(_audioPath!);
        if (await file.exists()) {
          await file.delete();
        }
        _audioPath = null;
      }
    } catch (e) {
      developer.log('Error canceling audio recording: $e');
    }
  }

  // Get recording duration
  static Stream<Duration>? getRecordingStream() {
    return _audioRecorder?.onProgress
        ?.map((disposition) => disposition.duration);
  }

  // Check if recording
  static bool get isRecording => _audioRecorder?.isRecording ?? false;

  // Dispose resources
  static Future<void> dispose() async {
    try {
      if (_audioRecorder != null) {
        await _audioRecorder!.closeRecorder();
        _audioRecorder = null;
      }
    } catch (e) {
      developer.log('Error disposing media picker: $e');
    }
  }
}
