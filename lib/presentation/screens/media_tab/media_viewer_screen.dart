import 'package:flutter/material.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class MediaViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> mediaItems;
  final int initialIndex;
  final String? senderName;
  final DateTime? timestamp;
  final String? caption;

  const MediaViewerScreen({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.senderName,
    this.timestamp,
    this.caption,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.mediaItems.length,
            itemBuilder: (context, index) {
              final item = widget.mediaItems[index];
              return _buildMediaContent(item);
            },
          ),
          // Top controls
          if (_showControls) _buildTopControls(),
          // Bottom controls
          if (_showControls) _buildBottomControls(),
          // Tap to toggle controls
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'image':
        return _buildImageViewer(item);
      case 'video':
        return _buildVideoViewer(item);
      case 'audio':
        return _buildAudioViewer(item);
      default:
        return _buildImageViewer(item);
    }
  }

  Widget _buildImageViewer(Map<String, dynamic> item) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppTheme.surfaceVariant,
          child: const Center(
            child: Icon(
              Icons.image,
              size: 100,
              color: AppTheme.textHint,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoViewer(Map<String, dynamic> item) {
    return Center(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            // Video placeholder
            Center(
              child: Container(
                width: double.infinity,
                height: 300,
                color: AppTheme.surfaceVariant,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Play button overlay
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.6).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            // Duration badge
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.7).round()),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  item['duration'] ?? '0:00',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioViewer(Map<String, dynamic> item) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Audio waveform visualization
            Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: const Center(
                child: Icon(
                  Icons.graphic_eq,
                  size: 60,
                  color: AppTheme.accentColor,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            // Play button
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            // Duration
            Text(
              item['duration'] ?? '0:00',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
          left: AppTheme.spacingM,
          right: AppTheme.spacingM,
          bottom: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha((255 * 0.8).round()),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Close button
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
            const Spacer(),
            // Page indicator
            Text(
              '${_currentIndex + 1} of ${widget.mediaItems.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            // Share button
            IconButton(
              onPressed: () {
                // TODO: Implement share functionality
              },
              icon: const Icon(
                Icons.share,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final currentItem = widget.mediaItems[_currentIndex];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: AppTheme.spacingM,
          left: AppTheme.spacingM,
          right: AppTheme.spacingM,
          bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withAlpha((255 * 0.8).round()),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sender info
            if (widget.senderName != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.accentColor,
                    child: Text(
                      widget.senderName![0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    widget.senderName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (widget.timestamp != null)
                    Text(
                      _formatTimestamp(widget.timestamp!),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
            ],
            // Caption
            if (widget.caption != null && widget.caption!.isNotEmpty) ...[
              Text(
                widget.caption!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],
            // Media type indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: AppTheme.spacingXS,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((255 * 0.2).round()),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getMediaIcon(currentItem['type']),
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    _getMediaTypeLabel(currentItem['type']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMediaIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getMediaTypeLabel(String type) {
    switch (type) {
      case 'image':
        return 'Photo';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      default:
        return 'Media';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
