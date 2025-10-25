class AppConstants {
  // App Info
  static const String appName = 'Mesh';
  static const String appVersion = '1.0.0';
  
  // Bluetooth Configuration
  static const int maxHopCount = 10;
  static const int maxMeshNodes = 100;
  static const int bluetoothChunkSize = 512; // bytes
  static const Duration bluetoothScanDuration = Duration(seconds: 10);
  
  // Message Configuration
  static const int maxMessageLength = 1000; // characters
  static const int maxAudioDuration = 15; // seconds
  static const int maxVideoDuration = 15; // seconds
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // Storage
  static const int maxStoredMessages = 1000;
  static const Duration messageRetentionPeriod = Duration(days: 7);
  
  // Higher-Access Users
  static const int maxHigherAccessUsers = 30;
  static const Map<String, String> higherAccessCredentials = {
    'admin1': 'mesh_secure_2024',
    'admin2': 'mesh_secure_2024',
    'admin3': 'mesh_secure_2024',
    // Add more as needed (up to 30)
  };
  
  // Reputation System
  static const int upvoteValue = 1;
  static const int downvoteValue = -1;
  static const int muteThreshold = -10;
  static const int trustedThreshold = 50;
  
  // Relay Configuration
  static const String telegramBotToken = ''; // Optional: Add if using Telegram relay
  static const String discordWebhook = ''; // Optional: Add if using Discord relay
  
  // UI Configuration
  static const Duration messageAnimationDuration = Duration(milliseconds: 300);
  static const double messageCardElevation = 2.0;
  static const double messageCardRadius = 12.0;
  
  // Notification Configuration
  static const String notificationChannelId = 'mesh_messages';
  static const String notificationChannelName = 'Mesh Messages';
  static const String notificationChannelDescription = 'Notifications for new Mesh messages';
}

