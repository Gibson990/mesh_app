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
      _connectivityService.connectionModeStream.listen(_handleConnectivityChange);

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

  // Internal send message method
  Future<bool> _sendMessage(Message message) async {
    try {
      // Save to local storage
      await _storageService.saveMessage(message);

      // Add to local list
      _allMessages.add(message);
      _messagesController.add(_allMessages);

      // Send via Bluetooth
      await _bluetoothService.sendMessage(message);

      // If online, relay to external platforms (optional)
      if (_connectivityService.isOnline) {
        await _relayToExternalPlatforms(message);
      }

      return true;
    } catch (e) {
      developer.log('Send message error: $e');
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
    // This is a placeholder for external relay functionality
    // In a real implementation, you would use HTTP requests to relay messages
    // to Telegram bots or Discord webhooks
    developer.log('Relaying message to external platforms: ${message.content}');
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

