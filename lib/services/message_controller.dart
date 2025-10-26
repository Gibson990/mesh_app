import 'dart:developer' as developer;
import 'dart:async';
import 'package:mesh_app/core/algorithms/encryption_service.dart';
import 'package:mesh_app/core/models/message.dart';

import 'package:mesh_app/services/bluetooth/bluetooth_service.dart';
import 'package:mesh_app/services/connectivity/connectivity_service.dart';
import 'package:mesh_app/services/notifications/notification_service.dart';
import 'package:mesh_app/services/storage/auth_service.dart';
import 'package:mesh_app/services/storage/storage_service.dart';
import 'package:uuid/uuid.dart';

class MessageController {
  static final MessageController _instance = MessageController._internal();
  factory MessageController() => _instance;
  MessageController._internal();

  final BluetoothService _bluetoothService = BluetoothService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  final StreamController<List<Message>> _messagesController =
      StreamController<List<Message>>.broadcast();

  Stream<List<Message>> get messagesStream => _messagesController.stream;

  List<Message> _allMessages = [];
  bool _isInitialized = false;

  // Spam prevention
  final List<DateTime> _recentSendTimes = [];
  static const int _maxMessagesPerMinute = 10;
  static const Duration _cooldownPeriod = Duration(seconds: 3);

  // Initialize message controller
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize services
      await _authService.initialize();
      await _connectivityService.initialize();
      await _notificationService.initialize();

      // Initialize Bluetooth
      final bluetoothReady = await _bluetoothService.initialize();
      if (bluetoothReady) {
        await _bluetoothService.startScanning();
      }

      // Load messages from storage
      _allMessages = await _storageService.getAllMessages();
      _messagesController.add(_allMessages);

      // Listen to incoming Bluetooth messages
      _bluetoothService.messageStream.listen(_handleIncomingMessage);

      // Listen to connectivity changes
      _connectivityService.connectionModeStream
          .listen(_handleConnectivityChange);

      _isInitialized = true;
    } catch (e) {
      developer.log('Message controller initialization error: $e');
    }
  }

  // Send a text message
  Future<bool> sendTextMessage(String content, MessageTab tab) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      final uuid = Uuid();
      final contentHash = EncryptionService.generateHash(content);

      final message = Message(
        id: uuid.v4(),
        senderId: user.id,
        senderName: user.name,
        content: content,
        type: MessageType.text,
        tab: tab,
        timestamp: DateTime.now(),
        contentHash: contentHash,
        isVerified: user.isHigherAccess,
      );

      return await _sendMessage(message);
    } catch (e) {
      developer.log('Send text message error: $e');
      return false;
    }
  }

  // Send a media message
  Future<bool> sendMediaMessage({
    required String content,
    required MessageType type,
    required MessageTab tab,
  }) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      final uuid = Uuid();
      final contentHash = EncryptionService.generateHash(content);

      final message = Message(
        id: uuid.v4(),
        senderId: user.id,
        senderName: user.name,
        content: content,
        type: type,
        tab: tab,
        timestamp: DateTime.now(),
        contentHash: contentHash,
        isVerified: user.isHigherAccess,
      );

      return await _sendMessage(message);
    } catch (e) {
      developer.log('Send media message error: $e');
      return false;
    }
  }

  // Check if user can send (spam prevention)
  bool _canSendMessage() {
    final now = DateTime.now();

    // Remove timestamps older than 1 minute
    _recentSendTimes.removeWhere(
      (time) => now.difference(time) > const Duration(minutes: 1),
    );

    // Check rate limit
    if (_recentSendTimes.length >= _maxMessagesPerMinute) {
      developer.log(
          'Rate limit exceeded: ${_recentSendTimes.length} messages in last minute');
      return false;
    }

    // Check cooldown
    if (_recentSendTimes.isNotEmpty) {
      final lastSendTime = _recentSendTimes.last;
      if (now.difference(lastSendTime) < _cooldownPeriod) {
        developer.log(
            'Cooldown active: ${_cooldownPeriod.inSeconds}s between messages');
        return false;
      }
    }

    return true;
  }

  // Internal send message method
  Future<bool> _sendMessage(Message message) async {
    try {
      developer.log('📤 Sending message: ${message.id} - ${message.type} - ${message.tab}');
      
      // Check spam prevention
      if (!_canSendMessage()) {
        developer.log('❌ Message blocked by spam prevention');
        return false;
      }

      // Record send time
      _recentSendTimes.add(DateTime.now());

      // Save to local storage
      final saved = await _storageService.saveMessage(message);
      developer.log('💾 Message saved to storage: $saved');

      // Add to local list
      _allMessages.add(message);
      developer.log('📝 Added to local list. Total messages: ${_allMessages.length}');
      
      // Emit to stream
      _messagesController.add(List.from(_allMessages));
      developer.log('📡 Emitted to stream. Listeners: ${_messagesController.hasListener}');

      // Send via Bluetooth
      await _bluetoothService.sendMessage(message);
      developer.log('📶 Sent via Bluetooth');

      // If online, relay to external platforms (optional)
      if (_connectivityService.isOnline) {
        developer.log('🌐 Online - relaying to external platforms');
        await _relayToExternalPlatforms(message);
      } else {
        developer.log('📴 Offline - skipping external relay');
      }

      developer.log('✅ Message sent successfully');
      return true;
    } catch (e) {
      developer.log('❌ Send message error: $e');
      return false;
    }
  }

  // Handle incoming message from Bluetooth
  void _handleIncomingMessage(Message message) async {
    try {
      // Check for spam/duplicates
      if (_isDuplicate(message)) {
        developer.log('Duplicate message detected');
        return;
      }

      // Save to storage
      final saved = await _storageService.saveMessage(message);
      if (!saved) return;

      // Add to local list
      _allMessages.add(message);
      _messagesController.add(_allMessages);

      // Show notification
      if (message.tab == MessageTab.updates && message.isVerified) {
        await _notificationService.showUpdateNotification(message);
      } else {
        await _notificationService.showMessageNotification(message);
      }
    } catch (e) {
      developer.log('Handle incoming message error: $e');
    }
  }

  // Check if message is duplicate
  bool _isDuplicate(Message message) {
    return _allMessages.any((m) => m.contentHash == message.contentHash);
  }

  // Handle connectivity changes
  void _handleConnectivityChange(ConnectionMode mode) {
    if (mode == ConnectionMode.online) {
      developer.log('Internet available - enabling relay mode');
      // Optionally sync pending messages
    } else {
      developer.log('Offline - Bluetooth mesh only');
    }
  }

  // Relay message to external platforms (Telegram/Discord)
  Future<void> _relayToExternalPlatforms(Message message) async {
    // TODO: Implement Telegram relay
    // 1. Add 'http' package to pubspec.yaml
    // 2. Configure bot token and channel ID in app_constants.dart
    // 3. Use Telegram Bot API to send messages:
    //    POST https://api.telegram.org/bot{token}/sendMessage
    //    Body: {"chat_id": "{channelId}", "text": "{message}"}

    // TODO: Implement Discord relay
    // 1. Configure webhook URL in app_constants.dart
    // 2. Use Discord Webhook API to send messages:
    //    POST {webhookUrl}
    //    Body: {"content": "{message}"}

    developer.log('Relay placeholder - Message: ${message.content}');
    developer.log('Configure tokens in lib/core/constants/app_constants.dart');
  }

  // Get messages by tab
  List<Message> getMessagesByTab(MessageTab tab) {
    return _allMessages.where((m) => m.tab == tab).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Search messages
  Future<List<Message>> searchMessages(String query) async {
    return await _storageService.searchMessages(query);
  }

  // Delete message
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _storageService.deleteMessage(messageId);
      _allMessages.removeWhere((m) => m.id == messageId);
      _messagesController.add(_allMessages);
      return true;
    } catch (e) {
      developer.log('Delete message error: $e');
      return false;
    }
  }

  // Get peer count
  int get peerCount => _bluetoothService.connectedPeerCount;

  // Get peer count stream
  Stream<int> get peerCountStream => _bluetoothService.peerCountStream;

  // Dispose resources
  void dispose() {
    _messagesController.close();
    _bluetoothService.dispose();
    _connectivityService.dispose();
  }
}
