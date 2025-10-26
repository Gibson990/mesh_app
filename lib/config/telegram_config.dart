/// Telegram Configuration for MO29 Channel
/// 
/// This file contains the Telegram bot credentials for auto-uploading media
/// to the MO29 channel. All media (images, videos, audio) sent in the app
/// will be automatically uploaded to this channel in the background.

class TelegramConfig {
  // Bot credentials
  static const String botToken = '8082508094:AAFSaDspK0tczmwA0OocRGfk2MSe3RxBCfg';
  static const String channelId = '-1003219185632';
  static const String channelName = 'MO29';
  static const String botUsername = 'theMO29_bot';
  
  // API endpoints
  static const String baseUrl = 'https://api.telegram.org/bot$botToken';
  
  // Upload settings
  static const bool autoUploadEnabled = true;
  static const bool compressBeforeUpload = true;
  static const int maxRetries = 5;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Caption formatting
  static bool includeTimestamp = true;
  static bool includeSenderName = true;
  static bool includeHashtags = true;
  static bool includeLocation = false; // Set to true if you want location in captions
  
  /// Get formatted caption for media
  static String formatCaption({
    required String senderName,
    required DateTime timestamp,
    String? caption,
    String? location,
    required String mediaType,
  }) {
    final buffer = StringBuffer();
    
    if (includeSenderName) {
      buffer.writeln('📱 From: $senderName');
    }
    
    if (includeTimestamp) {
      buffer.writeln('📅 ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}');
    }
    
    if (includeLocation && location != null && location.isNotEmpty) {
      buffer.writeln('📍 $location');
    }
    
    if (caption != null && caption.isNotEmpty) {
      buffer.writeln('💬 $caption');
    }
    
    buffer.writeln();
    
    if (includeHashtags) {
      buffer.write('#MeshApp #$mediaType');
    }
    
    return buffer.toString().trim();
  }
}
