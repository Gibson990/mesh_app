import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mesh_app/core/models/message.dart';
import 'package:mesh_app/services/connectivity/connectivity_service.dart';
import 'package:mesh_app/services/storage/storage_service.dart';
import 'package:mesh_app/config/telegram_config.dart';

/// Service for auto-uploading MEDIA to Discord and Telegram
/// ONLY uploads images, videos, and audio files
class ExternalPlatformsService {
  static final ExternalPlatformsService _instance = ExternalPlatformsService._internal();
  factory ExternalPlatformsService() => _instance;
  ExternalPlatformsService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ConnectivityService _connectivityService = ConnectivityService();
  final StorageService _storageService = StorageService();
  
  final List<Message> _uploadQueue = [];
  final Set<String> _uploadedMessageIds = {}; // Track uploaded messages to prevent duplicates
  bool _isUploading = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Secure storage keys
  static const String _telegramTokenKey = 'telegram_bot_token';
  static const String _telegramChatIdKey = 'telegram_chat_id';
  static const String _discordWebhookKey = 'discord_webhook_url';
  
  String? _telegramBotToken;
  String? _telegramChatId;
  String? _discordWebhookUrl;
  
  bool _isInitialized = false;

  /// Initialize and load credentials from secure storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load from secure storage first (user-configured)
      _telegramBotToken = await _secureStorage.read(key: _telegramTokenKey);
      _telegramChatId = await _secureStorage.read(key: _telegramChatIdKey);
      _discordWebhookUrl = await _secureStorage.read(key: _discordWebhookKey);
      
      // If not configured, use hardcoded MO29 channel credentials
      if (_telegramBotToken == null || _telegramChatId == null) {
        _telegramBotToken = TelegramConfig.botToken;
        _telegramChatId = TelegramConfig.channelId;
        developer.log('📱 [ExternalPlatforms] Using MO29 channel credentials');
      }
      
      developer.log('🔐 [ExternalPlatforms] Credentials loaded');
      developer.log('📱 Telegram configured: ${_telegramBotToken != null && _telegramChatId != null}');
      developer.log('📱 Channel: ${TelegramConfig.channelName} (${TelegramConfig.channelId})');
      developer.log('💬 Discord configured: ${_discordWebhookUrl != null}');
      
      _isInitialized = true;
      
      // Load uploaded message IDs from storage (to prevent duplicates after app restart)
      await _loadUploadedMessageIds();
      
      // Start processing queue if online
      if (_connectivityService.isOnline) {
        developer.log('🌐 [ExternalPlatforms] Online - processing queue immediately');
        _processQueue();
      }
      
      // Listen to connectivity changes in real-time (background monitoring)
      _connectivitySubscription = _connectivityService.connectivityStream.listen((result) {
        developer.log('📡 [ExternalPlatforms] Connectivity changed: $result');
        
        if (_connectivityService.isOnline) {
          developer.log('🌐 [ExternalPlatforms] Internet ACTIVE - processing queue instantly');
          _processQueue(); // Instant upload when internet becomes available
        } else {
          developer.log('📴 [ExternalPlatforms] Internet LOST - uploads paused');
        }
      });
      
    } catch (e) {
      developer.log('❌ [ExternalPlatforms] Init error: $e');
    }
  }

  /// Save Telegram credentials securely
  Future<void> setTelegramCredentials(String botToken, String chatId) async {
    await _secureStorage.write(key: _telegramTokenKey, value: botToken);
    await _secureStorage.write(key: _telegramChatIdKey, value: chatId);
    _telegramBotToken = botToken;
    _telegramChatId = chatId;
    developer.log('✅ [ExternalPlatforms] Telegram credentials saved');
  }

  /// Save Discord webhook URL securely
  Future<void> setDiscordWebhook(String webhookUrl) async {
    await _secureStorage.write(key: _discordWebhookKey, value: webhookUrl);
    _discordWebhookUrl = webhookUrl;
    developer.log('✅ [ExternalPlatforms] Discord webhook saved');
  }

  /// Get current configuration status
  Map<String, bool> getConfigurationStatus() {
    return {
      'telegram': _telegramBotToken != null && _telegramChatId != null,
      'discord': _discordWebhookUrl != null,
    };
  }

  /// Queue MEDIA message for upload (ONLY images, videos, audio)
  Future<void> queueMediaForUpload(Message message) async {
    // ONLY queue media messages
    if (message.type != MessageType.image && 
        message.type != MessageType.video && 
        message.type != MessageType.audio) {
      developer.log('⏭️ [ExternalPlatforms] Skipping non-media message: ${message.type}');
      return;
    }
    
    // PREVENT DUPLICATES - Check if already uploaded
    if (_uploadedMessageIds.contains(message.id)) {
      developer.log('⏭️ [ExternalPlatforms] Skipping duplicate: ${message.id} (already uploaded)');
      return;
    }
    
    // Check if already in queue
    if (_uploadQueue.any((m) => m.id == message.id)) {
      developer.log('⏭️ [ExternalPlatforms] Already in queue: ${message.id}');
      return;
    }
    
    developer.log('📥 [ExternalPlatforms] Queuing media: ${message.type} - ${message.id}');
    _uploadQueue.add(message);
    
    // Start processing INSTANTLY if online
    if (_connectivityService.isOnline) {
      developer.log('🚀 [ExternalPlatforms] Internet active - uploading instantly');
      _processQueue();
    } else {
      developer.log('📴 [ExternalPlatforms] Offline - queued for later (will upload when internet available)');
    }
  }

  /// Process upload queue
  Future<void> _processQueue() async {
    if (_isUploading || _uploadQueue.isEmpty) return;
    if (!_connectivityService.isOnline) return;
    
    _isUploading = true;
    developer.log('🚀 [ExternalPlatforms] Processing queue: ${_uploadQueue.length} items');
    
    while (_uploadQueue.isNotEmpty && _connectivityService.isOnline) {
      final message = _uploadQueue.first;
      bool success = true;
      
      try {
        // Upload to Telegram if configured
        if (_telegramBotToken != null && _telegramChatId != null) {
          await _uploadToTelegram(message);
          developer.log('✅ [ExternalPlatforms] Uploaded to Telegram: ${message.id}');
        }
        
        // Upload to Discord if configured
        if (_discordWebhookUrl != null) {
          await _uploadToDiscord(message);
          developer.log('✅ [ExternalPlatforms] Uploaded to Discord: ${message.id}');
        }
        
      } catch (e) {
        developer.log('❌ [ExternalPlatforms] Upload failed: $e');
        success = false;
      }
      
      if (success) {
        // Mark as uploaded to PREVENT DUPLICATES
        _uploadedMessageIds.add(message.id);
        await _saveUploadedMessageIds(); // Persist to storage
        
        // Update message in database with upload status
        final updatedMessage = message.markAsUploadedToTelegram();
        await _storageService.saveMessage(updatedMessage);
        developer.log('✅ [ExternalPlatforms] Marked as uploaded in DB: ${message.id}');
        
        // Remove from queue
        _uploadQueue.removeAt(0);
      } else {
        // Keep in queue for retry, but break to avoid infinite loop
        break;
      }
      
      // Small delay between uploads
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    _isUploading = false;
    
    if (_uploadQueue.isNotEmpty) {
      developer.log('⏸️ [ExternalPlatforms] Queue paused: ${_uploadQueue.length} items remaining');
    } else {
      developer.log('✅ [ExternalPlatforms] Queue empty');
    }
  }

  /// Upload media to Telegram
  Future<void> _uploadToTelegram(Message message) async {
    developer.log('📤 [Telegram] Starting upload for message: ${message.id}');
    developer.log('📤 [Telegram] Message type: ${message.type}');
    developer.log('📤 [Telegram] Content: ${message.content}');
    
    if (_telegramBotToken == null || _telegramChatId == null) {
      developer.log('❌ [Telegram] Not configured!');
      throw Exception('Telegram not configured');
    }
    
    developer.log('✅ [Telegram] Bot token: ${_telegramBotToken?.substring(0, 10)}...');
    developer.log('✅ [Telegram] Chat ID: $_telegramChatId');
    
    // Parse file path and caption
    final parts = message.content.split('|||');
    final filePath = parts[0];
    final caption = parts.length > 1 ? parts[1] : '';
    final file = File(filePath);
    
    developer.log('📂 [Telegram] File path: $filePath');
    developer.log('📂 [Telegram] File exists: ${file.existsSync()}');
    developer.log('📝 [Telegram] Caption: ${caption.isNotEmpty ? caption : "none"}');
    
    if (!file.existsSync()) {
      developer.log('❌ [Telegram] File not found: $filePath');
      throw Exception('File not found: $filePath');
    }
    
    final fileSize = await file.length();
    developer.log('📊 [Telegram] File size: ${fileSize / 1024} KB');
    
    String endpoint;
    String fileField;
    
    // Determine endpoint based on media type
    switch (message.type) {
      case MessageType.image:
        endpoint = 'sendPhoto';
        fileField = 'photo';
        break;
      case MessageType.video:
        endpoint = 'sendVideo';
        fileField = 'video';
        break;
      case MessageType.audio:
        endpoint = 'sendAudio';
        fileField = 'audio';
        break;
      default:
        throw Exception('Unsupported media type: ${message.type}');
    }
    
    final url = 'https://api.telegram.org/bot$_telegramBotToken/$endpoint';
    developer.log('🌐 [Telegram] URL: $url');
    developer.log('🌐 [Telegram] Endpoint: $endpoint');
    developer.log('🌐 [Telegram] File field: $fileField');
    
    // Format caption using TelegramConfig
    final formattedCaption = TelegramConfig.formatCaption(
      senderName: message.senderName,
      timestamp: message.timestamp,
      caption: caption.isNotEmpty ? caption : null,
      mediaType: message.type.toString().split('.').last,
    );
    
    developer.log('📝 [Telegram] Formatted caption: $formattedCaption');
    
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['chat_id'] = _telegramChatId!
      ..fields['caption'] = formattedCaption;
    
    // Add file
    developer.log('📎 [Telegram] Adding file to request...');
    request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    developer.log('📎 [Telegram] File added successfully');
    
    developer.log('🚀 [Telegram] Sending request...');
    final response = await request.send();
    developer.log('📥 [Telegram] Response status: ${response.statusCode}');
    
    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      developer.log('❌ [Telegram] Upload failed: ${response.statusCode}');
      developer.log('❌ [Telegram] Response: $responseBody');
      throw Exception('Telegram upload failed: ${response.statusCode} - $responseBody');
    }
    
    final responseBody = await response.stream.bytesToString();
    developer.log('✅ [Telegram] Upload successful!');
    developer.log('✅ [Telegram] Response: $responseBody');
    developer.log('📱 [Telegram] Uploaded ${message.type} to MO29 channel');
  }

  /// Upload media to Discord
  Future<void> _uploadToDiscord(Message message) async {
    if (_discordWebhookUrl == null) {
      throw Exception('Discord not configured');
    }
    
    // Parse file path and caption
    final parts = message.content.split('|||');
    final filePath = parts[0];
    final caption = parts.length > 1 ? parts[1] : '';
    final file = File(filePath);
    
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }
    
    final request = http.MultipartRequest('POST', Uri.parse(_discordWebhookUrl!));
    
    // Add content (caption)
    final content = caption.isNotEmpty 
        ? '**${message.senderName}**: $caption' 
        : '**${message.senderName}** shared a ${message.type.toString().split('.').last}';
    
    request.fields['content'] = content;
    
    // Add file
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    
    final response = await request.send();
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Discord upload failed: ${response.statusCode} - $responseBody');
    }
    
    developer.log('💬 [Discord] Uploaded ${message.type}: ${file.path}');
  }

  /// Retry failed uploads
  Future<void> retryFailedUploads() async {
    if (_uploadQueue.isNotEmpty && _connectivityService.isOnline) {
      developer.log('🔄 [ExternalPlatforms] Retrying ${_uploadQueue.length} failed uploads');
      await _processQueue();
    }
  }

  /// Clear all credentials (for logout/reset)
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _telegramTokenKey);
    await _secureStorage.delete(key: _telegramChatIdKey);
    await _secureStorage.delete(key: _discordWebhookKey);
    _telegramBotToken = null;
    _telegramChatId = null;
    _discordWebhookUrl = null;
    developer.log('🗑️ [ExternalPlatforms] Credentials cleared');
  }

  /// Get queue status
  Map<String, dynamic> getQueueStatus() {
    return {
      'queueLength': _uploadQueue.length,
      'isUploading': _isUploading,
      'isOnline': _connectivityService.isOnline,
      'telegramConfigured': _telegramBotToken != null && _telegramChatId != null,
      'discordConfigured': _discordWebhookUrl != null,
      'uploadedCount': _uploadedMessageIds.length,
    };
  }

  /// Load uploaded message IDs from storage (to prevent duplicates after app restart)
  Future<void> _loadUploadedMessageIds() async {
    try {
      final stored = await _secureStorage.read(key: 'uploaded_message_ids');
      if (stored != null && stored.isNotEmpty) {
        final List<dynamic> ids = jsonDecode(stored);
        _uploadedMessageIds.addAll(ids.cast<String>());
        developer.log('📥 [ExternalPlatforms] Loaded ${_uploadedMessageIds.length} uploaded message IDs');
      }
    } catch (e) {
      developer.log('⚠️ [ExternalPlatforms] Failed to load uploaded IDs: $e');
    }
  }

  /// Save uploaded message IDs to storage (persist across app restarts)
  Future<void> _saveUploadedMessageIds() async {
    try {
      final ids = _uploadedMessageIds.toList();
      await _secureStorage.write(
        key: 'uploaded_message_ids',
        value: jsonEncode(ids),
      );
      developer.log('💾 [ExternalPlatforms] Saved ${ids.length} uploaded message IDs');
    } catch (e) {
      developer.log('⚠️ [ExternalPlatforms] Failed to save uploaded IDs: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    developer.log('🔌 [ExternalPlatforms] Disposed');
  }
}
