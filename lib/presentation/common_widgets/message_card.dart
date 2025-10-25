import 'package:flutter/material.dart';
import 'package:mesh_app/core/models/message.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final VoidCallback? onTap;
  final VoidCallback? onReply;
  final bool showAvatar;
  final bool isThreadStart;

  const MessageCard({
    super.key,
    required this.message,
    this.isOwnMessage = false,
    this.onTap,
    this.onReply,
    this.showAvatar = true,
    this.isThreadStart = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar column
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  if (showAvatar) _buildAvatar(),
                  if (!showAvatar && !isThreadStart) _buildThreadLine(),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            // Message content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.messageBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(color: AppTheme.messageBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with name, verified badge, and timestamp
                    _buildMessageHeader(context),
                    const SizedBox(height: AppTheme.spacingS),
                    // Message content
                    _buildMessageContent(context),
                    const SizedBox(height: AppTheme.spacingM),
                    // Engagement row
                    _buildEngagementRow(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 18,
      backgroundColor:
          message.isVerified ? AppTheme.verifiedBadge : AppTheme.accentColor,
      child: Text(
        message.senderName.isNotEmpty
            ? message.senderName[0].toUpperCase()
            : 'A',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThreadLine() {
    return Expanded(
      child: Container(
        width: 2,
        margin: const EdgeInsets.only(left: 17),
        decoration: BoxDecoration(
          color: message.isVerified
              ? AppTheme.verifiedBadge.withAlpha((255 * 0.4).round())
              : AppTheme.textHint.withAlpha((255 * 0.3).round()),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildMessageHeader(BuildContext context) {
    return Row(
      children: [
        // Sender name - green if verified
        Text(
          message.senderName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: message.isVerified
                    ? AppTheme.verifiedBadge
                    : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        if (message.isVerified) ...[
          const SizedBox(width: AppTheme.spacingXS),
          const Icon(
            Icons.verified,
            size: 16,
            color: AppTheme.verifiedBadge,
          ),
        ],
        const Spacer(),
        // Timestamp
        Text(
          message.formattedTime,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textHint,
              ),
        ),
      ],
    );
  }

  Widget _buildEngagementRow(BuildContext context) {
    return Row(
      children: [
        // Reply button
        _buildEngagementButton(
          icon: Icons.reply_outlined,
          label: 'Reply',
          onTap: onReply,
        ),
        const SizedBox(width: AppTheme.spacingL),
        // Share button
        _buildEngagementButton(
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: () {},
        ),
        const SizedBox(width: AppTheme.spacingL),
        // Hop count indicator
        if (message.hopCount > 0)
          Row(
            children: [
              Icon(
                Icons.alt_route,
                size: 14,
                color: AppTheme.textHint,
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                '${message.hopCount} hops',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textHint,
                    ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEngagementButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingS, vertical: AppTheme.spacingXS),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacingXS),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.4,
              ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 48, color: AppTheme.textHint),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        );
      case MessageType.audio:
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio message',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            AppTheme.accentColor.withAlpha((255 * 0.3).round()),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case MessageType.video:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.play_circle_outline,
                        size: 48, color: AppTheme.textHint),
                  ),
                  Positioned(
                    bottom: AppTheme.spacingS,
                    right: AppTheme.spacingS,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                          vertical: AppTheme.spacingXS),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((255 * 0.7).round()),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: const Text(
                        '0:15',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        );
    }
  }
}
