import 'package:flutter/material.dart';
import 'package:mesh_app/core/models/message.dart';
import 'package:mesh_app/presentation/common_widgets/message_card.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class UpdatesTabScreen extends StatefulWidget {
  const UpdatesTabScreen({super.key});

  @override
  State<UpdatesTabScreen> createState() => _UpdatesTabScreenState();
}

class _UpdatesTabScreenState extends State<UpdatesTabScreen> {
  final List<Message> _updates = [];
  final TextEditingController _updateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDummyUpdates();
  }

  void _loadDummyUpdates() {
    final uuid = Uuid();
    _updates.addAll([
      Message(
        id: uuid.v4(),
        senderId: 'admin1',
        senderName: 'Coordinator',
        content: 'Official Update: All participants should gather at the main square by 2 PM.',
        type: MessageType.text,
        tab: MessageTab.updates,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        contentHash: 'hash_update1',
        isVerified: true,
      ),
      Message(
        id: uuid.v4(),
        senderId: 'admin2',
        senderName: 'Safety Officer',
        content: 'Safety reminder: Stay in groups and keep your phones charged.',
        type: MessageType.text,
        tab: MessageTab.updates,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        contentHash: 'hash_update2',
        isVerified: true,
      ),
    ]);
  }

  void _postUpdate() {
    if (_updateController.text.trim().isEmpty) return;

    final uuid = Uuid();
    final newUpdate = Message(
      id: uuid.v4(),
      senderId: 'current_admin',
      senderName: 'Verified User',
      content: _updateController.text.trim(),
      type: MessageType.text,
      tab: MessageTab.updates,
      timestamp: DateTime.now(),
      contentHash: uuid.v4(),
      isVerified: true,
    );

    setState(() {
      _updates.insert(0, newUpdate);
      _updateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info banner
        _buildInfoBanner(),
        // Post update section (for higher-access users)
        _buildPostUpdateSection(),
        // Updates list
        Expanded(
          child: _updates.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _updates.length,
                  itemBuilder: (context, index) {
                    return MessageCard(
                      message: _updates[index],
                      isOwnMessage: false,
                      onTap: () {
                        // TODO: Show update details
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.verifiedBadge.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.verifiedBadge.withAlpha((255 * 0.3).round()),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified,
            color: AppTheme.verifiedBadge,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified Updates',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.verifiedBadge,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Only verified users can post here. These are trusted announcements.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostUpdateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post Official Update',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _updateController,
            decoration: InputDecoration(
              hintText: 'Write an important announcement...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _postUpdate,
              icon: const Icon(Icons.send),
              label: const Text('Post Update'),
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
            Icons.campaign_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No updates yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verified users will post important announcements here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textHint,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }
}

