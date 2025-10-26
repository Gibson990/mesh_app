import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mesh_app/core/models/message.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final VoidCallback? onTap;
  final VoidCallback? onReply;
  final VoidCallback? onShare;
  final bool showAvatar;
  final bool isThreadStart;
  final Message? parentMessage;

  const MessageCard({
    super.key,
    required this.message,
    this.isOwnMessage = false,
    this.onTap,
    this.onReply,
    this.onShare,
    this.showAvatar = true,
    this.isThreadStart = true,
    this.parentMessage,
  });

  @override
  Widget build(BuildContext context) {
    developer.log('💬 [MessageCard] Rendering: ${message.type} - ${message.id.substring(0, 8)}');
    
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showAvatar) _buildAvatar(),
                  if (!showAvatar && !isThreadStart) _buildThreadLine(),
                  if (!showAvatar && isThreadStart) const SizedBox(height: 40),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            // Message content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: parentMessage != null 
                      ? AppTheme.accentColor.withAlpha((255 * 0.05).round())
                      : AppTheme.messageBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(
                    color: parentMessage != null
                        ? AppTheme.accentColor.withAlpha((255 * 0.2).round())
                        : AppTheme.messageBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with name, verified badge, and timestamp
                    _buildMessageHeader(context),
                    const SizedBox(height: AppTheme.spacingS),
                    // Reply indicator
                    if (parentMessage != null) ...[
                      _buildReplyIndicator(context),
                      const SizedBox(height: AppTheme.spacingS),
                    ],
                    // Message content
                    _buildMessageContent(context),
                    // Location display
                    if (message.location != null) ...[
                      const SizedBox(height: AppTheme.spacingS),
                      _buildLocationDisplay(context),
                    ],
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
    return Container(
      width: 2,
      height: 20,  // Fixed height instead of Expanded
      margin: const EdgeInsets.only(left: 17),
      decoration: BoxDecoration(
        color: message.isVerified
            ? AppTheme.verifiedBadge.withAlpha((255 * 0.4).round())
            : AppTheme.textHint.withAlpha((255 * 0.3).round()),
        borderRadius: BorderRadius.circular(1),
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
          onTap: onShare,
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

  Widget _buildLocationDisplay(BuildContext context) {
    return Text(
      'from ${message.location}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textHint,
            fontStyle: FontStyle.italic,
            fontSize: 11,
          ),
    );
  }

  Widget _buildReplyIndicator(BuildContext context) {
    if (parentMessage == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border(
          left: BorderSide(
            color: AppTheme.accentColor,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 14,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentMessage!.senderName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  parentMessage!.type == MessageType.text
                      ? parentMessage!.content
                      : _getMediaTypeLabel(parentMessage!.type),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMediaTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Voice note';
      default:
        return 'Message';
    }
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
        // Parse content: could be "path" or "path|||caption"
        final parts = message.content.split('|||');
        final imagePath = parts[0];
        final caption = parts.length > 1 ? parts[1] : null;
        
        developer.log('🖼️ [MessageCard] Rendering image: $imagePath');
        developer.log('🖼️ [MessageCard] Caption: ${caption ?? "none"}');
        
        // Try to check if file exists
        bool fileExists = false;
        try {
          fileExists = File(imagePath).existsSync();
          developer.log('🖼️ [MessageCard] File exists: $fileExists');
        } catch (e) {
          developer.log('❌ [MessageCard] Error checking file: $e');
        }
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                  minHeight: 150,
                ),
                width: double.infinity,
                child: imagePath.isNotEmpty
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: frame == null
                                ? Container(
                                    height: 200,
                                    color: AppTheme.surfaceVariant,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : child,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          developer.log('❌ [MessageCard] Image load error: $error');
                          developer.log('❌ [MessageCard] Stack trace: $stackTrace');
                          developer.log('❌ [MessageCard] File path: $imagePath');
                          developer.log('❌ [MessageCard] File exists: ${File(imagePath).existsSync()}');
                          
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accentColor.withAlpha((255 * 0.1).round()),
                                  AppTheme.surfaceVariant,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.broken_image, size: 48, color: AppTheme.textHint),
                                  const SizedBox(height: 8),
                                  const Text('Image not found', style: TextStyle(color: AppTheme.textHint)),
                                  const SizedBox(height: 4),
                                  Text(
                                    imagePath.split('/').last,
                                    style: const TextStyle(color: AppTheme.textHint, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Error: ${error.toString().substring(0, error.toString().length > 30 ? 30 : error.toString().length)}',
                                    style: const TextStyle(color: Colors.red, fontSize: 9),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                : Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentColor.withAlpha((255 * 0.1).round()),
                          AppTheme.surfaceVariant,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.image, size: 64, color: AppTheme.textHint),
                          const SizedBox(height: 8),
                          const Text(
                            'Image not available',
                            style: TextStyle(color: AppTheme.textHint, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
            ),
            // Display caption if exists
            if (caption != null && caption.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                caption,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
            ],
          ],
        );
      case MessageType.audio:
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentColor.withAlpha((255 * 0.1).round()),
                AppTheme.accentColor.withAlpha((255 * 0.05).round()),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color: AppTheme.accentColor.withAlpha((255 * 0.2).round()),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor,
                      AppTheme.accentColor.withAlpha((255 * 0.8).round()),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withAlpha((255 * 0.3).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.mic,
                          size: 16,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(
                          'Voice message',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withAlpha((255 * 0.2).round()),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.3,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      '0:15',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case MessageType.video:
        // Parse content: could be "path" or "path|||caption"
        final videoParts = message.content.split('|||');
        final videoPath = videoParts[0];
        final videoCaption = videoParts.length > 1 ? videoParts[1] : null;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha((255 * 0.8).round()),
                      Colors.black.withAlpha((255 * 0.6).round()),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((255 * 0.9).round()),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((255 * 0.3).round()),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 36,
                          color: AppTheme.textPrimary,
                        ),
                      ),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.videocam,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '0:15',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (videoCaption != null && videoCaption.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                videoCaption,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
            ],
          ],
        );
    }
  }
}
