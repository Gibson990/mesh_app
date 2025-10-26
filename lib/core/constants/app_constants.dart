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
  // TODO: Add your Telegram Bot Token here
  // How to get: Talk to @BotFather on Telegram, create a bot, and copy the token
  // Example: '1234567890:ABCdefGHIjklMNOpqrsTUVwxyz'
  static const String telegramBotToken = '';

  // TODO: Add your Telegram Channel ID here
  // How to get: Create a channel, add your bot as admin, forward a message from channel
  // to @userinfobot to get the channel ID (starts with -100)
  // Example: '-1001234567890'
  static const String telegramChannelId = '';

  // TODO: Add your Discord Webhook URL here
  // How to get: Server Settings > Integrations > Webhooks > New Webhook
  // Copy the webhook URL
  // Example: 'https://discord.com/api/webhooks/1234567890/abcdefghijklmnop'
  static const String discordWebhook = '';

  // UI Configuration
  static const Duration messageAnimationDuration = Duration(milliseconds: 300);
  static const double messageCardElevation = 2.0;
  static const double messageCardRadius = 12.0;

  // Notification Configuration
  static const String notificationChannelId = 'mesh_messages';
  static const String notificationChannelName = 'Mesh Messages';
  static const String notificationChannelDescription =
      'Notifications for new Mesh messages';
}
