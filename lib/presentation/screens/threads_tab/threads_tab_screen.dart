import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesh_app/core/models/message.dart';
import 'package:mesh_app/core/models/user.dart';
import 'package:mesh_app/presentation/common_widgets/message_card.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class ThreadsTabScreen extends StatefulWidget {
  const ThreadsTabScreen({super.key});

  @override
  State<ThreadsTabScreen> createState() => _ThreadsTabScreenState();
}

class _ThreadsTabScreenState extends State<ThreadsTabScreen> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = User.anonymous();
    _loadDummyMessages();
  }

  void _loadDummyMessages() {
    // Add some dummy messages for demonstration
    final uuid = Uuid();
    _messages.addAll([
      Message(
        id: uuid.v4(),
        senderId: 'user1',
        senderName: 'User#A7F3',
        content: 'Hey everyone! Is anyone else experiencing connection issues?',
        type: MessageType.text,
        tab: MessageTab.threads,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        contentHash: 'hash1',
        hopCount: 2,
      ),
      Message(
        id: uuid.v4(),
        senderId: 'user2',
        senderName: 'User#B2K9',
        content:
            'Yes, the network has been spotty. Try switching to Bluetooth mode.',
        type: MessageType.text,
        tab: MessageTab.threads,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        contentHash: 'hash2',
        hopCount: 1,
      ),
      Message(
        id: uuid.v4(),
        senderId: 'admin1',
        senderName: 'Coordinator',
        content: 'Important: Meeting point has changed to the library at 3 PM.',
        type: MessageType.text,
        tab: MessageTab.threads,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        contentHash: 'hash3',
        isVerified: true,
        hopCount: 0,
      ),
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    final uuid = Uuid();
    final newMessage = Message(
      id: uuid.v4(),
      senderId: _currentUser.id,
      senderName: _currentUser.name,
      content: _messageController.text.trim(),
      type: MessageType.text,
      tab: MessageTab.threads,
      timestamp: DateTime.now(),
      contentHash: uuid.v4(), // Simplified hash for demo
      isVerified: _currentUser.isHigherAccess,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    // Scroll to bottom with animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppTheme.mediumAnimation,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Connection status banner
        _buildConnectionBanner(),
        // Messages list
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isOwnMessage = message.senderId == _currentUser.id;
                    final isThreadStart = index == 0 ||
                        _messages[index - 1].senderId != message.senderId;
                    final showAvatar = isThreadStart;

                    return MessageCard(
                      message: message,
                      isOwnMessage: isOwnMessage,
                      showAvatar: showAvatar,
                      isThreadStart: isThreadStart,
                      onTap: () {
                        // TODO: Show message details or reply options
                      },
                      onReply: () {
                        // TODO: Implement reply functionality
                      },
                    );
                  },
                ),
        ),
        // Message input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildConnectionBanner() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: AppTheme.accentColor.withAlpha((255 * 0.2).round()),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bluetooth_connected,
            size: 16,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            'Connected • 12 peers',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your peers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textHint,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.messageBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Audio recording button only
            _buildMediaButton(
              icon: Icons.mic_outlined,
              onTap: () {
                // TODO: Record audio
              },
            ),
            const SizedBox(width: AppTheme.spacingM),
            // Text input
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Start a thread...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingM,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceVariant,
                ),
                maxLines: 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            // Send button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.white,
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        child: AnimatedContainer(
          duration: AppTheme.shortAnimation,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
