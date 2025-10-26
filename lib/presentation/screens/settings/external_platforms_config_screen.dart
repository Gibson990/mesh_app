import 'package:flutter/material.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';
import 'package:mesh_app/services/external_platforms_service.dart';

class ExternalPlatformsConfigScreen extends StatefulWidget {
  const ExternalPlatformsConfigScreen({super.key});

  @override
  State<ExternalPlatformsConfigScreen> createState() => _ExternalPlatformsConfigScreenState();
}

class _ExternalPlatformsConfigScreenState extends State<ExternalPlatformsConfigScreen> {
  final ExternalPlatformsService _service = ExternalPlatformsService();
  
  final TextEditingController _telegramTokenController = TextEditingController();
  final TextEditingController _telegramChatIdController = TextEditingController();
  final TextEditingController _discordWebhookController = TextEditingController();
  
  bool _telegramConfigured = false;
  bool _discordConfigured = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  void _loadStatus() {
    final status = _service.getConfigurationStatus();
    setState(() {
      _telegramConfigured = status['telegram'] ?? false;
      _discordConfigured = status['discord'] ?? false;
    });
  }

  Future<void> _saveTelegramConfig() async {
    if (_telegramTokenController.text.isEmpty || _telegramChatIdController.text.isEmpty) {
      _showError('Please enter both Bot Token and Chat ID');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.setTelegramCredentials(
        _telegramTokenController.text.trim(),
        _telegramChatIdController.text.trim(),
      );
      
      setState(() {
        _telegramConfigured = true;
        _telegramTokenController.clear();
        _telegramChatIdController.clear();
      });
      
      _showSuccess('Telegram configured successfully!');
    } catch (e) {
      _showError('Failed to save Telegram config: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveDiscordConfig() async {
    if (_discordWebhookController.text.isEmpty) {
      _showError('Please enter Discord Webhook URL');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.setDiscordWebhook(_discordWebhookController.text.trim());
      
      setState(() {
        _discordConfigured = true;
        _discordWebhookController.clear();
      });
      
      _showSuccess('Discord configured successfully!');
    } catch (e) {
      _showError('Failed to save Discord config: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('External Platforms'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Configure Telegram and Discord to auto-upload media files',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Telegram Section
            _buildSectionHeader('Telegram Bot', _telegramConfigured),
            const SizedBox(height: 16),
            
            TextField(
              controller: _telegramTokenController,
              decoration: InputDecoration(
                labelText: 'Bot Token',
                hintText: '123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11',
                prefixIcon: const Icon(Icons.key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            
            const SizedBox(height: 12),
            
            TextField(
              controller: _telegramChatIdController,
              decoration: InputDecoration(
                labelText: 'Chat ID',
                hintText: '123456789',
                prefixIcon: const Icon(Icons.chat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveTelegramConfig,
                icon: const Icon(Icons.save),
                label: const Text('Save Telegram Config'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildInstructionsButton('Telegram Setup Guide', _showTelegramInstructions),
            
            const SizedBox(height: 32),
            
            // Discord Section
            _buildSectionHeader('Discord Webhook', _discordConfigured),
            const SizedBox(height: 16),
            
            TextField(
              controller: _discordWebhookController,
              decoration: InputDecoration(
                labelText: 'Webhook URL',
                hintText: 'https://discord.com/api/webhooks/...',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveDiscordConfig,
                icon: const Icon(Icons.save),
                label: const Text('Save Discord Config'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildInstructionsButton('Discord Setup Guide', _showDiscordInstructions),
            
            const SizedBox(height: 32),
            
            // Queue Status
            _buildQueueStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool configured) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        if (configured)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Configured',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInstructionsButton(String label, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.help_outline),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildQueueStatus() {
    final status = _service.getQueueStatus();
    final queueLength = status['queueLength'] as int;
    final isUploading = status['isUploading'] as bool;
    final isOnline = status['isOnline'] as bool;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Queue Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusRow('Queue Length', '$queueLength items'),
          _buildStatusRow('Status', isUploading ? 'Uploading...' : 'Idle'),
          _buildStatusRow('Connection', isOnline ? 'Online' : 'Offline'),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showTelegramInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Telegram Setup Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('1. Open Telegram and search for @BotFather'),
              SizedBox(height: 8),
              Text('2. Send /newbot command'),
              SizedBox(height: 8),
              Text('3. Follow instructions to create your bot'),
              SizedBox(height: 8),
              Text('4. Copy the Bot Token provided'),
              SizedBox(height: 16),
              Text('5. Send a message to your bot'),
              SizedBox(height: 8),
              Text('6. Visit: https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates'),
              SizedBox(height: 8),
              Text('7. Find "chat":{"id":123456789}'),
              SizedBox(height: 8),
              Text('8. Copy the Chat ID'),
              SizedBox(height: 16),
              Text('9. Paste both values above and save'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showDiscordInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discord Setup Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('1. Open Discord and go to your server'),
              SizedBox(height: 8),
              Text('2. Right-click on the channel you want'),
              SizedBox(height: 8),
              Text('3. Select "Edit Channel"'),
              SizedBox(height: 8),
              Text('4. Go to "Integrations" tab'),
              SizedBox(height: 8),
              Text('5. Click "Create Webhook"'),
              SizedBox(height: 8),
              Text('6. Give it a name (e.g., "Mesh App")'),
              SizedBox(height: 8),
              Text('7. Click "Copy Webhook URL"'),
              SizedBox(height: 8),
              Text('8. Paste the URL above and save'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _telegramTokenController.dispose();
    _telegramChatIdController.dispose();
    _discordWebhookController.dispose();
    super.dispose();
  }
}
