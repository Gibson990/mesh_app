import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:screenshot/screenshot.dart';
import 'package:mesh_app/core/models/message.dart';
import 'package:mesh_app/core/models/user.dart';
import 'package:mesh_app/presentation/common_widgets/message_card.dart';
import 'package:mesh_app/presentation/common_widgets/voice_note_recorder.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';
import 'package:mesh_app/services/message_controller.dart';
import 'package:mesh_app/services/storage/auth_service.dart';
import 'package:mesh_app/utils/media_picker_helper.dart';
import 'package:path_provider/path_provider.dart';

class ThreadsTabScreen extends StatefulWidget {
  const ThreadsTabScreen({super.key});

  @override
  State<ThreadsTabScreen> createState() => _ThreadsTabScreenState();
}

class _ThreadsTabScreenState extends State<ThreadsTabScreen> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageController _messageControllerService = MessageController();
  final AuthService _authService = AuthService();
  final GlobalKey _messagesKey = GlobalKey();
  late User _currentUser;
  bool _isLoading = false;
  String? _replyingToMessageId;
  StreamSubscription<List<Message>>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser ?? User.anonymous();
    _initializeMessageController();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeMessageController() async {
    developer.log('🔧 [ThreadsTab] Initializing message controller');
    
    // Set up stream listener first
    _messageSubscription = _messageControllerService.messagesStream.listen(
      (messages) {
        developer.log('📡 [ThreadsTab] Received ${messages.length} messages from stream');
        
        // Log each message for debugging
        for (final msg in messages.where((m) => m.tab == MessageTab.threads)) {
          developer.log('📝 [ThreadsTab] Message ${msg.id.substring(0, 8)}: ${msg.type} - ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}');
        }
        
        if (mounted) {
          final threadMessages = messages.where((m) => m.tab == MessageTab.threads).toList();
          developer.log('📝 [ThreadsTab] Filtered to ${threadMessages.length} thread messages');
          setState(() {
            _messages.clear();
            _messages.addAll(threadMessages);
          });
          developer.log('✅ [ThreadsTab] UI updated with ${_messages.length} messages');
        }
      },
      onError: (error) {
        developer.log('❌ [ThreadsTab] Stream error: $error');
      },
    );
    
    // Then initialize (this will emit existing messages)
    await _messageControllerService.initialize();
    developer.log('✅ [ThreadsTab] MessageController initialized');
    
    // Force a refresh to show any existing messages
    final existingMessages = _messageControllerService.getMessagesByTab(MessageTab.threads);
    developer.log('💾 [ThreadsTab] Loaded ${existingMessages.length} existing messages');
    if (mounted) {
      setState(() {
        _messages.clear();
        _messages.addAll(existingMessages);
      });
      developer.log('✅ [ThreadsTab] Displayed ${_messages.length} existing messages');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_isLoading) return;

    final messageText = _messageController.text.trim();
    developer.log('📤 [ThreadsTab] Sending message: $messageText');

    setState(() {
      _isLoading = true;
    });

    try {
      // Haptic feedback
      HapticFeedback.lightImpact();

      final success = await _messageControllerService.sendTextMessage(
        messageText,
        MessageTab.threads,
      );

      developer.log('📬 [ThreadsTab] Send result: $success');

      if (success) {
        _messageController.clear();
        _replyingToMessageId = null;

        // Force immediate refresh from controller
        developer.log('🔄 [ThreadsTab] Forcing UI refresh');
        final updatedMessages = _messageControllerService.getMessagesByTab(MessageTab.threads);
        developer.log('📊 [ThreadsTab] Got ${updatedMessages.length} messages after send');
        
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(updatedMessages);
          });
          developer.log('✅ [ThreadsTab] UI refreshed with ${_messages.length} messages');
        }

        // Scroll to bottom with animation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: AppTheme.mediumAnimation,
              curve: Curves.easeOutCubic,
            );
          }
        });
      } else {
        developer.log('❌ [ThreadsTab] Send failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send message. Please try again.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      developer.log('❌ [ThreadsTab] Send error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('🏗️ [ThreadsTab] Building UI with ${_messages.length} messages');
    
    return Column(
      children: [
        // Connection status banner
        _buildConnectionBanner(),
        // Messages list
        Expanded(
          child: RepaintBoundary(
            key: _messagesKey,
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    developer.log('🎨 [ThreadsTab] Building message card $index of ${_messages.length}');
                    
                    final message = _messages[index];
                    final isOwnMessage = message.senderId == _currentUser.id;
                    final isThreadStart = index == 0 ||
                        _messages[index - 1].senderId != message.senderId;
                    final showAvatar = isThreadStart;

                    final parentMsg = message.parentId != null
                        ? _messages.firstWhere(
                            (m) => m.id == message.parentId,
                            orElse: () => message,
                          )
                        : null;

                    // Calculate thread depth for indentation
                    final threadDepth = _calculateThreadDepth(message);
                    final isReply = message.parentId != null;

                    developer.log('📨 [ThreadsTab] Message: ${message.type} - depth: $threadDepth');

                    return Padding(
                      padding: EdgeInsets.only(left: threadDepth * 40.0),
                      child: Container(
                        decoration: isReply ? BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.accentColor.withAlpha((255 * 0.3).round()),
                              width: 2,
                            ),
                          ),
                        ) : null,
                        child: MessageCard(
                          message: message,
                          isOwnMessage: isOwnMessage,
                          showAvatar: showAvatar,
                          isThreadStart: isThreadStart,
                          parentMessage: parentMsg,
                          onTap: () {
                            developer.log('👆 [ThreadsTab] Message tapped: ${message.id}');
                          },
                          onReply: () {
                            developer.log('↩️ [ThreadsTab] Reply to: ${message.id}');
                            _startReply(message);
                          },
                          onShare: () {
                            developer.log('📤 [ThreadsTab] Share: ${message.id}');
                            _shareMessageAsScreenshot(message);
                          },
                        ),
                      ),
                    );
                  },
                ),
          ),
        ),
        // Reply indicator
        if (_replyingToMessageId != null) _buildReplyIndicator(),
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
    developer.log('📭 [ThreadsTab] Showing empty state');
    
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
          const SizedBox(height: 16),
          // Debug info
          if (_messages.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Text(
                'Debug: _messages.length = ${_messages.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textHint,
                      fontFamily: 'monospace',
                    ),
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
            // Attachment button
            _buildMediaButton(
              icon: Icons.attach_file,
              onTap: () {
                _showAttachmentOptions();
              },
            ),
            const SizedBox(width: AppTheme.spacingXS),
            // Voice note button
            _buildMediaButton(
              icon: Icons.mic,
              onTap: () {
                _showVoiceNoteRecorder();
              },
            ),
            const SizedBox(width: AppTheme.spacingS),
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
                color: _isLoading ? AppTheme.textHint : AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                color: Colors.white,
                onPressed: _isLoading ? null : _sendMessage,
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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppTheme.accentColor),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppTheme.accentColor),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppTheme.accentColor),
              title: const Text('Record Video (15s max)'),
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: AppTheme.accentColor),
              title: const Text('Record Voice Note'),
              onTap: () {
                Navigator.pop(context);
                _showVoiceNoteRecorder();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _takePhoto() async {
    try {
      final file = await MediaPickerHelper.takePhoto();
      if (file != null) {
        await _sendMediaMessage(file, MessageType.image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  void _pickImageFromGallery() async {
    try {
      final file = await MediaPickerHelper.pickImageFromGallery();
      if (file != null) {
        await _sendMediaMessage(file, MessageType.image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _recordVideo() async {
    try {
      final file = await MediaPickerHelper.recordVideo();
      if (file != null) {
        await _sendMediaMessage(file, MessageType.video);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording video: $e')),
      );
    }
  }

  void _showVoiceNoteRecorder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceNoteRecorder(
        onRecordingComplete: (audioFile) async {
          Navigator.pop(context);
          await _sendMediaMessage(audioFile, MessageType.audio);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _sendMediaMessage(File file, MessageType type) async {
    developer.log('📤 [ThreadsTab] Sending media: $type - ${file.path}');
    developer.log('📤 [ThreadsTab] File exists before send: ${file.existsSync()}');
    developer.log('📤 [ThreadsTab] Original file size: ${file.lengthSync()} bytes');
    
    // Get caption from text input if exists
    final caption = _messageController.text.trim();
    developer.log('📝 [ThreadsTab] Caption: ${caption.isNotEmpty ? caption : "none"}');
    
    setState(() {
      _isLoading = true;
    });

    try {
      File finalFile = file;
      
      // Compress image if it's an image type
      if (type == MessageType.image) {
        developer.log('🗜️ [ThreadsTab] Compressing image...');
        final compressedFile = await _compressImage(file);
        if (compressedFile != null) {
          finalFile = compressedFile;
          developer.log('✅ [ThreadsTab] Compressed size: ${finalFile.lengthSync()} bytes');
          developer.log('📊 [ThreadsTab] Compression ratio: ${((1 - finalFile.lengthSync() / file.lengthSync()) * 100).toStringAsFixed(1)}%');
        } else {
          developer.log('⚠️ [ThreadsTab] Compression failed, using original');
        }
      }
      
      // For now, we'll store file path + caption separated by ||| 
      // In future, update Message model to have separate caption field
      final content = caption.isNotEmpty 
          ? '${finalFile.path}|||$caption'
          : finalFile.path;
      
      final success = await _messageControllerService.sendMediaMessage(
        content: content,
        type: type,
        tab: MessageTab.threads,
      );

      developer.log('📬 [ThreadsTab] Media send result: $success');

      if (success) {
        // Clear text input (caption was sent with media)
        _messageController.clear();
        
        // Force immediate refresh from controller
        developer.log('🔄 [ThreadsTab] Forcing UI refresh after media send');
        final updatedMessages = _messageControllerService.getMessagesByTab(MessageTab.threads);
        developer.log('📊 [ThreadsTab] Got ${updatedMessages.length} messages after media send');
        
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(updatedMessages);
          });
          developer.log('✅ [ThreadsTab] UI refreshed with ${_messages.length} messages');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(caption.isNotEmpty 
                  ? 'Media with caption sent!' 
                  : 'Media sent successfully!'),
            ),
          );
        }

        // Scroll to bottom
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: AppTheme.mediumAnimation,
              curve: Curves.easeOutCubic,
            );
          }
        });
      } else {
        developer.log('❌ [ThreadsTab] Media send failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send media')),
          );
        }
      }
    } catch (e) {
      developer.log('❌ [ThreadsTab] Media send error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _calculateThreadDepth(Message message) {
    int depth = 0;
    String? currentParentId = message.parentId;
    
    while (currentParentId != null && depth < 5) { // Max depth of 5
      depth++;
      final parent = _messages.firstWhere(
        (m) => m.id == currentParentId,
        orElse: () => Message(
          id: '',
          senderId: '',
          senderName: '',
          content: '',
          type: MessageType.text,
          tab: MessageTab.threads,
          timestamp: DateTime.now(),
          contentHash: '',
        ),
      );
      currentParentId = parent.id.isNotEmpty ? parent.parentId : null;
    }
    
    return depth;
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85, // 85% quality - good balance between size and quality
        minWidth: 1920, // Max width 1920px
        minHeight: 1920, // Max height 1920px
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      developer.log('❌ [ThreadsTab] Compression error: $e');
      return null;
    }
  }

  void _startReply(Message message) {
    setState(() {
      _replyingToMessageId = message.id;
    });

    // Focus on text input
    FocusScope.of(context).requestFocus(FocusNode());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Replying to ${message.senderName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareMessageAsScreenshot(Message message) async {
    try {
      developer.log('📤 [ThreadsTab] Creating screenshot for message: ${message.id}');
      
      // Create a screenshot controller
      final screenshotController = ScreenshotController();
      
      // Create a widget to screenshot
      final messageWidget = Material(
        color: AppTheme.backgroundColor,
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: MessageCard(
            message: message,
            isOwnMessage: message.senderId == _currentUser?.id,
            showAvatar: true,
            isThreadStart: true,
          ),
        ),
      );
      
      // Capture screenshot
      final Uint8List? imageBytes = await screenshotController.captureFromWidget(
        messageWidget,
        pixelRatio: 3.0,
      );
      
      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }
      
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/message_${message.id}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);
      
      developer.log('📤 [ThreadsTab] Screenshot saved: ${file.path}');
      
      // Share the screenshot
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Shared from Mesh App',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screenshot shared successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      developer.log('❌ [ThreadsTab] Share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  Widget _buildReplyIndicator() {
    final replyingMessage = _messages.firstWhere(
      (m) => m.id == _replyingToMessageId,
      orElse: () => _messages.first,
    );

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.accentColor),
      ),
      child: Row(
        children: [
          Icon(Icons.reply, color: AppTheme.accentColor, size: 16),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              'Replying to ${replyingMessage.senderName}: ${replyingMessage.content}',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _replyingToMessageId = null;
              });
            },
            icon: Icon(Icons.close, color: AppTheme.accentColor, size: 16),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
