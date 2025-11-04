# Implementation Plan - Production Ready Features

## 🎯 Goal
Make the app production-ready with all features working, especially:
1. Messages displaying correctly after send
2. Media attachments working
3. Telegram/Discord integration
4. Offline/online mode handling
5. Compression verified

---

## 🔧 Phase 1: Fix Critical Bugs (TODAY)

### 1.1 Message Display Fix
**Problem:** Messages sent but not visible in UI

**Root Cause Analysis:**
The issue is likely that the stream is emitting but the UI isn't rebuilding. Possible causes:
1. Stream listener not set up before first emission
2. `setState` not being called
3. Messages filtered out incorrectly

**Solution Implemented:**
- Added debug logging throughout the flow
- Set up listener before initialization
- Added manual refresh fallback

**Next Steps:**
1. Run app and send a test message
2. Check Flutter DevTools console for logs
3. Verify log sequence matches expected flow
4. If logs show emission but no UI update, check widget lifecycle

**Test Command:**
```bash
flutter run --verbose
# Then send a message and watch console
```

### 1.2 Add Proper Error Handling
```dart
// In threads_tab_screen.dart
void _initializeMessageController() async {
  try {
    developer.log('🔧 [ThreadsTab] Starting initialization');
    
    // Set up error handler for stream
    _messageControllerService.messagesStream.listen(
      (messages) {
        developer.log('📡 [ThreadsTab] Stream emission: ${messages.length} messages');
        if (mounted) {
          final filtered = messages.where((m) => m.tab == MessageTab.threads).toList();
          developer.log('📝 [ThreadsTab] Filtered: ${filtered.length} for threads tab');
          setState(() {
            _messages.clear();
            _messages.addAll(filtered);
          });
          developer.log('✅ [ThreadsTab] UI updated successfully');
        } else {
          developer.log('⚠️ [ThreadsTab] Widget not mounted, skipping update');
        }
      },
      onError: (error) {
        developer.log('❌ [ThreadsTab] Stream error: $error');
      },
      onDone: () {
        developer.log('⚠️ [ThreadsTab] Stream closed');
      },
    );
    
    await _messageControllerService.initialize();
    developer.log('✅ [ThreadsTab] Controller initialized');
    
    // Force refresh
    final existing = _messageControllerService.getMessagesByTab(MessageTab.threads);
    developer.log('💾 [ThreadsTab] Loaded ${existing.length} existing messages');
    if (mounted && existing.isNotEmpty) {
      setState(() {
        _messages.clear();
        _messages.addAll(existing);
      });
    }
  } catch (e, stack) {
    developer.log('❌ [ThreadsTab] Initialization error: $e\n$stack');
  }
}
```

---

## 🚀 Phase 2: Implement External Integrations (NEXT)

### 2.1 Secure Configuration Storage

**Create:** `lib/core/config/secure_config.dart`
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureConfig {
  static final SecureConfig _instance = SecureConfig._internal();
  factory SecureConfig() => _instance;
  SecureConfig._internal();

  final _storage = const FlutterSecureStorage();

  // Keys
  static const String telegramBotToken = 'TELEGRAM_BOT_TOKEN';
  static const String telegramChatId = 'TELEGRAM_CHAT_ID';
  static const String discordWebhookUrl = 'DISCORD_WEBHOOK_URL';

  Future<void> setTelegramConfig(String botToken, String chatId) async {
    await _storage.write(key: telegramBotToken, value: botToken);
    await _storage.write(key: telegramChatId, value: chatId);
  }

  Future<void> setDiscordWebhook(String webhookUrl) async {
    await _storage.write(key: discordWebhookUrl, value: webhookUrl);
  }

  Future<String?> getTelegramBotToken() async {
    return await _storage.read(key: telegramBotToken);
  }

  Future<String?> getTelegramChatId() async {
    return await _storage.read(key: telegramChatId);
  }

  Future<String?> getDiscordWebhookUrl() async {
    return await _storage.read(key: discordWebhookUrl);
  }

  Future<bool> isTelegramConfigured() async {
    final token = await getTelegramBotToken();
    final chatId = await getTelegramChatId();
    return token != null && chatId != null;
  }

  Future<bool> isDiscordConfigured() async {
    final url = await getDiscordWebhookUrl();
    return url != null;
  }
}
```

### 2.2 Telegram Integration

**Update:** `pubspec.yaml`
```yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
```

**Create:** `lib/services/external/telegram_service.dart`
```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mesh_app/core/config/secure_config.dart';
import 'package:mesh_app/core/models/message.dart';
import 'dart:developer' as developer;

class TelegramService {
  static final TelegramService _instance = TelegramService._internal();
  factory TelegramService() => _instance;
  TelegramService._internal();

  final _config = SecureConfig();

  Future<bool> sendTextMessage(Message message) async {
    try {
      final botToken = await _config.getTelegramBotToken();
      final chatId = await _config.getTelegramChatId();

      if (botToken == null || chatId == null) {
        developer.log('⚠️ Telegram not configured');
        return false;
      }

      final url = 'https://api.telegram.org/bot$botToken/sendMessage';

      String text = '<b>${message.senderName}</b>';
      if (message.isVerified) {
        text += ' ✅';
      }
      text += '\n${message.content}';
      
      if (message.location != null) {
        text += '\n\n📍 <i>From: ${message.location}</i>';
      }
      
      text += '\n\n🕐 <i>${message.formattedTime}</i>';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': text,
          'parse_mode': 'HTML',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        developer.log('✅ Message sent to Telegram');
        return true;
      } else {
        developer.log('❌ Telegram API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      developer.log('❌ Telegram send error: $e');
      return false;
    }
  }

  Future<bool> sendMediaMessage(Message message, File file) async {
    try {
      final botToken = await _config.getTelegramBotToken();
      final chatId = await _config.getTelegramChatId();

      if (botToken == null || chatId == null) {
        developer.log('⚠️ Telegram not configured');
        return false;
      }

      String endpoint;
      String fieldName;
      
      switch (message.type) {
        case MessageType.image:
          endpoint = 'sendPhoto';
          fieldName = 'photo';
          break;
        case MessageType.video:
          endpoint = 'sendVideo';
          fieldName = 'video';
          break;
        case MessageType.audio:
          endpoint = 'sendAudio';
          fieldName = 'audio';
          break;
        default:
          return false;
      }

      final url = 'https://api.telegram.org/bot$botToken/$endpoint';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['chat_id'] = chatId;
      
      String caption = '<b>${message.senderName}</b>';
      if (message.isVerified) caption += ' ✅';
      if (message.content.isNotEmpty) {
        caption += '\n${message.content}';
      }
      if (message.location != null) {
        caption += '\n📍 ${message.location}';
      }
      
      request.fields['caption'] = caption;
      request.fields['parse_mode'] = 'HTML';

      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

      final response = await request.send().timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        developer.log('✅ Media sent to Telegram');
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        developer.log('❌ Telegram media error: ${response.statusCode} - $responseBody');
        return false;
      }
    } catch (e) {
      developer.log('❌ Telegram media send error: $e');
      return false;
    }
  }
}
```

### 2.3 Discord Integration

**Create:** `lib/services/external/discord_service.dart`
```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mesh_app/core/config/secure_config.dart';
import 'package:mesh_app/core/models/message.dart';
import 'dart:developer' as developer;

class DiscordService {
  static final DiscordService _instance = DiscordService._internal();
  factory DiscordService() => _instance;
  DiscordService._internal();

  final _config = SecureConfig();

  Future<bool> sendTextMessage(Message message) async {
    try {
      final webhookUrl = await _config.getDiscordWebhookUrl();

      if (webhookUrl == null) {
        developer.log('⚠️ Discord not configured');
        return false;
      }

      final embed = {
        'embeds': [{
          'author': {
            'name': message.senderName + (message.isVerified ? ' ✅' : ''),
          },
          'description': message.content,
          'color': message.isVerified ? 0x00FF00 : 0x3498db,
          'footer': {
            'text': message.location ?? 'Unknown location',
          },
          'timestamp': message.timestamp.toIso8601String(),
        }],
      };

      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(embed),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 204 || response.statusCode == 200) {
        developer.log('✅ Message sent to Discord');
        return true;
      } else {
        developer.log('❌ Discord webhook error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      developer.log('❌ Discord send error: $e');
      return false;
    }
  }

  // Note: Discord webhooks don't support file uploads directly
  // You'd need to upload to a CDN first or use a bot instead
  Future<bool> sendMediaMessage(Message message, File file) async {
    developer.log('⚠️ Discord media upload not implemented - use bot instead of webhook');
    return false;
  }
}
```

### 2.4 Update Message Controller

**Update:** `lib/services/message_controller.dart`
```dart
import 'package:mesh_app/services/external/telegram_service.dart';
import 'package:mesh_app/services/external/discord_service.dart';

class MessageController {
  // Add these fields
  final TelegramService _telegramService = TelegramService();
  final DiscordService _discordService = DiscordService();

  // Update this method
  Future<void> _relayToExternalPlatforms(Message message) async {
    developer.log('🌐 Relaying to external platforms');
    
    try {
      // Send to Telegram
      final telegramSent = await _telegramService.sendTextMessage(message);
      if (telegramSent) {
        developer.log('✅ Sent to Telegram');
      }

      // Send to Discord
      final discordSent = await _discordService.sendTextMessage(message);
      if (discordSent) {
        developer.log('✅ Sent to Discord');
      }
    } catch (e) {
      developer.log('❌ External relay error: $e');
    }
  }
}
```

---

## 📱 Phase 3: Settings Screen for Configuration

**Create:** `lib/presentation/screens/settings/settings_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:mesh_app/core/config/secure_config.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _config = SecureConfig();
  final _telegramBotController = TextEditingController();
  final _telegramChatController = TextEditingController();
  final _discordWebhookController = TextEditingController();

  bool _telegramConfigured = false;
  bool _discordConfigured = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    _telegramConfigured = await _config.isTelegramConfigured();
    _discordConfigured = await _config.isDiscordConfigured();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        children: [
          _buildSectionTitle('External Integrations'),
          const SizedBox(height: AppTheme.spacingM),
          
          // Telegram Configuration
          _buildConfigCard(
            title: 'Telegram Bot',
            configured: _telegramConfigured,
            icon: Icons.telegram,
            onConfigure: () => _showTelegramDialog(),
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Discord Configuration
          _buildConfigCard(
            title: 'Discord Webhook',
            configured: _discordConfigured,
            icon: Icons.discord,
            onConfigure: () => _showDiscordDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildConfigCard({
    required String title,
    required bool configured,
    required IconData icon,
    required VoidCallback onConfigure,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: configured ? AppTheme.accentColor : AppTheme.textHint),
        title: Text(title),
        subtitle: Text(configured ? 'Configured ✓' : 'Not configured'),
        trailing: ElevatedButton(
          onPressed: onConfigure,
          child: Text(configured ? 'Update' : 'Configure'),
        ),
      ),
    );
  }

  void _showTelegramDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure Telegram Bot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _telegramBotController,
              decoration: const InputDecoration(
                labelText: 'Bot Token',
                hintText: '123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11',
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _telegramChatController,
              decoration: const InputDecoration(
                labelText: 'Chat ID',
                hintText: '-1001234567890',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _config.setTelegramConfig(
                _telegramBotController.text,
                _telegramChatController.text,
              );
              Navigator.pop(context);
              _loadConfig();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Telegram configured!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDiscordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure Discord Webhook'),
        content: TextField(
          controller: _discordWebhookController,
          decoration: const InputDecoration(
            labelText: 'Webhook URL',
            hintText: 'https://discord.com/api/webhooks/...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _config.setDiscordWebhook(_discordWebhookController.text);
              Navigator.pop(context);
              _loadConfig();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Discord configured!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
```

---

## 📝 Implementation Steps

### Step 1: Add Dependencies
```bash
flutter pub add http flutter_secure_storage
```

### Step 2: Create Files
1. `lib/core/config/secure_config.dart`
2. `lib/services/external/telegram_service.dart`
3. `lib/services/external/discord_service.dart`
4. `lib/presentation/screens/settings/settings_screen.dart`

### Step 3: Update Message Controller
- Import new services
- Update `_relayToExternalPlatforms()` method

### Step 4: Add Settings to Home Screen
```dart
// In home_screen.dart AppBar
actions: [
  IconButton(
    icon: const Icon(Icons.settings),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
    },
  ),
],
```

### Step 5: Test
1. Run app
2. Go to Settings
3. Configure Telegram bot
4. Configure Discord webhook
5. Send a message
6. Verify it appears in Telegram/Discord

---

## ✅ Success Criteria

- [ ] Messages appear in UI immediately after sending
- [ ] Telegram receives text messages
- [ ] Discord receives text messages
- [ ] Settings screen allows configuration
- [ ] Credentials stored securely
- [ ] Works offline (queues for later)
- [ ] Works online (sends immediately)
- [ ] Media files compress correctly
- [ ] All features tested and working

---

**Created:** October 26, 2025
**Priority:** HIGH
**Status:** Ready for Implementation
